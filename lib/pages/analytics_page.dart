import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sales Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: _buildSalesChart(),
            ),
            const SizedBox(height: 32),
            const Text(
              'Top Selling Products',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: _buildTopProductsChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesChart() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .limit(30)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final orders = snapshot.data!.docs;
        final salesData = _processSalesData(orders);

        return LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: salesData
                    .map((data) => FlSpot(
                        data.date.millisecondsSinceEpoch.toDouble(),
                        data.amount))
                    .toList(),
                isCurved: true,
                color: Colors.blue,
                barWidth: 3,
                dotData: FlDotData(show: false),
              ),
            ],
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final date =
                        DateTime.fromMillisecondsSinceEpoch(value.toInt());
                    return Text(DateFormat('MM/dd').format(date),
                        style: const TextStyle(fontSize: 10));
                  },
                  reservedSize: 22,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopProductsChart() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .limit(100)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final orders = snapshot.data!.docs;
        final productData = _processProductData(orders);

        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: productData
                .map((data) => data.quantity.toDouble())
                .reduce((a, b) => a > b ? a : b),
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 &&
                        value.toInt() < productData.length) {
                      return Text(productData[value.toInt()].name,
                          style: const TextStyle(fontSize: 10));
                    }
                    return const Text('');
                  },
                ),
              ),
            ),
            barGroups: productData.asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                      toY: entry.value.quantity.toDouble(), color: Colors.green)
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  List<SalesData> _processSalesData(List<QueryDocumentSnapshot> orders) {
    final Map<DateTime, double> salesMap = {};

    for (var order in orders) {
      final data = order.data() as Map<String, dynamic>;
      final date = (data['createdAt'] as Timestamp).toDate();
      final amount = (data['total_amount'] as num).toDouble();

      final dateWithoutTime = DateTime(date.year, date.month, date.day);
      salesMap[dateWithoutTime] = (salesMap[dateWithoutTime] ?? 0) + amount;
    }

    return salesMap.entries
        .map((entry) => SalesData(entry.key, entry.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<ProductData> _processProductData(List<QueryDocumentSnapshot> orders) {
    final Map<String, int> productQuantities = {};

    for (var order in orders) {
      final data = order.data() as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>;

      for (var item in items) {
        final productName = item['product_name'] as String;
        final quantity = item['quantity'] as int;
        productQuantities[productName] =
            (productQuantities[productName] ?? 0) + quantity;
      }
    }

    return productQuantities.entries
        .map((entry) => ProductData(entry.key, entry.value))
        .toList()
      ..sort((a, b) => b.quantity.compareTo(a.quantity));
  }
}

class SalesData {
  final DateTime date;
  final double amount;

  SalesData(this.date, this.amount);
}

class ProductData {
  final String name;
  final int quantity;

  ProductData(this.name, this.quantity);
}
