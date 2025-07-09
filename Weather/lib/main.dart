import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: const WeatherScreen(),
    );
  }
}

class WeatherData {
  final String city;
  final double temperature;
  final String condition;
  final int humidity;

  WeatherData({
    required this.city,
    required this.temperature,
    required this.condition,
    required this.humidity,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json, String city) {
    final weatherCode = json['current']['weather_code'];
    return WeatherData(
      city: city,
      temperature: json['current']['temperature_2m'] as double,
      condition: _mapWeatherCodeToCondition(weatherCode),
      humidity: json['current']['relative_humidity_2m'] as int,
    );
  }

  static String _mapWeatherCodeToCondition(int code) {
    // Simplified WMO weather code mapping
    // See https://open-meteo.com/en/docs for full list
    if (code == 0) return 'Clear';
    if (code >= 1 && code <= 3) return 'Cloudy';
    if (code >= 51 && code <= 67) return 'Rain';
    if (code >= 71 && code <= 77) return 'Snow';
    return 'Unknown';
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _controller = TextEditingController();
  WeatherData? _weatherData;
  bool _isLoading = false;
  String? _errorMessage;

  // Simple city-to-coordinates mapping for testing
  final Map<String, Map<String, double>> _cityCoordinates = {
    'lahore': {'lat': 31.5204, 'lon': 74.3587},
    'karachi': {'lat': 24.8607, 'lon': 67.0011},
    'islamabad': {'lat': 33.6844, 'lon': 73.0479},
    'tokyo': {'lat': 35.6762, 'lon': 139.6503},
    'london': {'lat': 51.5074, 'lon': -0.1278},
  };

  Future<void> _fetchWeather(String city) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Convert city to lowercase for case-insensitive matching
    final cityLower = city.toLowerCase();
    if (!_cityCoordinates.containsKey(cityLower)) {
      setState(() {
        _errorMessage = 'City not found. Try Lahore, Karachi, Islamabad, Tokyo, or London.';
        _isLoading = false;
      });
      return;
    }

    final coords = _cityCoordinates[cityLower]!;
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=${coords['lat']}&longitude=${coords['lon']}&current=temperature_2m,relative_humidity_2m,weather_code',
    );

    try {
      final response = await http.get(url);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          _weatherData = WeatherData.fromJson(jsonData, city);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch weather data.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch weather data.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0288D1), Color(0xFF26A69A)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Weather App',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Enter city name (e.g., Lahore, Tokyo)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 20,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Colors.white70),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        _fetchWeather(_controller.text);
                      }
                    },
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _fetchWeather(value);
                  }
                },
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _isLoading
                    ? const Center(
                  child: SpinKitWave(
                    color: Colors.white,
                    size: 50.0,
                  ),
                )
                    : _errorMessage != null
                    ? Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                    : _weatherData == null
                    ? const Center(
                  child: Text(
                    'Search for a city to see the weather!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                    : AnimatedOpacity(
                  opacity: _weatherData != null ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8,
                    color: Colors.white.withOpacity(0.9),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _weatherData!.city,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_weatherData!.temperature.round()}°C',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w300,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _weatherData!.condition,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Humidity: ${_weatherData!.humidity}%',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}