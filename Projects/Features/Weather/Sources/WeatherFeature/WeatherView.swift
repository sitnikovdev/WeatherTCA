import ComposableArchitecture
import CoreUI
import SwiftUI

public struct WeatherView: View {
    @Bindable var store: StoreOf<WeatherFeature>

    public init(store: StoreOf<WeatherFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: DesignTokens.Spacing.lg) {
                TextField("Город", text: $store.city.sending(\.cityChanged))
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, DesignTokens.Spacing.md)

                Button("Получить погоду") {
                    store.send(.fetchWeatherTapped)
                }
                .buttonStyle(.borderedProminent)
                .disabled(store.city.isEmpty)

                if store.isLoading {
                    ProgressView()
                }

                if let weather = store.weather {
                    VStack(spacing: DesignTokens.Spacing.sm) {
                        Text(weather.city)
                            .font(DesignTokens.Typography.title)

                        Text("\(weather.temperature, specifier: "%.1f")°C")
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                            .foregroundStyle(DesignTokens.Colors.primary)

                        Text(weather.description.capitalized)
                            .font(DesignTokens.Typography.body)
                            .foregroundStyle(.secondary)

                        HStack(spacing: DesignTokens.Spacing.lg) {
                            Label(
                                "Ощущается \(weather.feelsLike, specifier: "%.1f")°C",
                                systemImage: "thermometer.medium"
                            )
                            Label(
                                "Влажность \(weather.humidity)%",
                                systemImage: "humidity"
                            )
                        }
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(DesignTokens.Colors.secondary)
                    .clipShape(.rect(cornerRadius: 16))
                    .padding(.horizontal, DesignTokens.Spacing.md)
                }

                if let error = store.errorMessage {
                    Text(error)
                        .foregroundStyle(DesignTokens.Colors.error)
                        .font(DesignTokens.Typography.caption)
                        .padding(.horizontal, DesignTokens.Spacing.md)
                }

                Spacer()
            }
            .navigationTitle("Погода")
        }
    }
}
