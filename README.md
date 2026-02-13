# 📦 Ship Link - Advanced Logistics & Delivery Solution

**Ship Link** is a professional-grade, cross-platform mobile application built with **Flutter**. It provides a seamless interface for managing shipments, integrating real-time tracking and secure financial transactions.

## 🚀 Key Flutter Features

*   **📍 Real-Time Driver Tracking:** Integrated **Google Maps API** to provide live GPS tracking. Users can visualize the driver's movement on an interactive map with custom markers and dynamic polyline routes.
*   **💳 Integrated Payment Gateway:** Secure checkout experience supporting multiple payment methods (Credit Cards, Digital Wallets) through professional API integration.
*   **🛰️ Advanced Networking:** Built with **Dio** to handle complex REST API communication with the Laravel backend, featuring custom interceptors for auth tokens.
*   **⚡ Reactive State Management:** Utilizes **BLoc/Cubit** to ensure the UI stays in sync with shipment status updates without performance lag.

## 🛠️ Tech Stack (Mobile Focused)

- **Framework:** Flutter (Dart)
- **Maps & Location:** [google_maps_flutter](https://pub.dev) & [geolocator](https://pub.dev)
- **API Client:** [dio](https://pub.dev) for optimized HTTP requests.
- **Backend:** Laravel (PHP) - Providing a secure RESTful API.

## 📸 Project Preview
| Real-Time Tracking | Secure Payment | Order Management |
| :---: | :---: | :---: |
| *[Add Image Link]* | *[Add Image Link]* | *[Add Image Link]* |

## ⚙️ Installation

1.  **Clone the repo:**
    ```bash
    git clone https://github.com
    ```
2.  **Install Flutter dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Setup Google Maps:**
    - Add your `API_KEY` to `AndroidManifest.xml` and `AppDelegate.swift`.
4.  **Run the app:**
    ```bash
    flutter run
    ```
