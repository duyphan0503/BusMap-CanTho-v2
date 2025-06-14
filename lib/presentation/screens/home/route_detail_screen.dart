import 'package:busmapcantho/data/model/bus_route.dart';
import 'package:busmapcantho/data/model/bus_stop.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class RouteDetailScreen extends StatelessWidget {
  final BusRoute? route;
  final BusStop? startStop;
  final BusStop? endStop;
  final String? walkingDistance;
  final String? busDistance;
  final String? totalTime;
  final String? startName;
  final String? endName;
  final List<BusStop>? routeStops;
  final bool isBicycle;

  const RouteDetailScreen({
    super.key,
    this.route,
    this.startStop,
    this.endStop,
    this.walkingDistance,
    this.busDistance,
    this.totalTime,
    this.startName,
    this.endName,
    this.routeStops,
    this.isBicycle = false,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isBicycle
              ? 'bikeDetailTitle'.tr()
              : 'busRouteDetailTitle'.tr(args: [route?.routeNumber ?? ""])),
          bottom: TabBar(
            tabs: [
              Tab(text: 'detailTab'.tr()),
              Tab(text: 'stopsTab'.tr()),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDetailTab(context),
            _buildStopsTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTab(BuildContext context) {
    if (isBicycle) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2,
          child: ListTile(
            leading: const Icon(Icons.directions_bike, color: Colors.green),
            title: Text('bikeInstruction'.tr()),
            subtitle: Text(
              '${'from'.tr()}: $startName\n${'to'.tr()}: $endName\n${'distance'.tr()}: $busDistance\n${'totalTime'.tr()}: $totalTime',
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.directions_walk, color: Colors.green),
              title: Text('walkToStop'.tr()),
              subtitle: Text(
                '${'from'.tr()}: $startName\n${'to'.tr()}: ${startStop?.name ?? ""}\n${'distance'.tr()}: $walkingDistance',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.directions_bus, color: Colors.blue),
              title: Text('takeBusRoute'.tr(args: [route?.routeNumber ?? ""])),
              subtitle: Text(
                '${'fromStop'.tr()}: ${startStop?.name ?? ""}\n${'toStop'.tr()}: ${endStop?.name ?? ""}\n${'busDistance'.tr()}: $busDistance',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.flag, color: Colors.red),
              title: Text('walkToDestination'.tr()),
              subtitle: Text(
                '${'from'.tr()}: ${endStop?.name ?? ""}\n${'to'.tr()}: $endName',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.timer, color: Colors.orange),
              title: Text('totalTime'.tr()),
              subtitle: Text(totalTime ?? ""),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopsTab(BuildContext context) {
    if (routeStops == null || routeStops!.isEmpty) {
      return Center(child: Text('noStopsFound'.tr()));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: routeStops!.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final stop = routeStops![index];
        return ListTile(
          leading: Icon(
            index == 0
                ? Icons.trip_origin
                : (index == routeStops!.length - 1
                ? Icons.flag
                : Icons.stop_circle_outlined),
            color: index == 0
                ? Colors.green
                : (index == routeStops!.length - 1
                ? Colors.red
                : Colors.blueGrey),
          ),
          title: Text(stop.name),
          subtitle: Text(
              '${'lat'.tr()}: ${stop.latitude}, ${'lng'.tr()}: ${stop.longitude}'),
        );
      },
    );
  }
}
