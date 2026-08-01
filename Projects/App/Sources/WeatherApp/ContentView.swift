import SwiftUI
import WeatherFeature
import ComposableArchitecture

struct ContentView: View {
    var body: some View {
        WeatherView(
            store: Store(initialState: WeatherFeature.State()) {
                WeatherFeature()
            }
        )
    }
}
