# More Fish - API Documentation

This document provides a comprehensive guide to the API implementation for the **More Fish** mobile application. This documentation is designed to assist in the development of a corresponding web application.

---

## 1. General Information
- **Base URL:** `http://66.29.151.40:8004`
- **Content-Type:** `application/json`
- **Authentication:** Bearer Token (`Authorization: Bearer <token>`)

---

## 2. Authentication API
Endpoints for user session management and profile handling.

### 2.1 Login
- **Endpoint:** `POST /auth/login/`
- **Request Body:**
  ```json
  {
    "usr_email": "user@example.com",
    "password": "yourpassword"
  }
  ```
- **Response:** Returns `LoginResponse` containing tokens (`access`, `refresh`) and user details.

### 2.2 Registration
- **Endpoint:** `POST /auth/registration/`
- **Request Body:** `RegistrationRequest` model (fields include name, email, phone, password, etc.).
- **Response:** `RegistrationResponse`.

### 2.3 User Profile
- **Endpoint:** `GET /auth/user/details/{userId}`
- **Headers:** Requires Authorization.
- **Response:** Detailed user profile information.

### 2.4 Password Management
- **Change Password:** `POST /auth/user/password/change/`
  - Body: `{"old_password": "...", "new_password": "..."}`
- **Forgot Password:** `POST /auth/user/forgot/password/`
  - Body: `{"phone": "...", "email": "..."}`
- **OTP Verify:** `POST /auth/user/otp/verify/`
  - Body: `{"code": "..."}`
- **Reset Password:** `POST /auth/user/reset/password/`
  - Body: `{"user_id": "...", "password": "..."}`

---

## 3. Weather Forecast API
Uses external service for real-time environmental data.

- **Provider:** OpenWeatherMap
- **API Key:** `1fe3d8310812392fbac14b02b9b3dcf1`
- **Endpoints:**
  - **Current Weather:** `https://api.openweathermap.org/data/2.5/weather?q={city},BD&appid={apiKey}&units=metric`
  - **5-Day Forecast:** `https://api.openweathermap.org/data/2.5/forecast?q={city},BD&appid={apiKey}&units=metric`
- **Locations:** Supports all major districts in Bangladesh (Dhaka, Naogaon, etc.).

---

## 4. More Fish Features

### 4.0 Header Weather & Location Logic
The application header dynamically updates weather information based on the user's authentication state.

- **Logged Out User:**
  - **Default Location:** Dhaka
  - **Data Source:** OpenWeatherMap API.
  - **Displayed Info:** Air Temp, Humidity, and Weather Description.
  - **Update Frequency:** Throttled to every 5 minutes.

- **Logged In User (More Fish/Pharma):**
  - **Logic:** The app identifies the user's first registered pond/asset from `GET /devices/data/pond/list`.
  - **Data Source:** Backend Dashboard API (`GET /devices/data/pond/data?asset_id={id}`).
  - **Displayed Info:** 
    - **Location:** The district associated with the asset (e.g., "Naogaon").
    - **Weather:** Real-time values from the `weather` node in the API response.
    - **Sunlight Level:** Displays the `sunlight_level` value (e.g., "Medium", "High", "Low") provided by backend sensors.
  - **Fallback:** If no asset exists or backend weather data is missing, the app falls back to OpenWeatherMap (Dhaka).

### 4.1 Pond & Asset Management
- **Pond List:** `GET /devices/data/pond/list`
  - Returns list of ponds associated with the user.
- **Pond Data:** `GET /devices/data/pond/data?asset_id={asset_id}`
  - Fetches real-time sensor data for a specific pond (Temp, DO, pH, NH3, TDS, Salinity).

### 4.2 Sensor & Graph Data
- **Sensor List:** `GET /devices/sensor/list?device_id={device_id}`
- **Graph Data:** `GET /devices/data/graph`
  - **Query Params:**
    - `assst_id`: The ID of the pond/asset.
    - `sensor_id`: The ID of the specific sensor (1: pH, 2: Temp, 3: DO, 4: TDS, 5: NH3, 6: Salinity).
    - `type`: Data range (`daily`, `weekly`, `monthly`).
  - **Response Logic:**
    - Returns an array of `sensor_val` (numeric data points) and `time` (labels for the X-axis).
    - Used for historical data visualization on charts.

### 4.3 Hardware Automation (Aerators)
- **Send Command:** `POST /devices/aerators/command/`
  - Body: `{"aerator_id": "...", "command": "ON/OFF"}`
- **Automation Settings (GET):** `GET /devices/aerator-automation/?device_id={deviceId}`
- **Automation Settings (POST):** `POST /devices/aerator-automation/?device_id={deviceId}`
  - Body: `{"device_id": "...", "is_enabled": true, "do_min": 4.0, "do_max": 8.0}`
- **Cleaner Status:** `GET /devices/cleaner/status/?asset_id={assetId}`

### 4.4 Fish Disease Detector
- **Detect Disease:** `POST /devices/fish-disease/detect/`
- **Method:** Multipart POST
- **Field:** `file` (Image file)
- **Response:** Returns `disease` name and `confidence_percent`.

### 4.5 FCR Calculator
- **Calculate:** `POST /devices/fcr/calculate/`
- **Body:**
  ```json
  {
    "asset_id": 1,
    "feed_weight_kg": 1500,
    "weight_gained_kg": 1000,
    "notes": "Optional"
  }
  ```
- **Response:** Returns calculated `fcr` value.

---

## 5. Marketplace (Product & Equipment)
Endpoints for the various marketplaces (Feed, Equipment, Medicine, Fingerlings).

- **Category List:** `GET /product/category/list/`
- **Companies by Category:** `GET /product/product-companies?category_guid={guid}`
- **Products by Company:** `GET /product/search-product-by-company?page_number=1&size=30&product_company_guid={guid}`
- **Product Details:** `GET /product/details?product_guid={guid}`

---

## 6. Notifications
- **List Notifications:** `GET /notification/all/list/{userId}/`
- **Update FCM Token:** `POST /auth/user/fcm/token/update/`
  - Body: `{"fcm_token": "..."}`

---

## 7. Static Content & Tools
The following features are implemented using local data and application logic:
- **Feed Management Guides:** (Types, Guidelines, Feeding Methods, etc.) - Localized strings.
- **Pond Management Guides:** (Preparation, Selection) - Localized strings.
- **Live Consultancy:** Integration via WhatsApp (`wa.me`) and Facebook Messenger (`m.me`).
- **Emergency Service:** Direct dialer implementation.
- **Smart Khamari:** Concept documentation and premium network details.

---

## 8. Development Notes for Web App
- Ensure CORS is handled if the backend doesn't allow browser requests.
- Use the provided `apiKey` for OpenWeatherMap integration.
- Standardize on `http://66.29.151.40:8004` as the base for all API calls.
