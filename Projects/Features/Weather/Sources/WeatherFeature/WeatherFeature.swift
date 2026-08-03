import ComposableArchitecture
import Foundation
import Models
import Networking
import OpenAPIClient

// MARK: - WeatherClient dependency
//
// TCA-dependency, обёртка над WeatherNetworkClientProtocol.
// Тесты подставляют mock; production — WeatherNetworkClient.

public struct WeatherClient: Sendable {
    public var fetchWeather: @Sendable (String) async throws -> WeatherResponse

    public init(fetchWeather: @Sendable @escaping (String) async throws -> WeatherResponse) {
        self.fetchWeather = fetchWeather
    }
}

extension WeatherClient: DependencyKey {
    /// Live-реализация: WeatherNetworkClient → WeatherAPIClient → OpenAPI
    public static var liveValue: WeatherClient {
        let serverURL = URL(string: "https://api.openweathermap.org/data/2.5")!
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "WEATHER_API_KEY") as? String ?? ""

        let networkClient = WeatherNetworkClient(
            serverURL: serverURL,
            apiKey: apiKey
        )

        return WeatherClient { city in
            do {
                let payload = try await networkClient.fetchWeather(city: city, apiKey: apiKey)
                return WeatherResponse(
                    fromPayloadCity: payload.city,
                    temperature: payload.temperature,
                    feelsLike: payload.feelsLike,
                    humidity: payload.humidity,
                    description: payload.description
                )
            } catch let apiError as WeatherAPIError {
                throw WeatherError(fromAPIError: apiError)
            } catch is DecodingError {
                throw WeatherError.decodingFailed
            } catch is URLError {
                throw WeatherError.network
            } catch {
                throw WeatherError.unknown
            }
        }
    }

    /// Preview / test mock — возвращает фиксированные данные.
    public static var previewValue: WeatherClient {
        WeatherClient { city in
            WeatherResponse(
                city: city,
                temperature: 22.5,
                description: "Partly cloudy",
                humidity: 60,
                feelsLike: 21.0
            )
        }
    }
}

extension DependencyValues {
    public var weatherClient: WeatherClient {
        get { self[WeatherClient.self] }
        set { self[WeatherClient.self] = newValue }
    }
}

// MARK: - WeatherError mapping (WeatherAPIError → WeatherError)
//
// Живёт здесь, а не в Models, потому что Models не должен зависеть
// от OpenAPIClient — это единственное место, которое видит оба типа.

extension WeatherError {
    init(fromAPIError apiError: WeatherAPIError) {
        switch apiError {
        case .undocumentedResponse(let code):
            switch code {
            case 401: self = .invalidAPIKey
            case 404: self = .cityNotFound
            case 429: self = .rateLimited
            default:  self = .unknown
            }
        case .missingData:
            self = .unknown
        }
    }
}

// MARK: - WeatherFeature Reducer

@Reducer
public struct WeatherFeature {
    @ObservableState
    public struct State: Equatable {
        public var city: String = ""
        public var weather: WeatherResponse?
        public var isLoading: Bool = false
        public var errorMessage: String?

        /// Удобный аксессор для отображения температуры в UI.
        public var temperature: Double? { weather?.temperature }

        public init() {}
    }

    public enum Action: Equatable {
        case cityChanged(String)
        case fetchWeatherTapped
        case weatherResponse(Result<WeatherResponse, WeatherError>)
    }

    @Dependency(\.weatherClient) var weatherClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

            case let .cityChanged(city):
                state.city = city
                state.errorMessage = nil
                return .none

            case .fetchWeatherTapped:
                guard !state.city.isEmpty else { return .none }
                state.isLoading = true
                state.errorMessage = nil
                let city = state.city
                return .run { send in
                    do {
                        let response = try await weatherClient.fetchWeather(city)
                        await send(.weatherResponse(.success(response)))
                    } catch let weatherError as WeatherError {
                        await send(.weatherResponse(.failure(weatherError)))
                    } catch {
                        await send(.weatherResponse(.failure(.unknown)))
                    }
                }

            case let .weatherResponse(.success(response)):
                state.isLoading = false
                state.weather = response
                return .none

            case let .weatherResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.errorDescription
                return .none
            }
        }
    }
}
