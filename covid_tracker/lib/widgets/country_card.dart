import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../models/covid_data.dart';

class CountryCard extends StatelessWidget {
  final CountryData country;
  final bool isSelected;
  final VoidCallback onTap;

  const CountryCard({
    Key? key,
    required this.country,
    this.isSelected = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: AppStyles.cardDecoration.copyWith(
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Country Flag and Info
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: country.flag.isNotEmpty
                            ? Image.network(
                                country.flag,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Text(
                                      FormatHelper.getCountryFlagEmoji(
                                        country.countryCode,
                                      ),
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                              : null,
                                          strokeWidth: 2,
                                        ),
                                      );
                                    },
                              )
                            : Center(
                                child: Text(
                                  FormatHelper.getCountryFlagEmoji(
                                    country.countryCode,
                                  ),
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            country.country,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _getContinentColor(country.continent),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  country.continent,
                                  style: AppStyles.smallStyle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Stats
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.cases,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        FormatHelper.formatNumber(country.cases),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.cases,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.deaths,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        FormatHelper.formatNumber(country.deaths),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.deaths,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${country.recoveryRate.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getContinentColor(String continent) {
    switch (continent.toLowerCase()) {
      case 'asia':
        return Colors.red;
      case 'europe':
        return Colors.blue;
      case 'africa':
        return Colors.green;
      case 'north america':
        return Colors.orange;
      case 'south america':
        return Colors.purple;
      case 'oceania':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}

class CountryInfoCard extends StatelessWidget {
  final CountryData country;

  const CountryInfoCard({Key? key, required this.country}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyles.gradientCardDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header with flag and basic info
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white, width: 2),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: country.flag.isNotEmpty
                      ? Image.network(
                          country.flag,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                FormatHelper.getCountryFlagEmoji(
                                  country.countryCode,
                                ),
                                style: const TextStyle(fontSize: 24),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            FormatHelper.getCountryFlagEmoji(
                              country.countryCode,
                            ),
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      country.country,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getContinentColor(country.continent),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          country.continent,
                          style: AppStyles.bodyStyle.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (country.population != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Population: ${FormatHelper.formatNumber(country.population!)}',
                        style: AppStyles.smallStyle,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Per million statistics
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3,
              children: [
                _buildInfoItem(
                  '📊 Cases/M',
                  country.casesPerOneMillion?.toStringAsFixed(1) ?? 'N/A',
                  AppColors.cases,
                ),
                _buildInfoItem(
                  '💀 Deaths/M',
                  country.deathsPerOneMillion?.toStringAsFixed(1) ?? 'N/A',
                  AppColors.deaths,
                ),
                _buildInfoItem(
                  '🧪 Tests/M',
                  country.testsPerOneMillion?.toStringAsFixed(1) ?? 'N/A',
                  AppColors.info,
                ),
                _buildInfoItem(
                  '💚 Recovery Rate',
                  '${country.recoveryRate.toStringAsFixed(1)}%',
                  AppColors.success,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Today's statistics
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTodayStat(
                  'Today Cases',
                  country.todayCases,
                  AppColors.cases,
                ),
                _buildTodayStat(
                  'Today Deaths',
                  country.todayDeaths,
                  AppColors.deaths,
                ),
                _buildTodayStat(
                  'Today Recovered',
                  country.todayRecovered,
                  AppColors.success,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.smallStyle.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayStat(String title, int value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: AppStyles.smallStyle.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value > 0
                ? '+${FormatHelper.formatNumber(value)}'
                : FormatHelper.formatNumber(value),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Color _getContinentColor(String continent) {
    switch (continent.toLowerCase()) {
      case 'asia':
        return Colors.red;
      case 'europe':
        return Colors.blue;
      case 'africa':
        return Colors.green;
      case 'north america':
        return Colors.orange;
      case 'south america':
        return Colors.purple;
      case 'oceania':
      case 'australia/oceania':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}

// Compact version for lists
class CompactCountryCard extends StatelessWidget {
  final CountryData country;
  final VoidCallback onTap;
  final int rank;

  const CompactCountryCard({
    Key? key,
    required this.country,
    required this.onTap,
    required this.rank,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Rank
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _getRankColor(rank),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Flag
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: country.flag.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        country.flag,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              FormatHelper.getCountryFlagEmoji(
                                country.countryCode,
                              ),
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Text(
                        FormatHelper.getCountryFlagEmoji(country.countryCode),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
            ),
            const SizedBox(width: 12),

            // Country name
            Expanded(
              child: Text(
                country.country,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Cases
            Text(
              FormatHelper.formatNumber(country.cases),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.cases,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey;
    if (rank == 3) return Colors.orange[700]!;
    return AppColors.primary;
  }
}
