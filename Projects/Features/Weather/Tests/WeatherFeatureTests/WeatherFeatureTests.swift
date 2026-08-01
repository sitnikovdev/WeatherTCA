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

        // TCA 1.x требует keypath к case вместо значения action,
        // либо Action: Equatable. Используем \.weatherResponse + assert closure.
        await store.receive(\.weatherResponse) {
            $0.isLoading = false
            $0.weather = mockWeather
        }
    }

    func testFetchWeatherFailure() async {
        struct FakeError: Error, LocalizedError {
            var errorDescription: String? { "Network error" }
        }

        let store = TestStore(initialState: WeatherFeature.State()) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient = WeatherClient { _ in throw FakeError() }
        }

        await store.send(.cityChanged("BadCity")) {
            $0.city = "BadCity"
        }

        await store.send(.fetchWeatherTapped) {
            $0.isLoading = true
        }

        await store.receive(\.weatherResponse) {
            $0.isLoading = false
            $0.errorMessage = "Network error"
        }
    }
}
