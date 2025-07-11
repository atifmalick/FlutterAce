import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() {
  runApp(const WeatherApiApp());
}

class WeatherApiApp extends StatelessWidget {
  const WeatherApiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WeatherHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});

  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  final TextEditingController _cityController = TextEditingController();
  String cityName = "Karachi";
  String temp = "--";
  String description = "Clear";
  String animationUrl =
      "https://assets7.lottiefiles.com/packages/lf20_j1adxtyb.json";

  final String apiKey = "1c8c9362ac53d673901dfaadb9ca70e5";

  List<Map<String, String>> forecast = [];

  Future<void> fetchWeather(String city) async {
    final trimmedCity = city.trim();
    if (trimmedCity.isEmpty) return;

    final url =
        "https://api.openweathermap.org/data/2.5/weather?q=$trimmedCity&appid=$apiKey&units=metric";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        cityName = data['name'];
        temp = data['main']['temp'].toString();
        description = data['weather'][0]['main'];
        animationUrl = getAnimationUrl(description);
      });
      fetchForecast(city);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("City not found!")),
      );
    }
  }

  Future<void> fetchForecast(String city) async {
    final url =
        "https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['list'];
      forecast = [];
      for (int i = 0; i < 5; i++) {
        final item = list[i * 8];
        forecast.add({
          'day': DateTime.parse(item['dt_txt']).weekday.toString(),
          'temp': item['main']['temp'].toString(),
        });
      }
      setState(() {});
    }
  }

  String getAnimationUrl(String weatherCondition) {
    switch (weatherCondition) {
      case "Clear":
        return "https://assets7.lottiefiles.com/packages/lf20_j1adxtyb.json";
      case "Clouds":
        return "https://assets2.lottiefiles.com/packages/lf20_HpFqiS.json";
      case "Rain":
      case "Mist":
        return "https://assets2.lottiefiles.com/packages/lf20_Stdaec.json";
      default:
        return "https://assets7.lottiefiles.com/packages/lf20_j1adxtyb.json";
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeather(cityName);
  }

  String getWeekdayName(String number) {
    switch (number) {
      case "1":
        return "Mon";
      case "2":
        return "Tue";
      case "3":
        return "Wed";
      case "4":
        return "Thu";
      case "5":
        return "Fri";
      case "6":
        return "Sat";
      case "7":
        return "Sun";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[300],
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _cityController,
                style: const TextStyle(color: Colors.black87, fontSize: 18),
                decoration: InputDecoration(
                  hintText: "Search City...",
                  hintStyle: const TextStyle(color: Colors.black54),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Colors.black87),
                    onPressed: () {
                      if (_cityController.text.trim().isNotEmpty) {
                        fetchWeather(_cityController.text.trim());
                        _cityController.clear();
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Lottie.network(animationUrl, fit: BoxFit.cover),
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 30),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            cityName,
                            style: const TextStyle(
                              fontSize: 38,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.thermostat_outlined,
                                  color: Colors.amberAccent, size: 40),
                              const SizedBox(width: 8),
                              Text(
                                "$temp°C",
                                style: const TextStyle(
                                  fontSize: 70,
                                  color: Colors.amberAccent,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cloud_outlined,
                                  color: Colors.white70, size: 32),
                              const SizedBox(width: 8),
                              Text(
                                description,
                                style: const TextStyle(
                                  fontSize: 28,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 1000.ms),
                  ),
                  if (forecast.isNotEmpty)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: forecast.length,
                          itemBuilder: (context, index) {
                            final item = forecast[index];
                            return Container(
                              width: 90,
                              margin:
                              const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    getWeekdayName(item['day'] ?? ''),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Icon(Icons.thermostat,
                                      color: Colors.amberAccent, size: 28),
                                  const SizedBox(height: 6),
                                  Text(
                                    "${item['temp']}°C",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
