import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_dry/core/theme/AppColor.dart';
import 'package:smart_dry/features/auth/controller/AuthController.dart';
import 'package:smart_dry/features/setting/controller/SettingController.dart';

class SettingScreen extends StatefulWidget {
  final double batasanSuhu;
  const SettingScreen({super.key, this.batasanSuhu = 40.0});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late double currentTemperature;
  double? currentTemperatureLimit;
  bool isDarkMode = false;
  bool notifications = true;

  @override
  void initState() {
    super.initState();
    currentTemperature = widget.batasanSuhu;
    getBatasanSuhu();
  }

  Future<void> getBatasanSuhu() async {
    final resp = await SettingController.getBatasanSuhu();
    setState(() {
      currentTemperatureLimit = resp.batasan_suhu?.toDouble() ?? 100.0;
    });
  }

  void _showAlert(String title, String message, {bool isSuccess = true}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              color: Appcolor.splashColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(color: Appcolor.different),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Appcolor.splashColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Appcolor.primaryColor,
        );
      },
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Log Out',
            style: TextStyle(
              color: Appcolor.splashColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: TextStyle(color: Appcolor.different),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Appcolor.different),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Appcolor.splashColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Log Out'),
              onPressed: () async {
                final resp = await AuthController.logout();
                Navigator.of(context).pop();
                if (resp) {
                  _showAlert('Success', 'Logged out successfully');
                  context.go('/login');
                } else {
                  _showAlert('Error', 'Failed to log out', isSuccess: false);
                }
              },
            ),
          ],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Appcolor.primaryColor,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Appcolor.primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(
            color: Appcolor.splashColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Appcolor.splashColor),
          onPressed: () {
            context.go('/home');
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Appcolor.splashColor),
            tooltip: 'Refresh',
            onPressed: () async {
              await getBatasanSuhu();
              _showAlert('Success', 'Temperature limit refreshed');
            },
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),

            Text(
              'Temperature Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Appcolor.splashColor,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Appcolor.different.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Batasan Suhu',
                        style: TextStyle(
                          fontSize: 16,
                          color: Appcolor.different,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Appcolor.splashColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${currentTemperatureLimit}°C',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Appcolor.splashColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width / 3.2,
                          vertical: 8),
                      decoration: BoxDecoration(
                        color: Appcolor.splashColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${currentTemperature.toStringAsFixed(0)}°C',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Appcolor.splashColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.ac_unit, color: Appcolor.dayColor),
                      Expanded(
                        child: Slider(
                          value: currentTemperature,
                          min: 10.0,
                          max: 200.0,
                          divisions: 90,
                          activeColor: Appcolor.splashColor,
                          inactiveColor: Appcolor.different.withOpacity(0.2),
                          thumbColor: Appcolor.splashColor,
                          onChanged: (value) {
                            setState(() {
                              currentTemperature = value;
                            });
                          },
                        ),
                      ),
                      Icon(Icons.whatshot, color: Colors.redAccent),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Appcolor.splashColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        await SettingController.updateBatasanSuhu(
                            currentTemperature.toInt());

                        _showAlert('Success', 'Temperature setting saved');
                      },
                      child: const Text(
                        'Save Temperature Setting',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Text(
              'App Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Appcolor.splashColor,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Appcolor.different.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [],
              ),
            ),

            const SizedBox(height: 30),

            // Logout Button
            Center(
              child: TextButton.icon(
                icon: Icon(
                  Icons.logout,
                  color: Colors.redAccent,
                ),
                label: Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _logout,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
