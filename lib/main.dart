import 'package:flutter/material.dart';
import 'package:flutter_application_1/module/result.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smoothie',
      home: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
              title:
                  const Text('Smoothie', style: TextStyle(color: Colors.white)),
              backgroundColor: const Color.fromRGBO(228, 93, 93, 100)),
          body: const Center(
            child: SingleChildScrollView(
              child: Column(
                children: [SizedBox(height: 50), Result()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
