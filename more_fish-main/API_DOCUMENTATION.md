# DMA Technologies - Full API Documentation (Web Implementation)

This documentation provides the exact endpoint details, request payloads, and response structures for all features: More Fish, Poultry Care, Cattle Care, and Pharma Care.

---

## 1. Global Configuration
- **Base URL:** `http://66.29.151.40:8004` (Common for all features)
- **Content-Type:** `application/json`
- **Weather API Key:** `1fe3d8310812392fbac14b02b9b3dcf1` (OpenWeatherMap)

---

## 2. Authentication & Profile
Each module (More Fish, Poultry, Cattle, Pharma) manages its own session token. Ensure you use the correct token for the active module.

### 2.1 Login
- **Endpoint:** `POST /auth/login/`
- **Body:** `{ "usr_email": "...", "password": "..." }`
- **Response Keys (Crucial for UI):**
  - `data.token`: Session bearer token.
  - `data.user_id`: Numeric ID (store as `userId`, `poultryUserId`, etc.).
  - `data.user_data.first_name`, `data.user_data.last_name`: Displayed as user name.
  - `data.user_data.user_phone.phn_cell`: User's primary phone.

### 2.2 Profile Details
- **Endpoint:** `GET /auth/user/details/{userId}`
- **Response Mapping (Fix "None" values):**
  - **Email:** `data.usr_email`
  - **Phone:** `data.user_phone` (This can be an object or string; in `ProfileResponse` it is currently `dynamic`. Check both `data.user_phone.phn_cell` and `data.user_phone` as a raw string).
  - **Address:** `data.user_address`

---

## 3. More Fish Module (Main Dashboard)

### 3.1 Live Data Monitoring
- **Pond List:** `GET /devices/data/pond/list`
- **Pond Details:** `GET /devices/data/pond/data?asset_id={id}`
  - **Status:** `data.devices[0].device_status` (Online/Offline)
  - **Sensors:** `data.devices[0].sensors`
    - `sensor_name`: (e.g., "Dissolved Oxygen (DO)")
    - `last_value`: (The numeric value to display)
    - `sensor_unit`: (e.g., "mg/L")
    - `danger_status`: ("danger" or "normal")
  - **Aerators:** `data.devices[0].aerators`
    - `aerator_name`, `isRunning`, `isOnline`.

### 3.2 Automation & Controls
- **Manual Control:** `POST /devices/aerators/command/`
  - Body: `{"aerator_id": "...", "command": 1}` (1=ON, 0=OFF).
- **Automation Settings:** `GET /devices/aerator-automation/?device_id={id}`
- **Save Automation:** `POST /devices/aerator-automation/`
  - Body: `{"device_id": 123, "is_enabled": true, "do_min": 4.5, "do_max": 7.5}`
- **Cleaner Status:** `GET /devices/cleaner/status/?asset_id={id}`

### 3.3 Fish Disease Detector
- **Endpoint:** `POST /devices/fish-disease/detect/`
- **Type:** `Multipart/form-data`
- **Key:** `file` (Image blob)
- **Response:** `data.disease` (Name), `data.confidence_percent`.

### 3.4 Product Marketplace (Marketplace features)
- **Categories:** `GET /product/category/list/`
- **Companies:** `GET /product/product-companies?category_guid={guid}`
- **Products:** `GET /product/search-product-by-company?product_company_guid={guid}&page_number=1&size=30`
- **Details:** `GET /product/details?product_guid={guid}`

---

## 4. Cattle Care Module

### 4.1 Home Dashboard
- **Farm List:** `GET /cattle_care/farms/list/`
- **Farm Dashboard:** `GET /cattle_care/farms/dashboard/?farm_id={id}`
  - **Online Status:** `data.device.is_online` (bool)
  - **Sensors:** `data.device.sensors`
    - Keys: `name`, `last_value`, `unit`, `danger_status`.
  - **Switches:** `data.device.switches`
    - Keys: `switch_id`, `switch_name`, `is_on` (bool).
  - **Automation Flag:** `data.automation_enabled` (bool).

### 4.2 Automation & Light Timers
- **Toggle Switches:** `POST /cattle_care/switches/command/`
  - Body: `{"switch_id": "...", "command": 1}`
- **Automation Thresholds:** `POST /cattle_care/automation/`
  - Body: `{"farm_id": 1, "is_enabled": true, "fan_temp_min": 25, "fan_temp_max": 30, "fogger_humidity_min": 40}`
- **Light Schedules:**
  - **Add:** `POST /cattle_care/automation/light-schedule/`
    - Body: `{"farm_id": 1, "start_time": "HH:mm:ss", "end_time": "HH:mm:ss"}`
  - **Delete:** `DELETE /cattle_care/automation/light-schedule/{id}/`

---

## 5. Poultry Care Module

### 5.1 Dashboard Data
- **Farm List:** `GET /poultry_care/farms/list/`
- **Farm Dashboard:** `GET /poultry_care/farms/dashboard/?farm_id={id}`
  - **Structure:** Matches Cattle Care.
  - **Sensors:** Look for `temperature`, `humidity`, `nh3_gas`, `aqi`, `co2`, `tvoc`, `methane_ppm`, `light_intensity`.

### 5.2 Controls
- **Switch Control:** `POST /poultry_care/switches/command/`
  - Body: `{"switch_id": "...", "command": 1}`
- **Automation:** `POST /poultry_care/automation/` (Fan/Fogger/Humidity thresholds).

---

## 6. Common Mapping Issues (Troubleshooting Web)

1.  **Sensor Keys:**
    - **More Fish:** Uses `sensor_name` and `sensor_id` (string).
    - **Cattle/Poultry:** Uses `name` and `sensor_id` (int).
    - **Solution:** Ensure your sensor component can handle both `name` and `sensor_name`.

2.  **User Profile:**
    - If Email/Phone are "None", verify if you are hitting `/auth/user/details/{userId}`.
    - Check if the response `data.user_phone` is an object: `{ "phn_cell": "..." }`.

3.  **Missing Poultry Data:**
    - Verify `token` vs `poultryToken`. If you use the More Fish token for Poultry APIs, you might get an empty farm list.
    - Ensure you are hitting `/poultry_care/farms/list/` (NOT just `/devices/data/pond/list`).

4.  **Metric Cards (Cattle/Poultry):**
    - Map icons based on sensor names:
      - `temperature` -> thermometer icon
      - `humidity` -> water drop icon
      - `nh3_gas` -> ammonia/gas icon

5.  **Offline State:**
    - If `is_online` is false, grey out controls and show `--` for sensors if the backend doesn't provide the last known values.
