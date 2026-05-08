import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/covid_data.dart';

class CovidProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  CovidData? _globalData;
  List<CountryData> _countries = [];
  List<CountryData> _topCountries = [];
  CountryData? _selectedCountry;
  HistoricalData? _historicalData;
  bool _isLoading = false;
  String _error = '';
  DateTime? _lastUpdated;
  String _searchQuery = '';

  CovidData? get globalData => _globalData;
  List<CountryData> get countries => _countries;
  List<CountryData> get topCountries => _topCountries;
  CountryData? get selectedCountry => _selectedCountry;
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  String get searchQuery => _searchQuery;
  HistoricalData? get historicalData => _historicalData;

  Future<void> fetchAllData() async {
    _setLoading(true);
    _error = '';

    try {
      // Fetch global data and countries in parallel
      final globalFuture = _fetchGlobalData();
      final countriesFuture = _fetchAllCountries();

      await Future.wait([globalFuture, countriesFuture]);

      _lastUpdated = DateTime.now();
      _error = '';
    } catch (e) {
      _error = 'Failed to fetch data: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _fetchGlobalData() async {
    try {
      _globalData = await _apiService.getGlobalData();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to fetch global data: $e');
    }
  }

  Future<void> _fetchAllCountries() async {
    try {
      _countries = await _apiService.getAllCountries();
      _updateTopCountries();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to fetch countries: $e');
    }
  }

  void _updateTopCountries() {
    if (_countries.isNotEmpty) {
      // Sort by cases in descending order and take top 10
      _topCountries = List.from(_countries)
        ..sort((a, b) => b.cases.compareTo(a.cases))
        ..take(10);
    } else {
      _topCountries = [];
    }
  }

  Future<void> selectCountry(String countryCode) async {
    _setLoading(true);
    _error = '';

    try {
      _selectedCountry = await _apiService.getCountryData(countryCode);
      // Attempt to load historical data (last 30 days)
      try {
        _historicalData = await _apiService.getHistoricalData(countryCode);
      } catch (_) {
        _historicalData = null;
      }
      _error = '';
    } catch (e) {
      _error = 'Failed to fetch country data: $e';
      _selectedCountry = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchCountries(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      // Reset to original list
      await _fetchAllCountries();
    } else {
      // Filter existing countries based on query
      _countries = _countries
          .where(
            (country) =>
                country.country.toLowerCase().contains(query.toLowerCase()) ||
                country.countryCode.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    await fetchAllData();
    if (_selectedCountry != null) {
      await selectCountry(_selectedCountry!.countryCode);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  void clearSelectedCountry() {
    _selectedCountry = null;
    notifyListeners();
  }

  // Get filtered countries based on search
  List<CountryData> get filteredCountries {
    if (_searchQuery.isEmpty) return _countries;
    return _countries
        .where(
          (country) =>
              country.country.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              country.countryCode.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
        )
        .toList();
  }
}
