import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_providers.dart';
import 'package:intl/intl.dart';

class MoodChart extends ConsumerWidget {
  const MoodChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(emotionHistoryProvider);
    
    // Map emotions to numeric values
    double getMoodValue(String emotionName) {
      final cleanName = emotionName.toLowerCase();
      if (cleanName.contains('calm') || cleanName.contains('peaceful')) return 5.0;
      if (cleanName.contains('stress')) return 2.0;
      if (cleanName.contains('anxious') || cleanName.contains('anxiety')) return 1.5;
      if (cleanName.contains('sad')) return 1.0;
      if (cleanName.contains('angry') || cleanName.contains('anger')) return 2.5;
      if (cleanName.contains('fatigue') || cleanName.contains('tired')) return 3.0;
      if (cleanName.contains('lonely') || cleanName.contains('loneliness')) return 1.2;
      if (cleanName.contains('guilt')) return 1.8;
      return 3.5; // neutral/default
    }
    
    // Take the last 7 entries, reverse to display chronologically (oldest to newest)
    final recentLogs = history.take(7).toList().reversed.toList();
    
    final List<FlSpot> spots = [];
    for (int i = 0; i < recentLogs.length; i++) {
      spots.add(FlSpot(i.toDouble(), getMoodValue(recentLogs[i].emotionName)));
    }
    
    // Fallback if empty
    if (spots.isEmpty) {
      spots.addAll([
        const FlSpot(0, 3.5),
        const FlSpot(1, 4.0),
        const FlSpot(2, 3.0),
        const FlSpot(3, 4.5),
        const FlSpot(4, 3.8),
        const FlSpot(5, 5.0),
        const FlSpot(6, 4.2),
      ]);
    }

    final double maxX = (spots.length - 1).toDouble();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (val, meta) {
                final idx = val.toInt();
                if (idx >= 0 && idx < recentLogs.length) {
                  final date = recentLogs[idx].timestamp;
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      DateFormat('E').format(date),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                
                // Default fallback titles if we are showing hardcoded fallback data
                const style = TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                );
                switch (idx) {
                  case 0: return SideTitleWidget(meta: meta, child: const Text('Mon', style: style));
                  case 2: return SideTitleWidget(meta: meta, child: const Text('Wed', style: style));
                  case 4: return SideTitleWidget(meta: meta, child: const Text('Fri', style: style));
                  case 6: return SideTitleWidget(meta: meta, child: const Text('Sun', style: style));
                }
                return SideTitleWidget(meta: meta, child: const Text(''));
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: maxX > 0 ? maxX : 6.0,
        minY: 0,
        maxY: 6,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.teal],
            ),
            barWidth: 5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.3),
                  AppColors.teal.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

