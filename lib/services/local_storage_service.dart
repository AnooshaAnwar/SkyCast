import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

class LocalStorageService {
  static const String _favoritesKey = 'favorite_cities';
  static const String _weatherCacheKey = 'weather_cache';

  // Get saved favorite cities
  Future<List<LocationModel>> getFavoriteCities() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCities = prefs.getStringList(_favoritesKey) ?? [];

    return savedCities.map((city) {
      return LocationModel.fromJson(jsonDecode(city) as Map<String, dynamic>);
    }).toList();
  }

  // Add a city to favorites
  Future<void> addFavoriteCity(LocationModel city) async {
    final cities = await getFavoriteCities();

    final alreadyExists = cities.any(
      (item) =>
          item.name.toLowerCase() == city.name.toLowerCase() &&
          item.country.toLowerCase() == city.country.toLowerCase(),
    );

    if (alreadyExists) return;

    cities.add(city);
    await _saveFavoriteCities(cities);
  }

  // Remove a city from favorites
  Future<void> removeFavoriteCity(LocationModel city) async {
    final cities = await getFavoriteCities();

    cities.removeWhere(
      (item) =>
          item.name.toLowerCase() == city.name.toLowerCase() &&
          item.country.toLowerCase() == city.country.toLowerCase(),
    );

    await _saveFavoriteCities(cities);
  }

  Future<void> _saveFavoriteCities(List<LocationModel> cities) async {
    final prefs = await SharedPreferences.getInstance();

    final savedCities = cities.map((city) {
      return jsonEncode({
        'name': city.name,
        'country': city.country,
        'latitude': city.latitude,
        'longitude': city.longitude,
        'timezone': city.timezone,
      });
    }).toList();

    await prefs.setStringList(_favoritesKey, savedCities);
  }

  // Save the latest successful weather data
  Future<void> saveWeatherCache({
    required LocationModel location,
    required WeatherModel current,
    required List<ForecastModel> forecast,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final cache = {
      'location': {
        'name': location.name,
        'country': location.country,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'timezone': location.timezone,
      },
      'current': {
        'temperature_2m': current.temperature,
        'apparent_temperature': current.feelsLike,
        'weather_code': current.weatherCode,
        'wind_speed_10m': current.windSpeed,
        'time': current.observationTime,
      },
      'daily': {
        'time': forecast.map((day) => day.date).toList(),
        'weather_code': forecast.map((day) => day.weatherCode).toList(),
        'temperature_2m_max': forecast
            .map((day) => day.maxTemperature)
            .toList(),
        'temperature_2m_min': forecast
            .map((day) => day.minTemperature)
            .toList(),
      },
      'cached_at': DateTime.now().toIso8601String(),
    };

    await prefs.setString(_weatherCacheKey, jsonEncode(cache));
  }

  // Read the cached weather data
  Future<Map<String, dynamic>?> getWeatherCache() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCache = prefs.getString(_weatherCacheKey);

    if (savedCache == null) return null;

    final cache = jsonDecode(savedCache) as Map<String, dynamic>;

    final location = LocationModel.fromJson(
      cache['location'] as Map<String, dynamic>,
    );

    final current = WeatherModel.fromJson(
      cache['current'] as Map<String, dynamic>,
    );

    final daily = cache['daily'] as Map<String, dynamic>;

    final forecast = List.generate(
      (daily['time'] as List).length,
      (index) => ForecastModel.fromJson(daily, index),
    );

    return {
      'location': location,
      'current': current,
      'forecast': forecast,
      'cachedAt': DateTime.parse(cache['cached_at'] as String),
    };
  }
}
