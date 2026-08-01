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
            ],
            additionalInfoPlist: [
                "WEATHER_API_KEY": "$(WEATHER_API_KEY)"
            ],
            settings: .settings(
                configurations: [
                    .debug(name: "Debug", xcconfig: "Configurations/Debug.xcconfig"),
                    .release(name: "Release", xcconfig: "Configurations/Release.xcconfig"),
                ]
            )
        ),
    ]
)
