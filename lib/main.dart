import 'package:flutter/material.dart';
import 'package:flutter_bottom_nav/Activities/splashscreen_activity.dart';
import 'package:flutter_bottom_nav/models/route_observer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Tracker',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Color(0xFF17479E))),
      home: const MyHomePage(title: 'Smart Tracker'),
      navigatorObservers: [routeObserver],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashscreenActivity(),
    );
  }
}
