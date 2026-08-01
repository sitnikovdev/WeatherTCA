import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: "Models",
    targets: [
        // .staticFramework — один потребитель (WeatherFeature)
        .staticFramework(
            name: "Models",
            dependencies: []
        ),
    ]
)
