// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "iOSMediationAdapters",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
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
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git",
            "12.0.0"..<"14.0.0"
        ),
        .package(
            url: "https://github.com/displayio/DIOSDK.git",
            from: "4.5.5"
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
        )
    ]
)
