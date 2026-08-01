import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: "Networking",
    targets: [
        // .staticFramework — один потребитель (WeatherFeature)
        .staticFramework(
            name: "Networking",
            dependencies: [
                .project(target: "OpenAPIClient", path: "../../API/OpenAPIClient"),
                .external(name: "OpenAPIRuntime"),
            ]
        ),
    ]
)
