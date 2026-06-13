# More Fish - Smart Farming Solution

**More Fish** is a comprehensive Flutter-based mobile application designed to revolutionize modern farming. Developed by **DMA Technologies**, it provides a one-stop solution for managing Fish, Poultry, and Cattle farming through IoT integration, automation, and data-driven insights.

## 🚀 Key Features

### 🐟 Fish Farming (Aquaculture)
- **Pond Management:** Track and manage multiple ponds, water quality, and stock.
- **Water Quality Monitoring:** Real-time data from IoT devices (NH3, TDS, Salinity, pH).
- **High-Density Fish Farming:** Specialized tools for intensive aquaculture systems.
- **Fish Disease Detector & Treatment:** Identify diseases and get expert treatment advice.
- **FCR Calculator:** Easily calculate Feed Conversion Ratio to optimize feeding.
- **Nano Bubble System:** Manage and monitor nano-bubble aeration systems.

### 🐄 Cattle & 🐔 Poultry Management
- **Live Data Monitoring:** Real-time tracking of livestock health and environment.
- **Automation Settings:** Automate feeding and environmental controls.
- **Farm Management:** Detailed records of animals, growth, and health.

### ⚙️ IoT & Automation
- **Device Connections:** Seamlessly connect with Aerators, Feeders, and Water Quality devices.
- **Automation:** Set rules and thresholds for automated farm operations.

### 🛠 Other Utilities
- **Weather Forecast:** Stay updated with local weather conditions.
- **Product Store:** Browse and buy farming products from various companies.
- **Training & Workshops:** Access educational resources and upcoming events.
- **Social Features:** Connect with other farmers and experts.
- **Clean Air Monitoring:** Monitor air quality in and around the farm.

## 🛠 Tech Stack

- **Framework:** [Flutter](https://flutter.dev/)
- **State Management:** [GetX](https://pub.dev/packages/get)
- **Backend Services:** [Firebase](https://firebase.google.com/) (Auth, Firestore, Storage, Cloud Messaging)
- **Local Storage:** [Shared Preferences](https://pub.dev/packages/shared_preferences)
- **HTTP Requests:** [http](https://pub.dev/packages/http)
- **Data Visualization:** [fl_chart](https://pub.dev/packages/fl_chart)
- **Functional Programming:** [dartz](https://pub.dev/packages/dartz)
- **Internationalization:** [intl](https://pub.dev/packages/intl)

## 📁 Project Structure

The project follows a modular GetX architecture:

```text
lib/
├── app/
│   ├── common_widgets/   # Reusable UI components
│   ├── modules/          # Feature-based modules (View, Controller, Binding)
│   ├── repo/             # Data repositories
│   ├── response/         # API response models
│   ├── routes/           # App routing configuration
│   ├── service/          # App services (FCM, Local Storage, etc.)
│   ├── translations/     # Localization files
│   └── app_translations.dart
├── main.dart             # Entry point
└── firebase_options.dart  # Firebase configuration
```

## 🚀 Getting Started

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-repo/more_fish.git
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Run the app:**
    ```bash
    flutter run
    ```

---

## 👨‍💻 Developer Information

### **MD. ABDUL HAMIM LEON**
**Flutter & AI Developer | Automation Systems | Django Backend Engineer**
- 🌍 **Website:** [thedevhamim.vercel.app](https://thedevhamim.vercel.app)
- 🎓 **Education:** Daffodil International University
- 💼 **LinkedIn:** [in/abdul-hamim-a35b02253](https://www.linkedin.com/in/abdul-hamim-a35b02253)
- 🐦 **Twitter:** [@hamim_leon](https://twitter.com/hamim_leon)
- 📸 **Instagram:** [hamimleon](https://www.instagram.com/hamimleon)
- 📘 **Facebook:** [hamim.leon](https://www.facebook.com/hamim.leon)
- 🐙 **GitHub:** [hamim5264](https://github.com/hamim5264)

### **Izaz Ahmed (ahizaz)**
**Flutter Developer**
- ✉️ **Email:** izaz3531ahmed@gmail.com
- 💼 **LinkedIn:** [in/izaz-ahmed-62601132b](https://www.linkedin.com/in/izaz-ahmed-62601132b)

---
Developed with ❤️ by **DMA Technologies**
