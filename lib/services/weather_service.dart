import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

class WeatherService {
  static const String _geocodingUrl =
      'https://geocoding-api.open-meteo.com/v1/search';

  static const String _weatherUrl = 'https://api.open-meteo.com/v1/forecast';

  static const Duration _requestTimeout = Duration(seconds: 15);

  Future<LocationModel> searchCity(String city) async {
    if (city.trim().isEmpty) {
      throw Exception('Please enter a city name.');
    }

    try {
      final url = Uri.parse(_geocodingUrl).replace(
        queryParameters: {
          'name': city.trim(),
          'count': '1',
          'language': 'en',
          'format': 'json',
        },
      );

      final response = await http.get(url).timeout(_requestTimeout);

      if (response.statusCode != 200) {
        throw Exception('Unable to search for this city.');
      }

      final data = jsonDecode(response.body);

      if (data['results'] == null || (data['results'] as List).isEmpty) {
        throw Exception('City not found. Please try another name.');
      }

      return LocationModel.fromJson(data['results'][0]);
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } on http.ClientException {
      throw Exception('Network error. Please check your connection.');
    } on FormatException {
      throw Exception('Invalid response received from the server.');
    }
  }

  Future<Map<String, dynamic>> getWeather(LocationModel location) async {
    try {
      final url = Uri.parse(_weatherUrl).replace(
        queryParameters: {
          'latitude': location.latitude.toString(),
          'longitude': location.longitude.toString(),
          'current':
              'temperature_2m,apparent_temperature,weather_code,wind_speed_10m',
          'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
          'timezone': 'auto',
          'forecast_days': '7',
        },
      );

      final response = await http.get(url).timeout(_requestTimeout);

      if (response.statusCode != 200) {
        throw Exception('Unable to load weather information.');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data['current'] == null || data['daily'] == null) {
        throw Exception('Weather information is incomplete.');
      }

      final currentWeather = WeatherModel.fromJson(
        data['current'] as Map<String, dynamic>,
      );

      final dailyData = data['daily'] as Map<String, dynamic>;

      final dates = dailyData['time'] as List;
      final codes = dailyData['weather_code'] as List;
      final maximums = dailyData['temperature_2m_max'] as List;
      final minimums = dailyData['temperature_2m_min'] as List;

      final availableDays = [
        dates.length,
        codes.length,
        maximums.length,
        minimums.length,
      ].reduce((a, b) => a < b ? a : b);

      if (availableDays < 7) {
        throw Exception(
          'The weather service returned fewer than seven forecast days.',
        );
      }

      final forecast = List.generate(
        7,
        (index) => ForecastModel.fromJson(dailyData, index),
      );

      return {'current': currentWeather, 'forecast': forecast};
    } on TimeoutException {
      throw Exception('Weather request timed out. Please try again.');
    } on http.ClientException {
      throw Exception('Network error. Please check your connection.');
    } on FormatException {
      throw Exception('Invalid weather data received.');
    }
  }
}
