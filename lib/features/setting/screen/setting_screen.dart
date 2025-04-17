import 'package:flutter/material.dart';
import 'package:smart_dry/core/theme/AppColor.dart';

class SettingScreen extends StatelessWidget {
  final batasanSuhu;
  const SettingScreen({super.key, this.batasanSuhu});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pengaturan"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              color: Appcolor.primaryColor,
              child: Text("Batasan Suhu {$batasanSuhu}"),
            ),
            ListTile(
              
            )
          ],
        ),
      ),
    );
  }
}
