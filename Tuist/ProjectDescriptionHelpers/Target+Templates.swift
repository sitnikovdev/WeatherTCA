import ProjectDescription

public extension Target {

    // ── iOS App ────────────────────────────────────────────
    static func app(
        name: String,
        dependencies: [TargetDependency] = [],
        additionalInfoPlist: [String: Plist.Value] = [:],
        settings: Settings? = nil
    ) -> Target {
        .target(
            name: name,
            destinations: Constants.destinations,
            product: .app,
            bundleId: "\(Constants.bundlePrefix).\(name)",
            deploymentTargets: Constants.deploymentTarget,
            infoPlist: .extendingDefault(with: [
                "CFBundleDisplayName": "\(name)",
                "CFBundleVersion": "1",
                "CFBundleShortVersionString": "1.0.0",
                "UILaunchScreen": [:],
                // ATS — OpenWeatherMap использует HTTPS, явно разрешаем
                "NSAppTransportSecurity": [
                    "NSAllowsArbitraryLoads": false,
                    "NSExceptionDomains": [
                        "api.openweathermap.org": [
                            "NSExceptionAllowsInsecureHTTPLoads": false,
                            "NSIncludesSubdomains": true,
                        ]
                    ]
                ],
            ].merging(additionalInfoPlist) { _, new in new }),
            sources: ["Sources/\(name)/**"],
            resources: ["Resources/**"],
            dependencies: dependencies,
            settings: settings
        )
    }

    // ── Dynamic Framework ──────────────────────────────────
    // Использовать когда модуль линкуется в 2+ таргета
    static func framework(
        name: String,
        sources: SourceFilesList? = nil,
        resources: ResourceFileElements? = nil,
        dependencies: [TargetDependency] = []
    ) -> Target {
        .target(
            name: name,
            destinations: Constants.destinations,
            product: .framework,
            bundleId: "\(Constants.bundlePrefix).\(name)",
            deploymentTargets: Constants.deploymentTarget,
            sources: sources ?? ["Sources/\(name)/**"],
            resources: resources,
            dependencies: dependencies
        )
    }

    // ── Static Framework ───────────────────────────────────
    // Использовать когда модуль линкуется только в 1 таргет
    static func staticFramework(
        name: String,
        sources: SourceFilesList? = nil,
        dependencies: [TargetDependency] = []
    ) -> Target {
        .target(
            name: name,
            destinations: Constants.destinations,
            product: .staticFramework,
            bundleId: "\(Constants.bundlePrefix).\(name)",
            deploymentTargets: Constants.deploymentTarget,
            sources: sources ?? ["Sources/\(name)/**"],
            dependencies: dependencies
        )
    }

    // ── Unit Tests ─────────────────────────────────────────
    static func tests(
        name: String,
        testing targetName: String,
        dependencies: [TargetDependency] = []
    ) -> Target {
        .target(
            name: name,
            destinations: Constants.destinations,
            product: .unitTests,
            bundleId: "\(Constants.bundlePrefix).\(name)",
            deploymentTargets: Constants.deploymentTarget,
            sources: ["Tests/\(name)/**"],
            dependencies: [.target(name: targetName)] + dependencies
        )
    }
}
