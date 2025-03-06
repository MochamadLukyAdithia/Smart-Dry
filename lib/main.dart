import 'package:flutter/material.dart';
import 'package:smart_dry/features/splash/screen/splash_screen.dart';
import 'package:smart_dry/routes/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(
    primarySwatch: Colors.blue,
  ),
  routerConfig: router, 
);
  }
}
