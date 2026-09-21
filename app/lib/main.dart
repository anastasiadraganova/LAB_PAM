import 'package:flutter/material.dart';

void main() {
  runApp(const EventHubApp());
}

/// Application root. The design system, routing and state arrive in later
/// stages; for now this is an empty shell that boots and renders.
class EventHubApp extends StatelessWidget {
  const EventHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'EventHub',
      home: Scaffold(body: SizedBox.shrink()),
    );
  }
}
