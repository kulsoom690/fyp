// widget_tree.dart
import 'package:flutter/material.dart';
import "package:firebase_auth/firebase_auth.dart";

import 'auth.dart';
import 'auth/login._screen.dart';
import 'dashboard/dashboard_screen.dart';
// Your main dashboard

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  final Auth _auth = Auth();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return const DashboardScreen();
          }
          return const LoginScreen();
        }
        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: CircularProgressIndicator(color: Colors.blueAccent.shade200),
          ),
        );
      },
    );
  }
}
