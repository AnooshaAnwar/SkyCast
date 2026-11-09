import 'package:flutter/material.dart';

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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
            Flexible(
              child: Text(
                'SkyCast',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF226CA8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
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
                decoration: InputDecoration(
                  hintText: 'Search city...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 25),

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
                child: const Column(
                  children: [
                    Text(
                      'Peshawar, Pakistan',
                      style: TextStyle(
                        fontSize: 21,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 15),

                    Icon(Icons.wb_sunny_rounded, size: 75, color: Colors.white),

                    SizedBox(height: 10),

                    Text(
                      '--°C',
                      style: TextStyle(
                        fontSize: 55,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      'Weather data coming soon',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),

                    SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        WeatherDetail(
                          icon: Icons.water_drop,
                          label: 'Humidity',
                          value: '--%',
                        ),
                        WeatherDetail(
                          icon: Icons.air,
                          label: 'Wind',
                          value: '-- km/h',
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
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 40,
                      color: Color(0xFF3198E8),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Forecast will appear here',
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  ],
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
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.favorite_border, color: Color(0xFF3198E8)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your favorite cities will appear here',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            label: 'Favorites',
          ),
        ],
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
