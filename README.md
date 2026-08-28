# iOSMediationAdapters

Mediation adapters for the [display.io](https://www.display.io/) SDK.
Lets you serve DIOSDK ads through third-party mediation platforms.

---

## 📦 Available adapters

| Adapter | CocoaPods | SPM | Network SDK |
|---|---|---|---|
| Google Ad Manager | `GAM-DIO-Adapter` | `GAM-DIO-Adapter` | `Google-Mobile-Ads-SDK` >= 12.0 |
| Google Ad Manager (no FBAudienceNetwork) | — | `GAM-DIO-Adapter-WithoutFBAudienceNetwork` | `Google-Mobile-Ads-SDK` >= 12.0 |
| AppLovin MAX | `AppLovin-DIO-Adapter` | `AppLovin-DIO-Adapter` | `AppLovinSDK` >= 12.0 |
| IronSource (LevelPlay) | `IronSource-DIO-Adapter` | `IronSource-DIO-Adapter` | `IronSourceSDK` >= 9.0 |
| TopOn | `TopOn-DIO-Adapter` | — | `TPNiOS` >= 6.0, `TPNMediationAdxSmartdigimktAdapter` >= 6.0 |
| TradPlus | `TradPlus-DIO-Adapter` | `TradPlus-DIO-Adapter` | `TradPlusAdSDK` >= 15.12.1 |

All adapters require **`DIOSDK` >= 4.7.1**, except **TradPlus** which requires **`DIOSDK` >= 4.8.0** (iOS 15+).

---

## 🚀 Installation

### 🔹 CocoaPods

Add the adapter(s) you need to your `Podfile`:

```ruby
pod 'GAM-DIO-Adapter'
pod 'AppLovin-DIO-Adapter'
pod 'IronSource-DIO-Adapter'
pod 'TopOn-DIO-Adapter'
pod 'TradPlus-DIO-Adapter'
```

`DIOSDK` and the network SDK are pulled in automatically.

### 🔹 Swift Package Manager

1. In Xcode: **File > Add Packages...**
2. Enter URL:

   ```
   https://github.com/displayio/iOSMediationAdapters
   ```

3. Pick a version (e.g. `4.7.1`).
4. Select the products you need:
   - `GAM-DIO-Adapter`
   - `GAM-DIO-Adapter-WithoutFBAudienceNetwork` (variant without FBAudienceNetwork)
   - `AppLovin-DIO-Adapter`
   - `IronSource-DIO-Adapter`
   - `TradPlus-DIO-Adapter`

> ⚠️ `TopOn-DIO-Adapter` is **CocoaPods-only** — TPN's SDK doesn't ship a Swift Package.

---

## 📋 Requirements

- iOS 13.0+ (iOS 15.0+ for the TradPlus adapter / any adapter used via SPM with DIOSDK 4.8.0)
- Swift 5.9 or higher
- Xcode 15+

---

## 🧑‍💻 Maintainers

📧 billing@display.io

---

## 📄 License

See [LICENSE](LICENSE)
