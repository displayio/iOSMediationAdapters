# GAM-DIO-Adapter

Google Ad Manager mediation adapter for [display.io](https://www.display.io/) SDK.  
Enables using DIOSDK through Google Mobile Ads mediation.

---

## 🚀 Installation

### 🔹 Swift Package Manager

You can add `GAM-DIO-Adapter` to your Xcode project using **Swift Package Manager**:

1. Open your project in Xcode  
2. Go to **File > Add Packages...**  
3. Enter the repository URL:

   ```
   https://github.com/displayio/iOSMediationAdapters
   ```

4. Choose the version you want to integrate.  
5. Select the **GAM-DIO-Adapter** product only (unless you also need other adapters in this repo).

> 💡 This package depends on `DIOSDK` and `GoogleMobileAds` and will fetch them automatically via SPM.

---

## 📦 Requirements

- iOS 12.0+
- Swift 5.9 or higher
- Xcode 15+
- `GoogleMobileAds` SDK 12.0.0 or higher

---

## 📘 Example Usage

```swift
import GoogleMobileAds
import DIOSDK

// Use your GADCustomEvent logic from DIOCustomEvent
```

---

## 🛠 Internals

This Swift package contains only source files for the mediation adapter:

- `DIOCustomEvent.h`
- `DIOCustomEvent.m`

It links against:
- [`DIOSDK`](https://github.com/displayio/DIOSDK)
- [`GoogleMobileAds`](https://github.com/googleads/swift-package-manager-google-mobile-ads)

---

## 🧑‍💻 Maintainers

For support, please contact:  
📧 billing@display.io

---

## 📄 License

See [LICENSE](LICENSE)
