import ProjectDescription

public enum Constants {
    public static let bundlePrefix     = "com.weathertca"
    public static let deploymentTarget = DeploymentTargets.iOS("17.0")
    public static let destinations: Destinations = Set([.iPhone, .iPad])
    public static let swiftVersion: SettingValue = "5.9"

    public static let baseSettings: SettingsDictionary = [
        "SWIFT_VERSION": swiftVersion,
    ]
}

public extension Project {
    static func module(
        name: String,
        targets: [Target],
        additionalFiles: [FileElement] = []
    ) -> Project {
        Project(
            name: name,
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
            targets: targets,
            additionalFiles: additionalFiles
        )
    }
}
