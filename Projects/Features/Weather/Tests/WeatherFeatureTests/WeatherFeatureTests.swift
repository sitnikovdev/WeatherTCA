import ComposableArchitecture
import Models
import XCTest
@testable import WeatherFeature

@MainActor
final class WeatherFeatureTests: XCTestCase {

    func testCityChanged() async {
        let store = TestStore(initialState: WeatherFeature.State()) {
            WeatherFeature()
        }
        await store.send(.cityChanged("Moscow")) {
            $0.city = "Moscow"
        }
    }

    func testCityChangedClearsErrorMessage() async {
        var initialState = WeatherFeature.State()
        initialState.errorMessage = "Some previous error"

        let store = TestStore(initialState: initialState) {
            WeatherFeature()
        }
        await store.send(.cityChanged("Paris")) {
            $0.city = "Paris"
            $0.errorMessage = nil
        }
    }

    func testFetchWeatherIgnoredWhenCityEmpty() async {
        let store = TestStore(initialState: WeatherFeature.State()) {
            WeatherFeature()
        }
        await store.send(.fetchWeatherTapped)
    }

    func testFetchWeatherSuccess() async {
        let mockWeather = WeatherResponse(
            city: "London",
            temperature: 18.5,
            description: "Partly cloudy",
            humidity: 65,
            feelsLike: 17.0
        )

        let store = TestStore(initialState: WeatherFeature.State()) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient = WeatherClient { _ in mockWeather }
        }

        await store.send(.cityChanged("London")) {
            $0.city = "London"
        }
        await store.send(.fetchWeatherTapped) {
            $0.isLoading = true
        }
        await store.receive(.weatherResponse(.success(mockWeather))) {
            $0.isLoading = false
            $0.weather = mockWeather
        }
    }

    func testFetchWeatherCityNotFound() async {
        let store = TestStore(initialState: WeatherFeature.State()) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient = WeatherClient { _ in throw WeatherError.cityNotFound }
        }

        await store.send(.cityChanged("BadCity")) {
            $0.city = "BadCity"
        }
        await store.send(.fetchWeatherTapped) {
            $0.isLoading = true
        }
        await store.receive(.weatherResponse(.failure(.cityNotFound))) {
            $0.isLoading = false
            $0.errorMessage = "Город не найден. Проверьте название."
        }
    }

    func testFetchWeatherInvalidAPIKey() async {
        let store = TestStore(initialState: WeatherFeature.State()) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient = WeatherClient { _ in throw WeatherError.invalidAPIKey }
        }

        await store.send(.cityChanged("Paris")) {
            $0.city = "Paris"
        }
        await store.send(.fetchWeatherTapped) {
            $0.isLoading = true
        }
        await store.receive(.weatherResponse(.failure(.invalidAPIKey))) {
            $0.isLoading = false
            $0.errorMessage = "Неверный API-ключ."
        }
    }

    func testFetchWeatherRateLimited() async {
        let store = TestStore(initialState: WeatherFeature.State()) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient = WeatherClient { _ in throw WeatherError.rateLimited }
        }

        await store.send(.cityChanged("Tokyo")) {
            $0.city = "Tokyo"
        }
        await store.send(.fetchWeatherTapped) {
            $0.isLoading = true
        }
        await store.receive(.weatherResponse(.failure(.rateLimited))) {
            $0.isLoading = false
            $0.errorMessage = "Превышено количество запросов. Попробуйте позже."
        }
    }
}
