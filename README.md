# SkyCast — Weather & Forecast Mobile Application

## Project Overview

SkyCast is a Flutter-based weather application that provides users with current weather information and a 7-day forecast for searched cities. It uses the Open-Meteo API to retrieve real-time weather data and provides offline access to the last successfully saved forecast.

## Features

- Search for cities and view their weather information.
- Display current temperature and feels-like temperature.
- Show wind speed and weather conditions.
- View a 7-day weather forecast.
- Add and remove favorite cities.
- Save favorite cities locally.
- Cache the latest successful weather forecast.
- Display previously cached weather when the internet is unavailable.
- Show the last-updated timestamp for offline weather data.
- Handle invalid city searches, network errors, and request timeouts.

## Technologies Used

- **Programming Language:** Dart
- **Framework:** Flutter
- **IDE:** Visual Studio Code
- **Weather API:** Open-Meteo API
- **Geocoding API:** Open-Meteo Geocoding API
- **HTTP Package:** http
- **Local Storage:** SharedPreferences
- **Version Control:** Git and GitHub

## API Attribution

Weather information is provided by [Open-Meteo](https://open-meteo.com/).

City search and geographic coordinates are retrieved through the Open-Meteo Geocoding API.

## Project Setup

### Prerequisites

- Flutter SDK
- Dart SDK
- Visual Studio Code
- Internet connection for live weather data

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/AnooshaAnwar/SkyCast.git
   ```

2. Open the project folder:

   ```bash
   cd SkyCast
   ```

3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Run the application in Chrome:

   ```bash
   flutter run -d chrome
   ```

## Offline Functionality

SkyCast uses SharedPreferences to store the latest successfully retrieved weather forecast locally.

When a network or connection error occurs, the application attempts to display the previously saved forecast and its last-updated timestamp.

Offline weather information represents previously retrieved data and may not reflect current weather conditions.

## Project Structure

```text
lib/
├── models/
│   ├── location_model.dart
│   ├── weather_model.dart
│   └── forecast_model.dart
├── screens/
│   └── favorites_screen.dart
├── services/
│   ├── weather_service.dart
│   └── local_storage_service.dart
└── main.dart
```

## Learning Outcomes

Through this project, I learned:

- How to integrate REST APIs into Flutter applications.
- How to handle asynchronous operations using async and await.
- How to decode JSON responses into Dart models.
- How to manage loading, success, and error states.
- How to implement local data persistence.
- How to cache weather information for offline access.
- How to organize application code using models, services, and screens.

## Limitations

- Live weather updates require an internet connection.
- Offline mode displays the last successfully cached forecast.
- The application currently uses Celsius for temperature.
- The application currently caches one latest successful forecast.

## Repository

[GitHub — SkyCast](https://github.com/AnooshaAnwar/SkyCast)

---

**Project:** SkyCast — Weather & Forecast Mobile Application  
**Domain:** Mobile App Development  
**Framework:** Flutter
