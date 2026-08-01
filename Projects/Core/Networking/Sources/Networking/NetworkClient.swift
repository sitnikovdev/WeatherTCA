import Foundation
import OpenAPIRuntime
import OpenAPIClient

// MARK: - Legacy Endpoint protocol (сохранён для совместимости)
//
// Используется для кастомных запросов, не описанных в openapi.yaml.
// Для всех погодных запросов используй WeatherAPIClient напрямую.

public protocol Endpoint: Sendable {
    var path: String { get }
    var method: String { get }
    var queryItems: [URLQueryItem] { get }
}

public extension Endpoint {
    var method: String { "GET" }
    var queryItems: [URLQueryItem] { [] }
}

public enum NetworkError: Error, Equatable, Sendable {
    case badURL
    case badResponse(statusCode: Int)
    case decodingFailed
    case apiError(WeatherAPIError)
}

// MARK: - WeatherNetworkClient
//
// Фасад над WeatherAPIClient (Swift OpenAPI).
// WeatherFeature работает только с этим протоколом —
// детали транспорта и кодогенерации скрыты.

public protocol WeatherNetworkClientProtocol: Sendable {
    func fetchWeather(city: String, apiKey: String) async throws -> WeatherResponsePayload
    func fetchForecast(city: String, apiKey: String) async throws -> ForecastPayload
}

// MARK: - Payload types
//
// Тонкие обёртки над сгенерированными DTO.
// Позволяют WeatherFeature не импортировать OpenAPIClient напрямую.

public struct WeatherResponsePayload: Sendable, Equatable {
    public let city: String
    public let temperature: Double
    public let feelsLike: Double
    public let humidity: Int
    public let description: String

    public init(city: String, temperature: Double, feelsLike: Double, humidity: Int, description: String) {
        self.city = city
        self.temperature = temperature
        self.feelsLike = feelsLike
        self.humidity = humidity
        self.description = description
    }
}

public struct ForecastPayload: Sendable, Equatable {
    public struct Item: Sendable, Equatable, Identifiable {
        public let id: Int
        public let timestamp: Int
        public let temperature: Double
        public let description: String

        public init(timestamp: Int, temperature: Double, description: String) {
            self.id = timestamp
            self.timestamp = timestamp
            self.temperature = temperature
            self.description = description
        }
    }

    public let city: String
    public let items: [Item]

    public init(city: String, items: [Item]) {
        self.city = city
        self.items = items
    }
}

// MARK: - Live implementation

public struct WeatherNetworkClient: WeatherNetworkClientProtocol {

    private let apiClient: WeatherAPIClient
    private let apiKey: String

    public init(serverURL: URL, apiKey: String) {
        self.apiClient = WeatherAPIClient(serverURL: serverURL)
        self.apiKey = apiKey
    }

    // MARK: WeatherNetworkClientProtocol

    public func fetchWeather(city: String, apiKey: String) async throws -> WeatherResponsePayload {
        let dto = try await apiClient.fetchWeather(city: city, apiKey: apiKey)
        return WeatherResponsePayload(
            city: dto.name,
            temperature: dto.main.temp,
            feelsLike: dto.main.feels_like,
            humidity: dto.main.humidity,
            description: dto.weather.first?.description ?? ""
        )
    }

    public func fetchForecast(city: String, apiKey: String) async throws -> ForecastPayload {
        let dto = try await apiClient.fetchForecast(city: city, apiKey: apiKey)
        let items = dto.list.map { item in
            ForecastPayload.Item(
                timestamp: Int(item.dt),
                temperature: item.main.temp,
                description: item.weather.first?.description ?? ""
            )
        }
        return ForecastPayload(city: dto.city.name, items: items)
    }
}

// MARK: - Legacy URLSession-based client (для кастомных endpoint-ов)

public protocol NetworkClientProtocol: Sendable {
    func request<T: Decodable & Sendable>(_ endpoint: any Endpoint) async throws -> T
}

public struct NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    private let baseURL: URL
    private let decoder: JSONDecoder

    public init(
        baseURL: URL,
        session: URLSession = .shared,
        decoder: JSONDecoder = .init()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
    }

    public func request<T: Decodable & Sendable>(_ endpoint: any Endpoint) async throws -> T {
        var components = URLComponents(
            url: baseURL.appending(path: endpoint.path),
            resolvingAgainstBaseURL: false
        )
        if !endpoint.queryItems.isEmpty {
            components?.queryItems = endpoint.queryItems
        }
        guard let url = components?.url else { throw NetworkError.badURL }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method

        let (data, response) = try await session.data(for: urlRequest)

        if let http = response as? HTTPURLResponse,
           !(200..<300).contains(http.statusCode) {
            throw NetworkError.badResponse(statusCode: http.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}
