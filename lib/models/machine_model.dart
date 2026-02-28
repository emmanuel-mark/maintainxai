import 'package:flutter/material.dart';

class Machine {
  final String id;
  final String name;
  final double failureProbability; // 0.0 to 1.0
  final Color statusColor;
  final double torque;
  final double rpm;
  final double toolWear;
  final double powerEstimate;
  final double tempDelta;
  final List<double> monthlyPerformance; // Dummy graph data

  Machine({
    required this.id,
    required this.name,
    required this.failureProbability,
    required this.statusColor,
    required this.torque,
    required this.rpm,
    required this.toolWear,
    required this.powerEstimate,
    required this.tempDelta,
    required this.monthlyPerformance,
  });
}

// Dummy Data matching your request (Red, Yellow, Green)
List<Machine> dummyMachines = [
  Machine(
    id: "M-001",
    name: "CNC Milling-01",
    failureProbability: 0.942,
    statusColor: Colors.redAccent,
    torque: 62.5,
    rpm: 2800,
    toolWear: 235.0,
    powerEstimate: 18.3,
    tempDelta: 14.2,
    monthlyPerformance: [80, 75, 60, 40, 20, 10], // Dropping performance
  ),
  Machine(
    id: "M-002",
    name: "Lathe-04",
    failureProbability: 0.487,
    statusColor: Colors.orangeAccent,
    torque: 40.1,
    rpm: 1500,
    toolWear: 110.0,
    powerEstimate: 6.2,
    tempDelta: 8.5,
    monthlyPerformance: [85, 82, 88, 70, 75, 65],
  ),
  Machine(
    id: "M-003",
    name: "Drill Press-02",
    failureProbability: 0.012,
    statusColor: Colors.greenAccent,
    torque: 25.2,
    rpm: 1200,
    toolWear: 15.0,
    powerEstimate: 3.1,
    tempDelta: 2.1,
    monthlyPerformance: [95, 96, 94, 98, 97, 95],
  ),
];