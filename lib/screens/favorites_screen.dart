import 'package:flutter/material.dart';

import '../models/location_model.dart';

class FavoritesScreen extends StatelessWidget {
  final List<LocationModel> favoriteCities;
  final Function(LocationModel) onCitySelected;
  final Function(LocationModel) onRemove;

  const FavoritesScreen({
    super.key,
    required this.favoriteCities,
    required this.onCitySelected,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F8FF),
      appBar: AppBar(
        title: const Text(
          'Favorite Cities',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF2F8FF),
      ),
      body: favoriteCities.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 65,
                    color: Color(0xFF3198E8),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'No favorite cities yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Add cities to your favorites from the weather screen.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteCities.length,
              itemBuilder: (context, index) {
                final city = favoriteCities[index];

                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE3F2FD),
                      child: Icon(
                        Icons.location_city,
                        color: Color(0xFF3198E8),
                      ),
                    ),
                    title: Text(
                      city.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(city.country),
                    onTap: () => onCitySelected(city),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      tooltip: 'Remove from favorites',
                      onPressed: () => onRemove(city),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
