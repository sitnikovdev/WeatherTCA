import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: "WeatherFeature",
    targets: [
        // dynamic — App линкует WeatherFeature напрямую
        .framework(
            name: "WeatherFeature",
            dependencies: [
                .project(target: "Models",        path: "../../Shared/Models"),
                .project(target: "OpenAPIClient", path: "../../API/OpenAPIClient"),
                .project(target: "CoreUI",        path: "../../Core/UI"),
                .project(target: "Networking",    path: "../../Core/Networking"),
                .external(name: "ComposableArchitecture"),
            ]
        ),
        .tests(
            name: "WeatherFeatureTests",
            testing: "WeatherFeature",
            dependencies: [
                .external(name: "ComposableArchitecture"),
            ]
        ),
    ]
)
