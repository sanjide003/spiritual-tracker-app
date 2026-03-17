// 📂 File: lib/features/dashboard/dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart'; // ഗ്രാഫിന് വേണ്ടി
import '../../core/localization/app_localizations.dart';
import '../prayer/prayer_controller.dart';
import '../dhikr/dhikr_controller.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<AppLanguageProvider>(context);
    final prayerCtrl = Provider.of<PrayerController>(context);
    final dhikrCtrl = Provider.of<DhikrController>(context);

    // ഡാറ്റാബേസിൽ നിന്നുള്ള ലൈവ് വിവരങ്ങൾ
    int pendingQadha = prayerCtrl.getTotalPendingQadha();
    int totalDhikr = dhikrCtrl.getTotalDhikrCount();

    return Scaffold(
      appBar: AppBar(title: Text(lang.translate('tab_dashboard')), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your Spiritual Summary', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildSummaryCard(context, 'Pending Qadha', '$pendingQadha', Colors.orange),
                const SizedBox(width: 16),
                _buildSummaryCard(context, 'Total Dhikr', '$totalDhikr', Colors.teal),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Activity Graph', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                // fl_chart ഉപയോഗിച്ചുള്ള യഥാർത്ഥ ഗ്രാഫ്
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    barGroups: [
                      BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 8, color: Colors.teal)]),
                      BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 10, color: Colors.teal)]),
                      BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 14, color: Colors.teal)]),
                      BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 15, color: Colors.teal)]),
                      BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 13, color: Colors.teal)]),
                      BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 10, color: Colors.teal)]),
                      BarChartGroupData(x: 7, barRods: [BarChartRodData(toY: totalDhikr.toDouble() / 10, color: Colors.orange)]), // ഇന്നത്തെ പ്രോഗ്രസ്
                    ],
                    titlesData: const FlTitlesData(leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(count, style: TextStyle(fontSize: 32, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}