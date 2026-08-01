import ProjectDescription
import ProjectDescriptionHelpers

// В Tuist 4 build-tool plugin подключается как TargetDependency
// типа .package(product:type:.plugin) — не через отдельный параметр plugins.
// Дополнительно нужно объявить пакет в массиве packages проекта,
// иначе Tuist не сможет разрезолвить плагин.

let project = Project(
    name: "OpenAPIClient",
    organizationName: "WeatherTCA",
    options: .options(
        defaultKnownRegions: ["en"],
        developmentRegion: "en"
    ),
    packages: [
        // Пакет нужно объявить здесь, чтобы Tuist знал откуда брать плагин.
        // swift-openapi-generator подтягивается из Tuist/Package.swift,
        // но для разрезолва .plugin-зависимости нужна явная ссылка на packages.
        .remote(
            url: "https://github.com/apple/swift-openapi-generator",
            requirement: .upToNextMajor(from: "1.3.0")
        ),
    ],
    settings: .settings(
        base: Constants.baseSettings,
        configurations: [
            .debug(name: "Debug"),
            .release(name: "Release"),
        ]
    ),
    targets: [
        // .framework (dynamic) — используется из Networking и WeatherFeature
        //
        // Build-tool plugin: swift-openapi-generator ищет файлы в SRCROOT (working dir).
        // Apple docs явно поддерживают симлинки: "can also be a symlink".
        // openapi.yaml и openapi-generator-config.yaml хранятся в Sources/OpenAPIClient/,
        // а симлинки на них создаются в корне таргета (SRCROOT) — скриптом выше.
        .target(
            name: "OpenAPIClient",
            destinations: Constants.destinations,
            product: .framework,
            bundleId: "\(Constants.bundlePrefix).OpenAPIClient",
            deploymentTargets: Constants.deploymentTarget,
            // Согласно документации Apple (туториал "Generating a client in an Xcode project"):
            // yaml-файлы ОБЯЗАТЕЛЬНО должны быть в фазе Compile Sources таргета.
            // Без этого плагин не получает их как INPUT_FILES → ошибка "No config file found".
            // Tuist добавляет в Compile Sources всё, что перечислено в sources:.
            // Xcode не компилирует .yaml (не Swift), но передаёт их плагину — это и нужно.
            sources: ["Sources/OpenAPIClient/**/*.swift"],
            dependencies: [
                .external(name: "OpenAPIRuntime"),
                .external(name: "OpenAPIURLSession"),
                // Build-tool plugin — генерирует Client + Types из openapi.yaml
                .package(product: "OpenAPIGenerator", type: .plugin),
            ]
        ),
    ],
    additionalFiles: []
)
