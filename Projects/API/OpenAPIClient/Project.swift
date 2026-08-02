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
    settings: .settings(
        base: Constants.baseSettings,
        configurations: [
            .debug(name: "Debug"),
            .release(name: "Release"),
        ]
    ),
    targets: [
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
            sources: [
                "Sources/OpenAPIClient/**/*.swift",
                "Sources/OpenAPIClient/Generated/**/*.swift",
            ],
            dependencies: [
                .external(name: "OpenAPIRuntime"),
                .external(name: "OpenAPIURLSession"),
            ]
        ),
    ],
    additionalFiles: []
)
