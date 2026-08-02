// swift-tools-version: 6.2
import PackageDescription

#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
    productTypes: [
        "ComposableArchitecture":        .framework,
        "OpenAPIRuntime":                .framework,
        "OpenAPIURLSession":             .framework,
        // Линкуется из OpenAPIRuntime + OpenAPIURLSession → dynamic
        "HTTPTypes":                     .framework,
        "HTTPTypesFoundation":           .framework,
        // Линкуется из ComposableArchitecture + OpenAPIURLSession → dynamic
        "InternalCollectionsUtilities":  .framework,
    ]
)
#endif

let package = Package(
    name: "WeatherTCA",
    dependencies: [
        // TCA
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "1.25.5"
        ),
        // Протоколы Client / Transport / Middleware — нужны в рантайме
        .package(
            url: "https://github.com/apple/swift-openapi-runtime",
            from: "1.5.0"
        ),
        // URLSession-транспорт для Swift OpenAPI
        .package(
            url: "https://github.com/apple/swift-openapi-urlsession",
            from: "1.0.2"
        ),
    ]
)
