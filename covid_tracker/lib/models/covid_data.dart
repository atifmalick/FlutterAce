class CovidData {
  final int cases;
  final int deaths;
  final int recovered;
  final int active;
  final int critical;
  final int todayCases;
  final int todayDeaths;
  final int todayRecovered;
  final int tests;
  final int? population;
  final int? affectedCountries;
  final DateTime? updated;

  CovidData({
    required this.cases,
    required this.deaths,
    required this.recovered,
    required this.active,
    required this.critical,
    required this.todayCases,
    required this.todayDeaths,
    required this.todayRecovered,
    required this.tests,
    this.population,
    this.affectedCountries,
    this.updated,
  });

  factory CovidData.fromJson(Map<String, dynamic> json) {
    return CovidData(
      cases: json['cases']?.toInt() ?? 0,
      deaths: json['deaths']?.toInt() ?? 0,
      recovered: json['recovered']?.toInt() ?? 0,
      active: json['active']?.toInt() ?? 0,
      critical: json['critical']?.toInt() ?? 0,
      todayCases: json['todayCases']?.toInt() ?? 0,
      todayDeaths: json['todayDeaths']?.toInt() ?? 0,
      todayRecovered: json['todayRecovered']?.toInt() ?? 0,
      tests: json['tests']?.toInt() ?? 0,
      population: json['population']?.toInt(),
      affectedCountries: json['affectedCountries']?.toInt(),
      updated: json['updated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updated'])
          : null,
    );
  }

  double get recoveryRate => cases > 0 ? (recovered / cases) * 100 : 0;
  double get deathRate => cases > 0 ? (deaths / cases) * 100 : 0;
  double get activeRate => cases > 0 ? (active / cases) * 100 : 0;
}

class CountryData extends CovidData {
  final String country;
  final String countryCode;
  final String flag;
  final String continent;
  final double? casesPerOneMillion;
  final double? deathsPerOneMillion;
  final double? testsPerOneMillion;
  final double? recoveredPerOneMillion;
  final double? activePerOneMillion;

  CountryData({
    required this.country,
    required this.countryCode,
    required this.flag,
    required this.continent,
    required int cases,
    required int deaths,
    required int recovered,
    required int active,
    required int critical,
    required int todayCases,
    required int todayDeaths,
    required int todayRecovered,
    required int tests,
    this.casesPerOneMillion,
    this.deathsPerOneMillion,
    this.testsPerOneMillion,
    this.recoveredPerOneMillion,
    this.activePerOneMillion,
    int? population,
    DateTime? updated,
  }) : super(
    cases: cases,
    deaths: deaths,
    recovered: recovered,
    active: active,
    critical: critical,
    todayCases: todayCases,
    todayDeaths: todayDeaths,
    todayRecovered: todayRecovered,
    tests: tests,
    population: population,
    updated: updated,
  );

  factory CountryData.fromJson(Map<String, dynamic> json) {
    return CountryData(
      country: json['country'] ?? 'Unknown',
      countryCode: json['countryInfo']['iso2']?.toString() ?? '',
      flag: json['countryInfo']['flag'] ?? '',
      continent: json['continent'] ?? 'Unknown',
      cases: json['cases']?.toInt() ?? 0,
      deaths: json['deaths']?.toInt() ?? 0,
      recovered: json['recovered']?.toInt() ?? 0,
      active: json['active']?.toInt() ?? 0,
      critical: json['critical']?.toInt() ?? 0,
      todayCases: json['todayCases']?.toInt() ?? 0,
      todayDeaths: json['todayDeaths']?.toInt() ?? 0,
      todayRecovered: json['todayRecovered']?.toInt() ?? 0,
      tests: json['tests']?.toInt() ?? 0,
      population: json['population']?.toInt(),
      casesPerOneMillion: json['casesPerOneMillion']?.toDouble(),
      deathsPerOneMillion: json['deathsPerOneMillion']?.toDouble(),
      testsPerOneMillion: json['testsPerOneMillion']?.toDouble(),
      recoveredPerOneMillion: json['recoveredPerOneMillion']?.toDouble(),
      activePerOneMillion: json['activePerOneMillion']?.toDouble(),
      updated: json['updated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updated'])
          : null,
    );
  }
}

class HistoricalData {
  final Map<String, int> cases;
  final Map<String, int> deaths;
  final Map<String, int> recovered;

  HistoricalData({
    required this.cases,
    required this.deaths,
    required this.recovered,
  });

  factory HistoricalData.fromJson(Map<String, dynamic> json) {
    Map<String, int> parseCases(Map<String, dynamic> data) {
      return Map<String, int>.from(data.map((key, value) {
        return MapEntry(key, (value as num).toInt());
      }));
    }

    return HistoricalData(
      cases: parseCases(json['cases'] ?? {}),
      deaths: parseCases(json['deaths'] ?? {}),
      recovered: parseCases(json['recovered'] ?? {}),
    );
  }
}