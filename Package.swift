// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "iOSMediationAdapters",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "GAM-DIO-Adapter",
            type: .static,
            targets: ["DIOGAMAdapter"]
        ),
        .library(
            name: "GAM-DIO-Adapter-WithoutFBAudienceNetwork",
            type: .static,
            targets: ["DIOGAMAdapterNoFAN"]
        ),
        .library(
            name: "AppLovin-DIO-Adapter",
            type: .static,
            targets: ["DIOAppLovinAdapter"]
        ),
        .library(
            name: "IronSource-DIO-Adapter",
            type: .static,
            targets: ["DIOIronSourceAdapter"]
        ),
        .library(
            name: "TradPlus-DIO-Adapter",
            type: .static,
            targets: ["DIOTradPlusAdapter"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git",
            "12.0.0"..<"14.0.0"
        ),
        .package(
            url: "https://github.com/displayio/DIOSDK.git",
            from: "4.7.1"
        ),
        .package(
            url: "https://github.com/AppLovin/AppLovin-MAX-Swift-Package.git",
            "12.0.0"..<"14.0.0"
        ),
        .package(
            url: "https://github.com/ironsource-mobile/Unity-Mediation-iAds-Swift-Package",
            from: "9.0.0"
        ),
        .package(
            url: "https://github.com/tradplus/TradPlusAdSDK-SPM.git",
            from: "15.12.1"
        )
    ],
    targets: [
        .target(
            name: "DIOGAMAdapter",
            dependencies: [
                .product(
                    name: "GoogleMobileAds",
                    package: "swift-package-manager-google-mobile-ads"
                ),
                .product(
                    name: "DIOSDK",
                    package: "DIOSDK"
                )
            ],
            path: "GAM",
            publicHeadersPath: "."
        ),
        .target(
            name: "DIOGAMAdapterNoFAN",
            dependencies: [
                .product(
                    name: "GoogleMobileAds",
                    package: "swift-package-manager-google-mobile-ads"
                ),
                .product(
                    name: "DIOSDK-WithoutFBAudienceNetwork",
                    package: "DIOSDK"
                )
            ],
            path: "GAM-NOFAN",
            publicHeadersPath: "."
        ),
        .target(
            name: "DIOAppLovinAdapter",
            dependencies: [
                .product(
                    name: "AppLovinSDK",
                    package: "AppLovin-MAX-Swift-Package"
                ),
                .product(
                    name: "DIOSDK",
                    package: "DIOSDK"
                )
            ],
            path: "AppLovin",
            publicHeadersPath: "."
        ),
        .target(
            name: "DIOIronSourceAdapter",
            dependencies: [
                .product(
                    name: "UnityMediationSDK",
                    package: "Unity-Mediation-iAds-Swift-Package"
                ),
                .product(
                    name: "DIOSDK",
                    package: "DIOSDK"
                )
            ],
            path: "IronSource",
            publicHeadersPath: "."
        ),
        .target(
            name: "DIOTradPlusAdapter",
            dependencies: [
                .product(
                    name: "TradPlusAdSDK",
                    package: "TradPlusAdSDK-SPM"
                ),
                .product(
                    name: "DIOSDK",
                    package: "DIOSDK"
                )
            ],
            path: "TradPlus",
            publicHeadersPath: "."
        )
    ]
)
