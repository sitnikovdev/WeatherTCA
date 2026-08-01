import Foundation

// MARK: - Domain models
//
// Эти модели — «доменный слой»: они не зависят ни от OpenAPI-DTO,
// ни от Networking. WeatherFeature работает именно с ними.
// Маппинг из WeatherResponsePayload → WeatherResponse происходит
// в WeatherFeature через статические фабрики ниже.

public struct WeatherResponse: Codable, Equatable, Sendable {
    public let city: String
    public let temperature: Double
    public let description: String
    public let humidity: Int
    public let feelsLike: Double

    public init(
        city: String,
        temperature: Double,
        description: String,
        humidity: Int,
        feelsLike: Double
    ) {
        self.city = city
        self.temperature = temperature
        self.description = description
        self.humidity = humidity
        self.feelsLike = feelsLike
    }
}

public struct Forecast: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public let date: Date
    public let minTemp: Double
    public let maxTemp: Double
    public let description: String

    public init(
        id: UUID = UUID(),
        date: Date,
        minTemp: Double,
        maxTemp: Double,
        description: String
    ) {
        self.id = id
        self.date = date
        self.minTemp = minTemp
        self.maxTemp = maxTemp
        self.description = description
    }
}

// MARK: - Mapping helpers (Payload → Domain)
//
// Import Networking в Models нежелателен (круговая зависимость).
// Поэтому маппинг реализован через generic init с label-параметрами,
// а WeatherFeature вызывает его, передавая значения из Payload.

public extension WeatherResponse {
    /// Создать из плоских значений, полученных из WeatherResponsePayload.
    init(
        fromPayloadCity city: String,
        temperature: Double,
        feelsLike: Double,
        humidity: Int,
        description: String
    ) {
        self.init(
            city: city,
            temperature: temperature,
            description: description,
            humidity: humidity,
            feelsLike: feelsLike
        )
    }
}

public extension Forecast {
    /// Создать из плоских значений ForecastPayload.Item.
    init(fromTimestamp timestamp: Int, temperature: Double, description: String) {
        self.init(
            date: Date(timeIntervalSince1970: TimeInterval(timestamp)),
            minTemp: temperature,
            maxTemp: temperature,
            description: description
        )
    }
}
