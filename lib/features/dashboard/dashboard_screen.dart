import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Ensure this is in your pubspec.yaml
import '../../models/machine_model.dart'; // Path to the model file we created

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Machine? selectedMachine;
  bool _viewingHistory = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Row(
        children: [
          // --- 1. SIDEBAR ---
          _buildSidebar(),

          // --- 2. DYNAMIC CONTENT ---
          Expanded(
            child: _viewingHistory
                ? _buildMaintenanceHistoryView()
                : (selectedMachine == null
                    ? _buildFactoryOverview()
                    : _buildMachineDetail(selectedMachine!)),
          ),
        ],
      ),
    );
  }

  // --- SIDEBAR WIDGET ---
  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: Color(0xFF161618),
        border: Border(right: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.bolt, color: Colors.blueAccent, size: 30),
                SizedBox(width: 10),
                Text("MaintainX AI",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          _sidebarTile("Factory Overview", Icons.grid_view_rounded, isSelected: selectedMachine == null && !_viewingHistory, onTap: () {
            setState(() {
              selectedMachine = null;
              _viewingHistory = false;
            });
          }),
          const SizedBox(height: 20),
          _sidebarTile("Maintenance & ROI", Icons.history_edu_rounded, isSelected: _viewingHistory, onTap: () {
            setState(() {
              _viewingHistory = true;
              selectedMachine = null;
            });
          }),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text("MACHINES", style: TextStyle(color: Colors.white24, fontSize: 11, letterSpacing: 1.5))),
          ),
          const SizedBox(height: 10),
          ...dummyMachines.map((m) => _sidebarMachineTile(m)).toList(),
          const Spacer(),
          const Divider(color: Colors.white10, height: 1),
          const ListTile(
            leading: CircleAvatar(backgroundColor: Colors.white10, child: Icon(Icons.person, color: Colors.white54)),
            title: Text("Admin Tech", style: TextStyle(color: Colors.white70, fontSize: 14)),
            subtitle: Text("ID: 4429-01", style: TextStyle(color: Colors.white24, fontSize: 12)),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // --- DYNAMIC MACHINE DETAIL VIEW ---
  Widget _buildMachineDetail(Machine machine) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildDetailHeader(machine),
          const SizedBox(height: 30),

          // Predictive Alert Card (Changes based on Machine 1, 2, or 3)
          _buildPredictiveAlertCard(machine),
          const SizedBox(height: 30),

          // Core Stats Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Graph Section
              Expanded(flex: 3, child: _buildPerformanceCard(machine)),
              const SizedBox(width: 20),
              // Sensor Grid Section
              Expanded(flex: 2, child: _buildSensorGrid(machine)),
            ],
          ),
          const SizedBox(height: 30),

          // Feature Importance (XAI)
          _buildFeatureImportance(machine),
        ],
      ),
    );
  }

  // --- SHARED UI COMPONENTS ---

  Widget _buildDetailHeader(Machine machine) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(machine.name, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("MODEL: LightGBM-v2 • SERIAL: ${machine.id}", style: const TextStyle(color: Colors.white38)),
          ],
        ),
        _buildActionButtons(machine.statusColor),
      ],
    );
  }

  Widget _buildPredictiveAlertCard(Machine machine) {
    // Logic for Machine 1 (Red), 2 (Yellow), 3 (Green)
    String title = "SYSTEM NOMINAL";
    String desc = "Machine is operating within expected parameters. No issues detected.";
    IconData icon = Icons.check_circle;

    if (machine.failureProbability > 0.8) {
      title = "CRITICAL FAILURE IMMINENT";
      desc = "Model identifies 90%+ probability of Tool Wear Failure (TWF). Immediate maintenance recommended.";
      icon = Icons.report_problem;
    } else if (machine.failureProbability > 0.3) {
      title = "MAINTENANCE ADVISORY";
      desc = "Warning: Abnormal Thermal Delta detected. Probability of Overstrain (OSF) is rising.";
      icon = Icons.warning_amber_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: machine.statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: machine.statusColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: machine.statusColor),
              const SizedBox(width: 12),
              Text(title, style: TextStyle(color: machine.statusColor, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: machine.failureProbability,
              backgroundColor: Colors.white10,
              color: machine.statusColor,
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 10),
          Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard(Machine machine) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF161618), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Health Trend (30 Days)", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
          const Spacer(),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: machine.monthlyPerformance.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                    isCurved: true,
                    color: machine.statusColor,
                    barWidth: 4,
                    belowBarData: BarAreaData(show: true, color: machine.statusColor.withOpacity(0.1)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorGrid(Machine machine) {
    return Column(
      children: [
        _sensorTile("Torque", "${machine.torque} Nm", Icons.settings_input_component),
        const SizedBox(height: 15),
        _sensorTile("Speed", "${machine.rpm} RPM", Icons.speed),
        const SizedBox(height: 15),
        _sensorTile("Tool Wear", "${machine.toolWear} min", Icons.build_circle_outlined),
        const SizedBox(height: 15),
        _sensorTile("Power Est.", "${machine.powerEstimate} kW", Icons.bolt),
      ],
    );
  }

  Widget _buildFeatureImportance(Machine machine) {
    // Mocking the 'Feature Importance' chart from your notebook
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF161618), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("FAILURE DRIVERS (LightGBM)", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _importanceBar("Tool Wear Interaction", 0.72, machine.statusColor),
          _importanceBar("Temp Difference", 0.45, machine.statusColor),
          _importanceBar("Torque / RPM Ratio", 0.28, machine.statusColor),
        ],
      ),
    );
  }

  // --- SUB-WIDGETS ---

  Widget _sidebarTile(String title, IconData icon, {required bool isSelected, required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isSelected ? Colors.blueAccent : Colors.white24),
      title: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.white24, fontSize: 14)),
      selected: isSelected,
    );
  }

  Widget _sidebarMachineTile(Machine m) {
    bool isSelected = selectedMachine?.id == m.id;
    return ListTile(
      onTap: () => setState(() {
        selectedMachine = m;
        _viewingHistory = false;
      }),
      leading: Icon(Icons.circle, color: m.statusColor, size: 10),
      title: Text(m.name, style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontSize: 14)),
      trailing: Text("${(m.failureProbability * 100).toInt()}%", style: const TextStyle(color: Colors.white24, fontSize: 11)),
      selected: isSelected,
      selectedTileColor: Colors.white.withOpacity(0.03),
    );
  }

  Widget _sensorTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 20),
          const SizedBox(width: 15),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.white24, fontSize: 12)),
          ]),
        ],
      ),
    );
  }

  Widget _importanceBar(String label, double val, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text("${(val * 100).toInt()}%", style: const TextStyle(color: Colors.white24, fontSize: 11)),
          ]),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: val, color: color, backgroundColor: Colors.white10, minHeight: 4),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Color machineColor) {
    return Row(
      children: [
        OutlinedButton(onPressed: () {}, child: const Text("Export Logs", style: TextStyle(color: Colors.white70))),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: machineColor.withOpacity(0.2), foregroundColor: machineColor),
          child: const Text("Service Request"),
        ),
      ],
    );
  }

  // Placeholder for the Factory Overview screen
  Widget _buildFactoryOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Welcome & Global Status ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Production Insights", 
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  Text("Factory Performance & Capacity Analysis", style: TextStyle(color: Colors.white38)),
                ],
              ),
              _buildSyncIndicator(),
            ],
          ),
          const SizedBox(height: 32),

          // --- 1. Top Metrics Row (ROI Focused) ---
          Row(
            children: [
              _buildOverviewStatCard("Total Output (Units)", "128,490", Icons.inventory_2_outlined, Colors.blueAccent),
              const SizedBox(width: 20),
              _buildOverviewStatCard("Estimated ROI", "₹35,27,500", Icons.trending_up, Colors.greenAccent),
              const SizedBox(width: 20),
              _buildOverviewStatCard("Prevented Downtime", "18.5 hrs", Icons.verified_user_outlined, Colors.orangeAccent),
            ],
          ),
          const SizedBox(height: 32),

          // --- 2. OEE Gauges Section ---
          _buildOEESection(),
          const SizedBox(height: 32),

          // --- 3. Production Capacity Bar Chart ---
          _buildCapacityChartSection(),
          
          const SizedBox(height: 32),
          
          // --- 4. Live System Logs (Smaller) ---
          _buildLiveSystemLogs(),
        ],
      ),
    );
  }

  // --- Sub-Widgets for Factory Overview ---

  Widget _buildOEESection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161618),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("OVERALL EQUIPMENT EFFECTIVENESS (OEE)", 
            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOEEGauge("Availability", 0.94, Colors.greenAccent),
              _buildOEEGauge("Performance", 0.88, Colors.blueAccent),
              _buildOEEGauge("Quality", 0.96, Colors.orangeAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOEEGauge(String label, double val, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 100, width: 100,
              child: CircularProgressIndicator(
                value: val,
                strokeWidth: 10,
                color: color,
                backgroundColor: Colors.white10,
                strokeCap: StrokeCap.round,
              ),
            ),
            Text("${(val * 100).toInt()}%", 
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
      ],
    );
  }

  Widget _buildCapacityChartSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161618),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("WEEKLY PRODUCTION CAPACITY", 
                style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              Text("Target: 15k Units", style: TextStyle(color: Colors.white24, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 20,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        return Text(days[val.toInt()], style: const TextStyle(color: Colors.white38, fontSize: 12));
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeBarGroup(0, 12, Colors.blueAccent),
                  _makeBarGroup(1, 15, Colors.blueAccent),
                  _makeBarGroup(2, 18, Colors.blueAccent),
                  _makeBarGroup(3, 14, Colors.blueAccent),
                  _makeBarGroup(4, 9, Colors.orangeAccent),
                  _makeBarGroup(5, 16, Colors.blueAccent),
                  _makeBarGroup(6, 17, Colors.blueAccent),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 22,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(show: true, toY: 20, color: Colors.white.withOpacity(0.05)),
        ),
      ],
    );
  }

  Widget _buildOverviewStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF161618),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 20),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveSystemLogs() {
    final List<Map<String, String>> logs = [
      {"time": "10:55", "msg": "M-001: Tool Wear threshold breach.", "type": "critical"},
      {"time": "10:48", "msg": "M-002: Temp Delta rising (12.4°C).", "type": "warning"},
      {"time": "10:30", "msg": "Daily model optimization sync complete.", "type": "info"},
      {"time": "10:15", "msg": "M-003: Operational sync successful.", "type": "info"},
      {"time": "09:00", "msg": "Shift handover: Tech Admin signed in.", "type": "info"},
    ];

    return Container(
      height: 365,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF161618), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Live System Logs", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, i) {
                Color logColor = logs[i]['type'] == 'critical' ? Colors.redAccent : 
                                 (logs[i]['type'] == 'warning' ? Colors.orangeAccent : Colors.white24);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Text(logs[i]['time']!, style: const TextStyle(color: Colors.white24, fontSize: 11)),
                      const SizedBox(width: 15),
                      Expanded(child: Text(logs[i]['msg']!, style: TextStyle(color: logColor.withOpacity(0.8), fontSize: 12))),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Maintenance & ROI View ---
  Widget _buildMaintenanceHistoryView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Maintenance & ROI Tracker", 
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const Text("Financial impact of predictive interventions", style: TextStyle(color: Colors.white38)),
          const SizedBox(height: 40),

          // --- ROI Breakdown Cards ---
          Row(
            children: [
              _buildROICard("Net Savings", "₹35,27,500", "+12% vs last month", Colors.greenAccent),
              const SizedBox(width: 20),
              _buildROICard("Failures Prevented", "24", "LightGBM Accuracy: 99%", Colors.blueAccent),
              const SizedBox(width: 20),
              _buildROICard("MTBF Improvement", "+18hrs", "Mean Time Between Failures", Colors.orangeAccent),
            ],
          ),
          const SizedBox(height: 40),

          // --- Savings Chart & Event Log ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Savings Trend
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: const Color(0xFF161618), borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Savings Trend (USD)", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 40),
                      SizedBox(height: 250, child: _buildSavingsLineChart()),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Recent Interventions
              Expanded(
                flex: 2,
                child: _buildInterventionList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildROICard(String label, String value, String sub, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF161618),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(height: 12),
            Text(sub, style: const TextStyle(color: Colors.white24, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildInterventionList() {
    final events = [
      {"m": "CNC-01", "date": "Oct 12", "saved": "₹3,48,600", "type": "Critical Tool Wear"},
      {"m": "Lathe-04", "date": "Oct 10", "saved": "₹1,49,400", "type": "Overstrain Warning"},
      {"m": "Drill-02", "date": "Oct 05", "saved": "₹74,700", "type": "Routine Optimization"},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF161618), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Recent AI Interventions", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ...events.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e['m']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(e['type']!, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(e['saved']!, style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                    Text(e['date']!, style: const TextStyle(color: Colors.white24, fontSize: 11)),
                  ],
                )
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildSavingsLineChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [FlSpot(0, 10), FlSpot(1, 15), FlSpot(2, 12), FlSpot(3, 25), FlSpot(4, 30), FlSpot(5, 42)],
            isCurved: true,
            color: Colors.greenAccent,
            barWidth: 4,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: Colors.greenAccent.withOpacity(0.1)),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.greenAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.sync, color: Colors.greenAccent, size: 14),
          SizedBox(width: 8),
          Text("SYSTEM SYNCED", style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}