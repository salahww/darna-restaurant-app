import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:darna/core/theme/app_theme.dart';

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Location> _locations = [];
  List<Placemark> _placemarks = [];
  bool _isLoading = false;
  Timer? _debounce;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.isEmpty) {
      setState(() {
        _locations = [];
        _placemarks = [];
        _error = null;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 600), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Note: locationFromAddress returns generic Locations (lat/lng)
      // It doesn't give street names directly unless we reverse geocode them back, 
      // or use a different API. Geocoding package is limited here.
      // We will try to show Coordinates as a fallback or reverse geocode the first few.
      final locations = await locationFromAddress(query);
      
      // For better UX, let's reverse geocode the top 3 to get names? 
      // That might be too many API calls (Quota risk).
      // Strategy: Show the "Query" as the title, and coordinates/country as subtitle
      // Since 'locationFromAddress' doesn't return the formatted address string.
      
      setState(() {
        _locations = locations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
         // Don't show technical error, just no results
         _locations = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: AppShadows.elevation1,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Enter street, building num...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: theme.colorScheme.surfaceContainerHighest,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        isDense: true,
                        prefixIcon: Icon(Icons.search, size: 20, color: theme.colorScheme.onSurfaceVariant),
                         suffixIcon: _searchController.text.isNotEmpty 
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
            
            if (_isLoading)
              const LinearProgressIndicator(color: AppColors.richGold),
              
            // Results List
            Expanded(
              child: _locations.isEmpty 
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _locations.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final loc = _locations[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.location_on, color: AppColors.deepTeal, size: 20),
                          ),
                          title: Text(
                            _searchController.text, // approximate match name
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Lat: ${loc.latitude.toStringAsFixed(4)}, Lng: ${loc.longitude.toStringAsFixed(4)}'),
                          onTap: () {
                             Navigator.pop(context, loc);
                          },
                        );
                      },
                    ),
            ),
            
             // Powered by Google (Mock aesthetics)
             Padding(
               padding: const EdgeInsets.all(16.0),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Text('Powered by Google', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                 ],
               ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_searchController.text.isEmpty) return const SizedBox();
    return Center(
      child: Text(
        'No results found',
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }
}
