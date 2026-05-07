import 'package:intl/intl.dart';

class FormatHelper {
  static String formatNumber(int number) {
    if (number < 1000) return number.toString();
    if (number < 1000000) return '${(number / 1000).toStringAsFixed(1)}K';
    if (number < 1000000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    return '${(number / 1000000000).toStringAsFixed(1)}B';
  }

  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(2)}%';
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }

  static String formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  static String getCountryFlagEmoji(String countryCode) {
    if (countryCode.length != 2) return '🏳️';

    final firstLetter = countryCode.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final secondLetter = countryCode.codeUnitAt(1) - 0x41 + 0x1F1E6;

    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }
}

class ChartData {
  final String date;
  final int value;
  final String type;

  ChartData(this.date, this.value, this.type);
}
//           const SizedBox(height: 200, child: charts.BarChart(series, animate: true)),
//         ],
//       ),
//     );
//   }
// }