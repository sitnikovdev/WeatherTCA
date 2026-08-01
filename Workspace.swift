import ProjectDescription

let workspace = Workspace(
    name: "WeatherTCA",
    projects: [
        "Projects/App",
        "Projects/Features/Weather",
        "Projects/Core/UI",
        "Projects/Core/Networking",
        "Projects/Shared/Models",
        "Projects/API/OpenAPIClient",
    ]
)
