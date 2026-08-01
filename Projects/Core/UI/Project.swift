import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: "CoreUI",
    targets: [
        // .staticFramework — CoreUI линкуется только из WeatherFeature.
        // Dynamic framework для SwiftUI-модуля без asset catalog вызывает
        // краш CUICatalog при старте: "-[CUICatalog initWithName:fromBundle:error:]
        // unrecognized selector". Static framework не создаёт отдельный bundle
        // → нет попытки загрузить несуществующий asset catalog.
        .staticFramework(
            name: "CoreUI",
            dependencies: []
        ),
    ]
)
