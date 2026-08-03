import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

// MARK: - WeatherAPIClient
//
// Swift OpenAPI Generator создаёт из openapi.yaml три файла в DerivedData:
//   • Types.swift      — все схемы в namespace Components.Schemas.*
//   • Client.swift     — структура Client с методами getWeather / getForecast
//   • Server.swift     — серверные stub-ы (не используем)
//
// Типы доступны как:
//   Components.Schemas.WeatherDTO
//   Components.Schemas.ForecastDTO
//   Components.Schemas.MainDTO   и т.д.
//
// Typealias-ы ниже скрывают этот namespace от потребителей фреймворка.

// MARK: - Public typealiases (re-export generated types)

public typealias WeatherDTO  = Components.Schemas.WeatherDTO
public typealias ForecastDTO = Components.Schemas.ForecastDTO
public typealias MainDTO     = Components.Schemas.MainDTO
public typealias WeatherConditionDTO = Components.Schemas.WeatherConditionDTO
public typealias ForecastItemDTO     = Components.Schemas.ForecastItemDTO
public typealias CityDTO             = Components.Schemas.CityDTO

// MARK: - WeatherAPIClient

/// Обёртка над сгенерированным `Client`.
/// Предоставляет чистый Swift-интерфейс без деталей OpenAPI.
public struct WeatherAPIClient: Sendable {

    private let client: Client

    // MARK: Init

    /// Production-инициализатор — использует URLSessionTransport.
    public init(serverURL: URL) {
        self.client = Client(
            serverURL: serverURL,
            transport: URLSessionTransport()
        )
    }

    /// Тест-инициализатор — принимает любой `ClientTransport` из OpenAPIRuntime.
    public init(serverURL: URL, transport: any ClientTransport) {
        self.client = Client(
            serverURL: serverURL,
            transport: transport
        )
    }

    // MARK: - Weather

    /// Получить текущую погоду для города.
    public func fetchWeather(
        city: String,
        apiKey: String,
        units: String = "metric"
    ) async throws -> WeatherDTO {
        let response = try await client.getWeather(
            query: .init(q: city, appid: apiKey, units: units)
        )
        switch response {
        case .ok(let ok):
            return try ok.body.json
        case .undocumented(let statusCode, _):
            throw WeatherAPIError.undocumentedResponse(statusCode: statusCode)
        }
    }

    // MARK: - Forecast

    /// Получить 5-дневный прогноз (шаг 3 ч) для города.
    public func fetchForecast(
        city: String,
        apiKey: String,
        units: String = "metric",
        count: Int = 40
    ) async throws -> ForecastDTO {
        let response = try await client.getForecast(
            query: .init(q: city, appid: apiKey, units: units, cnt: count)
        )
        switch response {
        case .ok(let ok):
            return try ok.body.json
        case .undocumented(let statusCode, _):
            throw WeatherAPIError.undocumentedResponse(statusCode: statusCode)
        }
    }
}

// MARK: - Errors

public enum WeatherAPIError: Error, Equatable, Sendable {
    case undocumentedResponse(statusCode: Int)
    case missingData
}
