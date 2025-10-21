import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../../domain/login_history.dart';

class LoginStatsCard extends StatelessWidget {
  final List<LoginHistory> loginHistory;
  final String title;
  final Color startColor;
  final Color endColor;

  const LoginStatsCard({
    super.key,
    required this.loginHistory,
    required this.title,
    required this.startColor,
    required this.endColor,
  });

  @override
  Widget build(BuildContext context) {
    // Obtener fecha hace 30 días
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    
    // Agrupar por día para el gráfico (últimos 30 días)
    final Map<DateTime, int> loginsByDay = {};
    
    // Inicializar todos los días con 0
    for (int i = 0; i <= 30; i++) {
      final date = thirtyDaysAgo.add(Duration(days: i));
      loginsByDay[DateTime(date.year, date.month, date.day)] = 0;
    }
    
    // Contar los logins por día
    for (var login in loginHistory) {
      if (login.timestamp.isAfter(thirtyDaysAgo)) {
        final date = DateTime(
          login.timestamp.year,
          login.timestamp.month,
          login.timestamp.day,
        );
        loginsByDay[date] = (loginsByDay[date] ?? 0) + 1;
      }
    }

    final chartData = loginsByDay.entries
        .map((e) => LoginDataPoint(e.key, e.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                  axisLine: const AxisLine(width: 0),
                  labelStyle: const TextStyle(color: Colors.white70),
                  dateFormat: DateFormat('dd/MM'),
                  interval: 5,
                  minimum: thirtyDaysAgo,
                  maximum: DateTime.now(),
                ),
                primaryYAxis: NumericAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                  axisLine: const AxisLine(width: 0),
                  labelStyle: const TextStyle(color: Colors.white70),
                  minimum: 0,
                  interval: 1,
                  maximum: loginsByDay.values.isEmpty ? 1 : 
                          (loginsByDay.values.reduce((max, value) => max > value ? max : value) + 1).toDouble(),
                ),
                plotAreaBorderWidth: 0,
                enableAxisAnimation: true,
                series: <CartesianSeries<LoginDataPoint, DateTime>>[
                  AreaSeries<LoginDataPoint, DateTime>(
                    dataSource: chartData,
                    xValueMapper: (LoginDataPoint data, _) => data.date,
                    yValueMapper: (LoginDataPoint data, _) => data.count,
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.5),
                        Colors.white.withOpacity(0.1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  LineSeries<LoginDataPoint, DateTime>(
                    dataSource: chartData,
                    xValueMapper: (LoginDataPoint data, _) => data.date,
                    yValueMapper: (LoginDataPoint data, _) => data.count,
                    color: Colors.white,
                    markerSettings: const MarkerSettings(
                      isVisible: true,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginDataPoint {
  final DateTime date;
  final int count;

  LoginDataPoint(this.date, this.count);
}