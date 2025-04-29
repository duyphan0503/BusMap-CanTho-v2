import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class RoutePlannerScreen extends StatefulWidget {
  const RoutePlannerScreen({super.key});

  @override
  State<RoutePlannerScreen> createState() => _RoutePlannerScreenState();
}

class _RoutePlannerScreenState extends State<RoutePlannerScreen> {
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  List<String> availableRoutes = [];

  void _planRoute() {
    // TODO: Implement route search logic.
    setState(() {
      availableRoutes = [
        'Route A: Direct',
        'Route B: 1 transfer',
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('routePlanner'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _startController,
              decoration: InputDecoration(labelText: 'startPoint'.tr()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _destinationController,
              decoration: InputDecoration(labelText: 'destination'.tr()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _planRoute,
              child: Text('searchRoutes'.tr()),
            ),
            const SizedBox(height: 16),
            if (availableRoutes.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: availableRoutes.length,
                  itemBuilder: (context, index) =>
                      ListTile(title: Text(availableRoutes[index])),
                ),
              ),
          ],
        ),
      ),
    );
  }
}