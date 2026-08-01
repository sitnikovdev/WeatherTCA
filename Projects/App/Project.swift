import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: "App",
    targets: [
        .app(
            name: "WeatherApp",
            dependencies: [
                .project(target: "WeatherFeature", path: "../Features/Weather"),
                // CoreUI и Networking подтягиваются транзитивно
                // через WeatherFeature — не линкуем дважды
            ]
        ),
    ]
)
