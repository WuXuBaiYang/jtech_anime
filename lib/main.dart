import 'package:flutter/material.dart';
import 'package:jtech_anime/common/route.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'JTech Anime',
      routerConfig: RoutePath.routers,
    );
  }
}
