
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

class WeatherService {
  static const String _geocodingUrl =
      'https://geocoding-api.open-meteo.com/v1/search';

  static const String _weatherUrl =
      'https://api.open-meteo.com/v1/forecast';

  Future<LocationModel> searchCity(String city) async {
    final url = Uri.parse(_geocodingUrl).replace(
      queryParameters: {
        'name': city,
        'count': '1',
        'language': 'en',
        'format': 'json',
      },
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Unable to search for this city.');
    }

    final data = jsonDecode(response.body);

    if (data['results'] == null || data['results'].isEmpty) {
      throw Exception('City not found. Please try another name.');
    }

    return LocationModel.fromJson(data['results'][0]);
  }

  Future<Map<String, dynamic>> getWeather(
    LocationModel location,
  ) async {
    final url = Uri.parse(_weatherUrl).replace(
      queryParameters: {
        'latitude': location.latitude.toString(),
        'longitude': location.longitude.toString(),
        'current':
            'temperature_2m,apparent_temperature,weather_code,wind_speed_10m',
        'daily':
            'weather_code,temperature_2m_max,temperature_2m_min',
        'timezone': 'auto',
        'forecast_days': '7',
      },
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Unable to load weather information.');
    }

    final data = jsonDecode(response.body);

    final currentWeather = WeatherModel.fromJson(data['current']);

    final dailyData = data['daily'] as Map<String, dynamic>;

    final forecast = List.generate(
      (dailyData['time'] as List).length,
      (index) => ForecastModel.fromJson(dailyData, index),
    );

    return {
      'current': currentWeather,
      'forecast': forecast,
    };
  }
}
