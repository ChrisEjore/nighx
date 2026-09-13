import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 1. Request local storage/media permissions on Android
    if (Platform.isAndroid) {
      await [
        Permission.audio,
        Permission.videos,
        Permission.storage,
      ].request();
    }

    // 2. Splash duration
    await Future.delayed(const Duration(seconds: 4));

    // 3. Navigate to Login
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 3D Soundwave
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepOrange.shade900.withOpacity(0.3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepOrange.withOpacity(0.6),
                    blurRadius: 30,
                    spreadRadius: 10,
                  )
                ],
              ),
              child: const SpinKitWave(
                color: Colors.deepOrange,
                size: 80.0,
                itemCount: 7,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'ODI WA TURKANA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Live from Kakuma, Turkana 🇰🇪',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}