import ComposableArchitecture
import Foundation
import Models
import Networking

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
        // URL берётся из openapi.yaml servers[0].url
        let serverURL = URL(string: "https://api.openweathermap.org/data/2.5")!
        // TODO: перенести apiKey в конфиг / Secrets (не хранить в коде)
        // ⚠️  ЗАМЕНИ НА РЕАЛЬНЫЙ КЛЮЧ: https://home.openweathermap.org/api_keys
        // После регистрации ключ активируется в течение 2 часов.
        let apiKey = "ec4b779c6f354c4cfb9b99e3de5c069c"

        // WeatherNetworkClient может бросить при некорректном URL —
        // в production это невозможно, поэтому try! оправдан.
        let networkClient = WeatherNetworkClient(
            serverURL: serverURL,
            apiKey: apiKey
        )

        return WeatherClient { city in
            let payload = try await networkClient.fetchWeather(city: city, apiKey: apiKey)
            return WeatherResponse(
                fromPayloadCity: payload.city,
                temperature: payload.temperature,
                feelsLike: payload.feelsLike,
                humidity: payload.humidity,
                description: payload.description
            )
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

    public enum Action {
        case cityChanged(String)
        case fetchWeatherTapped
        case weatherResponse(Result<WeatherResponse, Error>)
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
                    await send(.weatherResponse(
                        Result { try await weatherClient.fetchWeather(city) }
                    ))
                }

            case let .weatherResponse(.success(response)):
                state.isLoading = false
                state.weather = response
                return .none

            case let .weatherResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
            }
        }
    }
}
