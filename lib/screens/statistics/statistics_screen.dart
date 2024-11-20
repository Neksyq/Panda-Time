import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pandatime/widgets/navigation/custom_drawer.dart';

class GrowStats extends StatefulWidget {
  const GrowStats({super.key});

  @override
  State<GrowStats> createState() => _GrowStatsState();
}

class _GrowStatsState extends State<GrowStats> {
  String selectedView = 'Daily';
  String selectedMonth = 'January';
  String selectedYear = '2024';

  // Available weeks and months
  final List<String> weeks = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  final List<String> years = ['2023', '2024', '2025']; // Define the years list

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            color: Colors.green,
            padding: const EdgeInsets.only(left: 16.0, top: 12.0),
            icon: const Icon(Icons.menu),
            iconSize: 36.0,
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Completed Bamboo Breaks'),
            const SizedBox(height: 10),
            _detoxTimeBreakdown(),
            const SizedBox(height: 20),
            _buildToggleButtons(),
            const SizedBox(height: 20),

            if (selectedView == 'Weekly') _buildWeeklyDropdown(),
            if (selectedView == 'Monthly') _buildMonthlyDropdown(),

            // Detox Time Summary
            _sectionTitle('Summary'),
            const SizedBox(height: 10),
            _detoxTimeSummary(),
            const SizedBox(height: 10),
            _personalizedRecommendations(),
            const SizedBox(height: 20),

            // Achievements
            _sectionTitle('Achievements'),
            const SizedBox(height: 10),
            _challengeProgress(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Toggle Buttons to switch between views
  Widget _buildToggleButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => _updateView('Daily'),
          child: const Text('Daily'),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () => _updateView('Weekly'),
          child: const Text('Weekly'),
        ),
        ElevatedButton(
          onPressed: () => _updateView('Monthly'),
          child: const Text('Monthly'),
        ),
      ],
    );
  }

  // Update view and refresh chart data
  void _updateView(String view) {
    setState(() {
      selectedView = view;
    });
  }

  // Section Title
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  // Detox Time Summary
  Widget _detoxTimeSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statTile('Total Time', '12h 30m'),
          _statTile('Daily Avg', '1h 45m'),
          _statTile('Streak', '7 Days'),
        ],
      ),
    );
  }

  // Challenge Progress
  Widget _challengeProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: 0.7,
            backgroundColor: Colors.green[300],
            color: Colors.green[800],
          ),
          const SizedBox(height: 8),
          const Text(
            '24-hour Challenge: 70% Complete',
            style: TextStyle(color: Colors.black87, fontSize: 16),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: 0.5,
            backgroundColor: Colors.green[300],
            color: Colors.green[800],
          ),
          const SizedBox(height: 8),
          const Text(
            '7-Day Streak: 50% Complete',
            style: TextStyle(color: Colors.black87, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Detox Time Breakdown with dynamic data
  Widget _detoxTimeBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    var days = [];
                    switch (selectedView) {
                      case 'Daily':
                        days = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun'
                        ];
                        break;
                      case 'Weekly':
                        days = [
                          'Week 1',
                          'Week 2',
                          'Week 3',
                          'Week 4',
                        ];
                        break;
                      case 'Monthly':
                        days = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                          'Jul',
                          'Aug',
                          'Sep',
                          'Oct',
                          'Nov',
                          'Dec'
                        ];
                        break;
                      default:
                        break;
                    }
                    return Text(
                      days[value.toInt() % days.length],
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                      ),
                    );
                  },
                  reservedSize: 30,
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: _getBarData(selectedView),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _getBarData(String view) {
    if (view == 'Daily') {
      return [
        _barData(0, 2),
        _barData(1, 3),
        _barData(2, 1.5),
        _barData(3, 4),
        _barData(4, 3.5),
        _barData(5, 2),
        _barData(6, 5)
      ];
    } else if (view == 'Weekly') {
      return _getWeeklyData(selectedMonth);
    } else {
      return _getMonthlyData(selectedYear);
    }
  }

  // Helper function for Weekly data based on selected month
  List<BarChartGroupData> _getWeeklyData(String month) {
    switch (month) {
      case 'January':
        return [
          _barData(0, 50),
          _barData(1, 70),
          _barData(2, 65),
          _barData(3, 90)
        ];
      case 'February':
        return [
          _barData(0, 40),
          _barData(1, 60),
          _barData(2, 55),
          _barData(3, 75)
        ];
      case 'March':
        return [
          _barData(0, 55),
          _barData(1, 65),
          _barData(2, 60),
          _barData(3, 80)
        ];
      case 'April':
        return [
          _barData(0, 60),
          _barData(1, 80),
          _barData(2, 70),
          _barData(3, 85)
        ];
      case 'May':
        return [
          _barData(0, 65),
          _barData(1, 75),
          _barData(2, 68),
          _barData(3, 88)
        ];
      case 'June':
        return [
          _barData(0, 70),
          _barData(1, 85),
          _barData(2, 78),
          _barData(3, 92)
        ];
      case 'July':
        return [
          _barData(0, 72),
          _barData(1, 90),
          _barData(2, 85),
          _barData(3, 95)
        ];
      case 'August':
        return [
          _barData(0, 80),
          _barData(1, 88),
          _barData(2, 86),
          _barData(3, 94)
        ];
      case 'September':
        return [
          _barData(0, 68),
          _barData(1, 78),
          _barData(2, 75),
          _barData(3, 83)
        ];
      case 'October':
        return [
          _barData(0, 62),
          _barData(1, 73),
          _barData(2, 70),
          _barData(3, 82)
        ];
      case 'November':
        return [
          _barData(0, 55),
          _barData(1, 65),
          _barData(2, 63),
          _barData(3, 78)
        ];
      case 'December':
        return [
          _barData(0, 58),
          _barData(1, 72),
          _barData(2, 70),
          _barData(3, 80)
        ];
      default:
        return [
          _barData(0, 50),
          _barData(1, 70),
          _barData(2, 65),
          _barData(3, 90)
        ];
    }
  }

  // Helper function for Monthly data
  List<BarChartGroupData> _getMonthlyData(String year) {
    switch (year) {
      case '2024':
        return [
          _barData(0, 50),
          _barData(1, 45),
          _barData(2, 70),
          _barData(3, 80),
          _barData(4, 60),
          _barData(5, 75),
          _barData(6, 85),
          _barData(7, 70),
          _barData(8, 60),
          _barData(9, 65),
          _barData(10, 75),
          _barData(11, 90)
        ];
      case '2025':
        return [
          _barData(0, 50),
          _barData(1, 70),
          _barData(2, 65),
          _barData(3, 90)
        ];
      default:
        return [
          _barData(0, 50),
          _barData(1, 70),
          _barData(2, 65),
          _barData(3, 90)
        ];
    }
  }

  // Helper function for bar chart data
  BarChartGroupData _barData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.green[800],
          width: 16,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  // Personalized Recommendations
  Widget _personalizedRecommendations() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suggested Detox Time: Evening (6 - 8 PM)',
            style: TextStyle(color: Colors.black87, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Recommended Challenge: Try a 2-hour detox session in the morning!',
            style: TextStyle(color: Colors.black87, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Helper widget for each stat tile
  Widget _statTile(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.black87, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Dropdown for selecting a specific month (#TODO)
  Widget _buildWeeklyDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Select Month: '),
        DropdownButton<String>(
          value: selectedMonth,
          items: months.map((String month) {
            return DropdownMenuItem<String>(
              value: month,
              child: Text(month),
            );
          }).toList(),
          onChanged: (String? newMonth) {
            setState(() {
              selectedMonth = newMonth ?? months[0];
            });
          },
        ),
      ],
    );
  }

  Widget _buildMonthlyDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Select Year: '),
        DropdownButton<String>(
          value: selectedYear,
          items: years.map((String year) {
            return DropdownMenuItem<String>(
              value: year,
              child: Text(year),
            );
          }).toList(),
          onChanged: (String? newYear) {
            setState(() {
              selectedYear = newYear ?? years[0];
            });
          },
        ),
      ],
    );
  }
}
