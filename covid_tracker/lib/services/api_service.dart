import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/covid_data.dart';

class ApiService {
  static const String baseUrl = 'https://disease.sh/v3/covid-19';
  static const Duration timeout = Duration(seconds: 15);

  Future<CovidData> getGlobalData() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/all'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return CovidData.fromJson(data);
      } else {
        throw Exception('Failed to load global data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<CountryData>> getAllCountries() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/countries'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => CountryData.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load countries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<CountryData> getCountryData(String country) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/countries/$country'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return CountryData.fromJson(data);
      } else {
        throw Exception('Failed to load country data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<CountryData>> getTopCountries(int count) async {
    try {
      final countries = await getAllCountries();
      // Sort by cases in descending order and take top N
      countries.sort((a, b) => b.cases.compareTo(a.cases));
      return countries.take(count).toList();
    } catch (e) {
      throw Exception('Failed to get top countries: $e');
    }
  }

  Future<HistoricalData> getHistoricalData(
    String country, {
    int lastDays = 30,
  }) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/historical/$country?lastdays=$lastDays'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // For country historical data the API often returns a 'timeline' object
        final timeline = data['timeline'] ?? data;
        return HistoricalData.fromJson(Map<String, dynamic>.from(timeline));
      } else {
        throw Exception(
          'Failed to load historical data: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
