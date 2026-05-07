import 'package:flutter/material.dart' hide CarouselController;
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/covid_data.dart';
import '../providers/covid_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/country_card.dart';
import '../widgets/chart_widget.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RefreshController _refreshController = RefreshController();
  final CarouselController _carouselController = CarouselController();
  int _currentCarouselIndex = 0;
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final provider = Provider.of<CovidProvider>(context, listen: false);
    await provider.fetchAllData();
  }

  Future<void> _onRefresh() async {
    final provider = Provider.of<CovidProvider>(context, listen: false);
    await provider.refreshData();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CovidProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(provider),
          body: SafeArea(
            child: SmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefresh,
              enablePullDown: true,
              header: WaterDropHeader(
                waterDropColor: AppColors.primary,
                complete: Icon(Icons.check_circle, color: AppColors.success),
              ),
              child: _buildContent(provider),
            ),
          ),
          floatingActionButton: _buildFloatingActionButton(provider),
        );
      },
    );
  }

  AppBar _buildAppBar(CovidProvider provider) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: _showSearch
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search country...',
                hintStyle: const TextStyle(color: Colors.white70),
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _showSearch = false;
                      _searchController.clear();
                      provider.searchCountries('');
                    });
                  },
                ),
              ),
              onChanged: (value) {
                provider.searchCountries(value);
              },
            )
          : Row(
              children: [
                const Icon(Icons.monitor_heart, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'COVID-19 Tracker',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (provider.lastUpdated != null) ...[
                  const Spacer(),
                  Text(
                    'Updated ${FormatHelper.formatTimeAgo(provider.lastUpdated!)}',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ],
            ),
      actions: _showSearch
          ? []
          : [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _showSearch = true;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.white),
                onPressed: _showInfoDialog,
              ),
            ],
    );
  }

  Widget _buildContent(CovidProvider provider) {
    if (provider.isLoading && provider.globalData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SpinKitFadingCircle(color: AppColors.primary, size: 50.0),
            const SizedBox(height: 20),
            Text('Fetching COVID-19 Data...', style: AppStyles.subtitleStyle),
          ],
        ),
      );
    }

    if (provider.error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.danger, size: 64),
            const SizedBox(height: 16),
            Text(
              'Error Loading Data',
              style: AppStyles.titleStyle.copyWith(color: AppColors.danger),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                provider.error,
                textAlign: TextAlign.center,
                style: AppStyles.bodyStyle,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => provider.fetchAllData(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (provider.globalData != null) _buildGlobalStats(provider),
        const SizedBox(height: 24),
        _buildPreventionTips(),
        const SizedBox(height: 24),
        _buildTopCountries(provider),
        const SizedBox(height: 16),
        if (provider.selectedCountry != null) _buildCountryDetails(provider),
        const SizedBox(height: 16),
        _buildDataSourceInfo(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildGlobalStats(CovidProvider provider) {
    final data = provider.globalData!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Global Statistics', style: AppStyles.titleStyle),
        const SizedBox(height: 8),
        Text(
          'Last updated: ${FormatHelper.formatDateTime(data.updated ?? DateTime.now())}',
          style: AppStyles.smallStyle,
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            AnimatedStatCard(
              title: 'Total Cases',
              value: data.cases,
              color: AppColors.cases,
              icon: Icons.people_alt,
            ),
            AnimatedStatCard(
              title: 'Total Deaths',
              value: data.deaths,
              color: AppColors.deaths,
              icon: Icons.warning,
            ),
            AnimatedStatCard(
              title: 'Recovered',
              value: data.recovered,
              color: AppColors.success,
              icon: Icons.health_and_safety,
            ),
            AnimatedStatCard(
              title: 'Active Cases',
              value: data.active,
              color: AppColors.active,
              icon: Icons.local_hospital,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Today's cases
        Container(
          decoration: AppStyles.cardDecoration,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTodayStat('Today Cases', data.todayCases, AppColors.cases),
              _buildTodayStat(
                'Today Deaths',
                data.todayDeaths,
                AppColors.deaths,
              ),
              _buildTodayStat(
                'Today Recovered',
                data.todayRecovered,
                AppColors.success,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Recovery and Death Rates
        Row(
          children: [
            Expanded(
              child: LinearPercentIndicator(
                animation: true,
                lineHeight: 20.0,
                animationDuration: 2000,
                percent: data.recoveryRate / 100,
                center: Text(
                  '${data.recoveryRate.toStringAsFixed(1)}% Recovery',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                linearStrokeCap: LinearStrokeCap.roundAll,
                progressColor: AppColors.success,
                backgroundColor: AppColors.success.withOpacity(0.1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LinearPercentIndicator(
                animation: true,
                lineHeight: 20.0,
                animationDuration: 2000,
                percent: data.deathRate / 100,
                center: Text(
                  '${data.deathRate.toStringAsFixed(1)}% Fatality',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                linearStrokeCap: LinearStrokeCap.roundAll,
                progressColor: AppColors.danger,
                backgroundColor: AppColors.danger.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodayStat(String title, int value, Color color) {
    return Column(
      children: [
        Text(title, style: AppStyles.smallStyle),
        const SizedBox(height: 4),
        Text(
          FormatHelper.formatNumber(value),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPreventionTips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Prevention Tips', style: AppStyles.titleStyle),
        const SizedBox(height: 12),
        CarouselSlider.builder(
          carouselController: _carouselController,
          options: CarouselOptions(
            height: 140,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.8,
            autoPlayInterval: const Duration(seconds: 5),
            onPageChanged: (index, reason) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
          ),
          itemCount: AppConstants.preventionTips.length,
          itemBuilder: (context, index, realIndex) {
            final tip = AppConstants.preventionTips[index];
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.2),
                    AppColors.secondary.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tip['icon']!,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tip['title']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tip['description']!,
                          style: AppStyles.bodyStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Center(
          child: AnimatedSmoothIndicator(
            activeIndex: _currentCarouselIndex,
            count: AppConstants.preventionTips.length,
            effect: ExpandingDotsEffect(
              activeDotColor: AppColors.primary,
              dotColor: AppColors.primary.withOpacity(0.3),
              dotHeight: 8,
              dotWidth: 8,
              spacing: 8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopCountries(CovidProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Top Countries', style: AppStyles.titleStyle),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CountriesScreen()),
                );
              },
              child: const Text(
                'View All',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (provider.topCountries.isEmpty)
          const Center(child: Text('No countries data available'))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.topCountries.length,
            itemBuilder: (context, index) {
              final country = provider.topCountries[index];
              return CountryCard(
                country: country,
                isSelected:
                    provider.selectedCountry?.countryCode ==
                    country.countryCode,
                onTap: () {
                  provider.selectCountry(country.countryCode);
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildCountryDetails(CovidProvider provider) {
    final country = provider.selectedCountry!;
    final historicalData = provider.historicalData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        const Text('Selected Country', style: AppStyles.titleStyle),
        const SizedBox(height: 12),
        CountryInfoCard(country: country),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            StatCard(
              title: 'Total Cases',
              value: country.cases,
              todayValue: country.todayCases,
              color: AppColors.cases,
              icon: Icons.people_alt,
            ),
            StatCard(
              title: 'Total Deaths',
              value: country.deaths,
              todayValue: country.todayDeaths,
              color: AppColors.deaths,
              icon: Icons.warning,
            ),
            StatCard(
              title: 'Recovered',
              value: country.recovered,
              todayValue: country.todayRecovered,
              color: AppColors.success,
              icon: Icons.health_and_safety,
            ),
            StatCard(
              title: 'Active Cases',
              value: country.active,
              color: AppColors.active,
              icon: Icons.local_hospital,
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (historicalData != null && historicalData.cases.isNotEmpty) ...[
          const Text('30-Day Trend', style: AppStyles.titleStyle),
          const SizedBox(height: 12),
          CovidChart(
            data: historicalData.cases,
            title: 'Cases Trend',
            color: AppColors.cases,
          ),
          const SizedBox(height: 16),
          CovidChart(
            data: historicalData.deaths,
            title: 'Deaths Trend',
            color: AppColors.deaths,
          ),
        ],
      ],
    );
  }

  Widget _buildDataSourceInfo() {
    return Container(
      decoration: AppStyles.cardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Data Source',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Data provided by ${AppConstants.apiSource} API',
            style: AppStyles.bodyStyle,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final url = Uri.parse(AppConstants.githubRepo);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                  icon: const Icon(Icons.code, size: 16),
                  label: const Text('API Source'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final url = Uri.parse(AppConstants.whoWebsite);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                  icon: const Icon(Icons.public, size: 16),
                  label: const Text('WHO'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton(CovidProvider provider) {
    return FloatingActionButton(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      onPressed: () {
        if (provider.selectedCountry != null) {
          _shareCountryData(provider.selectedCountry!);
        } else {
          _shareGlobalData(provider.globalData!);
        }
      },
      child: const Icon(Icons.share),
    );
  }

  void _shareGlobalData(CovidData data) {
    final message =
        '🌍 Global COVID-19 Statistics:\n'
        '📊 Total Cases: ${FormatHelper.formatNumber(data.cases)}\n'
        '😷 Active Cases: ${FormatHelper.formatNumber(data.active)}\n'
        '💀 Total Deaths: ${FormatHelper.formatNumber(data.deaths)}\n'
        '💚 Recovered: ${FormatHelper.formatNumber(data.recovered)}\n'
        '📈 Recovery Rate: ${data.recoveryRate.toStringAsFixed(1)}%\n'
        'Updated: ${FormatHelper.formatDateTime(data.updated ?? DateTime.now())}\n'
        '\n#COVID19 #CoronavirusTracker';

    _showShareDialog(message);
  }

  void _shareCountryData(CountryData country) {
    final message =
        '🇺🇸 ${country.country} COVID-19 Statistics:\n'
        '📊 Total Cases: ${FormatHelper.formatNumber(country.cases)}\n'
        '😷 Active Cases: ${FormatHelper.formatNumber(country.active)}\n'
        '💀 Total Deaths: ${FormatHelper.formatNumber(country.deaths)}\n'
        '💚 Recovered: ${FormatHelper.formatNumber(country.recovered)}\n'
        '📈 Recovery Rate: ${country.recoveryRate.toStringAsFixed(1)}%\n'
        '🏥 Critical: ${FormatHelper.formatNumber(country.critical)}\n'
        'Updated: ${FormatHelper.formatDateTime(country.updated ?? DateTime.now())}\n'
        '\n#COVID19 #${country.country.replaceAll(' ', '')}';

    _showShareDialog(message);
  }

  void _showShareDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Statistics'),
        content: SelectableText(message, style: AppStyles.bodyStyle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Copy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, you would use share_plus package for sharing
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copied to clipboard!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primary),
            SizedBox(width: 8),
            Text('About COVID-19 Tracker'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This app provides real-time COVID-19 statistics from around the world.',
              style: AppStyles.bodyStyle,
            ),
            const SizedBox(height: 16),
            const Text(
              'Features:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildFeatureItem('🌍 Global and country-specific data'),
            _buildFeatureItem('📊 Interactive charts and visualizations'),
            _buildFeatureItem('🔄 Real-time updates'),
            _buildFeatureItem('🔍 Search and filter countries'),
            _buildFeatureItem('📱 Offline data persistence'),
            const SizedBox(height: 16),
            const Text(
              'Data is updated every 10 minutes.',
              style: AppStyles.smallStyle,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 16, color: AppColors.success),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppStyles.bodyStyle)),
        ],
      ),
    );
  }
}

class CountriesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CovidProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Countries'),
        backgroundColor: AppColors.primary,
      ),
      body: provider.countries.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('Loading countries...', style: AppStyles.subtitleStyle),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.countries.length,
              itemBuilder: (context, index) {
                final country = provider.countries[index];
                return CountryCard(
                  country: country,
                  isSelected:
                      provider.selectedCountry?.countryCode ==
                      country.countryCode,
                  onTap: () {
                    provider.selectCountry(country.countryCode);
                    Navigator.pop(context);
                  },
                );
              },
            ),
    );
  }
}
