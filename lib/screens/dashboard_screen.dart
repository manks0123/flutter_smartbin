import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final scansRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('scans');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.green[700],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: scansRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // 🔢 นับข้อมูลจริงจาก History
          int plastic = 0;
          int paper = 0;
          int organic = 0;

          for (var doc in snapshot.data!.docs) {
            final result = doc['result'];
            if (result == 'Plastic') plastic++;
            if (result == 'Paper') paper++;
            if (result == 'Organic') organic++;
          }

          final total = plastic + paper + organic;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Overview'),

                const SizedBox(height: 20),

                /// 🔢 SUMMARY CARDS
                IntrinsicHeight(
                  child: Row(
                    children: [
                      _SummaryCard(
                        title: 'Total Scans',
                        value: total.toString(),
                        icon: Icons.recycling,
                        gradient: [Colors.green, Colors.greenAccent],
                      ),
                      const SizedBox(width: 16),
                      _SummaryCard(
                        title: 'Plastic',
                        value: plastic.toString(),
                        icon: Icons.local_drink,
                        gradient: [Colors.blue, Colors.blueAccent],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      _SummaryCard(
                        title: 'Paper',
                        value: paper.toString(),
                        icon: Icons.description,
                        gradient: [Colors.teal, Colors.tealAccent],
                      ),
                      const SizedBox(width: 16),
                      _SummaryCard(
                        title: 'Organic',
                        value: organic.toString(),
                        icon: Icons.eco,
                        gradient: [Colors.brown, Colors.orangeAccent],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                _sectionTitle('Statistics'),
                const SizedBox(height: 20),

                /// 🥧 PIE CHART
                _ChartCard(
                  title: 'Waste Distribution',
                  icon: Icons.pie_chart,
                  child: total == 0
                      ? const _EmptyState()
                      : SizedBox(
                          height: 240,
                          child: PieChart(
                            PieChartData(
                              centerSpaceRadius: 50,
                              sectionsSpace: 3,
                              sections: [
                                _pie(plastic, Colors.blue, 'Plastic'),
                                _pie(paper, Colors.teal, 'Paper'),
                                _pie(organic, Colors.brown, 'Organic'),
                              ],
                            ),
                          ),
                        ),
                ),

                const SizedBox(height: 24),

                /// 📊 BAR CHART
                _ChartCard(
                  title: 'Waste Count',
                  icon: Icons.bar_chart,
                  child: total == 0
                      ? const _EmptyState()
                      : SizedBox(
                          height: 240,
                          child: BarChart(
                            BarChartData(
                              borderData: FlBorderData(show: false),
                              gridData: FlGridData(show: true),
                              titlesData: FlTitlesData(
                                topTitles:
                                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles:
                                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: true),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, _) {
                                      switch (value.toInt()) {
                                        case 0:
                                          return const Text('Plastic');
                                        case 1:
                                          return const Text('Paper');
                                        case 2:
                                          return const Text('Organic');
                                        default:
                                          return const Text('');
                                      }
                                    },
                                  ),
                                ),
                              ),
                              barGroups: [
                                _bar(0, plastic, Colors.blue),
                                _bar(1, paper, Colors.teal),
                                _bar(2, organic, Colors.brown),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// ---------- HELPERS ----------

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: Colors.green[700],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  PieChartSectionData _pie(int value, Color color, String title) {
    return PieChartSectionData(
      value: value.toDouble(),
      title: value == 0 ? '' : value.toString(),
      color: color,
      radius: 70,
      titleStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  BarChartGroupData _bar(int x, int y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y.toDouble(),
          width: 30,
          borderRadius: BorderRadius.circular(8),
          color: color,
        ),
      ],
    );
  }
}

/// ---------- SUMMARY CARD ----------
class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradient;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------- CHART CARD ----------
class _ChartCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

/// ---------- EMPTY ----------
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 200,
      child: Center(
        child: Text(
          'No data yet',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
