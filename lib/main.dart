import 'package:flutter/material.dart';

import 'models/location_model.dart';
import 'models/weather_model.dart';
import 'models/forecast_model.dart';
import 'services/weather_service.dart';
import 'services/local_storage_service.dart';
import 'screens/favorites_screen.dart';

void main() {
  runApp(const SkyCastApp());
}

class SkyCastApp extends StatelessWidget {
  const SkyCastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SkyCast',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3198E8),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF2F8FF),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  final LocalStorageService _storageService = LocalStorageService();
  final TextEditingController _searchController = TextEditingController();

  LocationModel? _location;
  WeatherModel? _currentWeather;
  List<ForecastModel> _forecast = [];
  List<LocationModel> _favoriteCities = [];

  bool _isLoading = false;
  bool _isShowingCache = false;

  DateTime? _cachedAt;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _searchCity('Peshawar');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final cities = await _storageService.getFavoriteCities();

    if (!mounted) return;

    setState(() {
      _favoriteCities = cities;
    });
  }

  Future<void> _toggleFavorite() async {
    if (_location == null) return;

    final exists = _favoriteCities.any(
      (city) =>
          city.name.toLowerCase() == _location!.name.toLowerCase() &&
          city.country.toLowerCase() == _location!.country.toLowerCase(),
    );

    if (exists) {
      await _storageService.removeFavoriteCity(_location!);
    } else {
      await _storageService.addFavoriteCity(_location!);
    }

    await _loadFavorites();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(exists ? 'Removed from favorites' : 'Added to favorites'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openFavorites() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoritesScreen(
          favoriteCities: _favoriteCities,
          onCitySelected: (city) {
            Navigator.pop(context);
            _searchCity(city.name);
          },
          onRemove: (city) async {
            await _storageService.removeFavoriteCity(city);
            await _loadFavorites();
          },
        ),
      ),
    );

    await _loadFavorites();
  }

  bool _isConnectivityError(Object error) {
    final message = error.toString().toLowerCase();

    // Invalid city names should show their own error,
    // rather than loading an unrelated cached city.
    if (message.contains('city not found') ||
        message.contains('please enter a city')) {
      return false;
    }

    return message.contains('network') ||
        message.contains('timeout') ||
        message.contains('connection') ||
        message.contains('socket') ||
        message.contains('host lookup') ||
        message.contains('unable to search') ||
        message.contains('unable to load') ||
        message.contains('failed host');
  }

  Future<void> _searchCity(String city) async {
    if (city.trim().isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final location = await _weatherService.searchCity(city.trim());
      final weatherData = await _weatherService.getWeather(location);

      final current = weatherData['current'] as WeatherModel;
      final forecast = weatherData['forecast'] as List<ForecastModel>;

      // Save the latest successful weather data locally.
      await _storageService.saveWeatherCache(
        location: location,
        current: current,
        forecast: forecast,
      );

      if (!mounted) return;

      setState(() {
        _location = location;
        _currentWeather = current;
        _forecast = forecast;
        _cachedAt = DateTime.now();
        _isShowingCache = false;
        _isLoading = false;
        _errorMessage = null;
      });

      _searchController.clear();
    } catch (error) {
      if (!mounted) return;

      // If the request failed because of connectivity,
      // try to load the last successfully saved forecast.
      if (_isConnectivityError(error)) {
        try {
          final cachedData = await _storageService.getWeatherCache();

          if (!mounted) return;

          if (cachedData != null) {
            setState(() {
              _location = cachedData['location'] as LocationModel;
              _currentWeather = cachedData['current'] as WeatherModel;
              _forecast = cachedData['forecast'] as List<ForecastModel>;
              _cachedAt = cachedData['cachedAt'] as DateTime;
              _isShowingCache = true;
              _isLoading = false;
              _errorMessage = null;
            });

            return;
          }
        } catch (_) {
          // Show the original request error if cache loading fails.
        }
      }

      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  String _formatLastUpdated(DateTime dateTime) {
    final date = dateTime.toLocal();

    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '${date.day}/${date.month}/${date.year} at $hour:$minute $period';
  }

  String _weatherDescription(int code) {
    if (code == 0) return 'Clear sky';
    if (code == 1) return 'Mainly clear';
    if (code == 2) return 'Partly cloudy';
    if (code == 3) return 'Overcast';
    if (code == 45 || code == 48) return 'Foggy';
    if (code >= 51 && code <= 57) return 'Drizzle';
    if (code >= 61 && code <= 67) return 'Rain';
    if (code >= 71 && code <= 77) return 'Snow';
    if (code >= 80 && code <= 82) return 'Rain showers';
    if (code >= 85 && code <= 86) return 'Snow showers';
    if (code >= 95) return 'Thunderstorm';
    return 'Weather conditions';
  }

  IconData _weatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny_rounded;
    if (code <= 2) return Icons.wb_cloudy_rounded;
    if (code == 3) return Icons.cloud_rounded;
    if (code == 45 || code == 48) return Icons.foggy;
    if (code >= 51 && code <= 67) return Icons.grain;
    if (code >= 71 && code <= 86) return Icons.ac_unit;
    if (code >= 95) return Icons.thunderstorm;
    return Icons.cloud;
  }

  String _dayName(String date) {
    final parsedDate = DateTime.tryParse(date);
    if (parsedDate == null) return date;

    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return days[parsedDate.weekday - 1];
  }

  bool get _isFavorite {
    if (_location == null) return false;

    return _favoriteCities.any(
      (city) =>
          city.name.toLowerCase() == _location!.name.toLowerCase() &&
          city.country.toLowerCase() == _location!.country.toLowerCase(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F8FF),
        titleSpacing: 16,
        title: const Row(
          children: [
            Icon(Icons.cloud, color: Color(0xFF3198E8)),
            SizedBox(width: 8),
            Text(
              'SkyCast',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF226CA8),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _openFavorites,
            tooltip: 'Favorite cities',
            icon: const Icon(Icons.favorite, color: Colors.red),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Weather Forecast',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your daily weather companion',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: _searchCity,
                decoration: InputDecoration(
                  hintText: 'Search city...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () => _searchCity(_searchController.text),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: CircularProgressIndicator(),
                  ),
                ),

              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade800),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: () =>
                            _searchCity(_location?.name ?? 'Peshawar'),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try again'),
                      ),
                    ],
                  ),
                ),

              if (!_isLoading && _currentWeather != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF55B4F5), Color(0xFF267AC7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              '${_location!.name}, ${_location!.country}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 21,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _toggleFavorite,
                            icon: Icon(
                              _isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.white,
                            ),
                            tooltip: 'Toggle favorite',
                          ),
                        ],
                      ),

                      // Offline cache indicator.
                      if (_isShowingCache) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'OFFLINE — CACHED DATA',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        if (_cachedAt != null)
                          Text(
                            'Last updated: ${_formatLastUpdated(_cachedAt!)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                      ],

                      const SizedBox(height: 15),
                      Icon(
                        _weatherIcon(_currentWeather!.weatherCode),
                        size: 75,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${_currentWeather!.temperature.round()}°C',
                        style: const TextStyle(
                          fontSize: 55,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _weatherDescription(_currentWeather!.weatherCode),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          WeatherDetail(
                            icon: Icons.thermostat,
                            label: 'Feels Like',
                            value: '${_currentWeather!.feelsLike.round()}°C',
                          ),
                          WeatherDetail(
                            icon: Icons.air,
                            label: 'Wind',
                            value: '${_currentWeather!.windSpeed.round()} km/h',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  '7-Day Forecast',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: _forecast.map((day) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                _dayName(day.date),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(
                              _weatherIcon(day.weatherCode),
                              color: const Color(0xFF3198E8),
                              size: 25,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: Text(
                                _weatherDescription(day.weatherCode),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Text(
                              '${day.maxTemperature.round()}° / ${day.minTemperature.round()}°',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  'Favorite Cities',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _favoriteCities.isEmpty
                      ? const Text(
                          'No favorite cities yet. Tap the heart to add one.',
                          style: TextStyle(color: Colors.grey),
                        )
                      : Column(
                          children: _favoriteCities.map((city) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
                                Icons.location_city,
                                color: Color(0xFF3198E8),
                              ),
                              title: Text(city.name),
                              subtitle: Text(city.country),
                              onTap: () => _searchCity(city.name),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class WeatherDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const WeatherDetail({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 25),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
