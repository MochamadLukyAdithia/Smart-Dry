import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_dry/core/theme/AppColor.dart';

class SettingScreen extends StatefulWidget {
  final double batasanSuhu;
  const SettingScreen({super.key, this.batasanSuhu = 40.0});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late double currentTemperature;
  bool isDarkMode = false;
  bool notifications = true;

  @override
  void initState() {
    super.initState();
    currentTemperature = widget.batasanSuhu;
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
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/login');
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),

            // Temperature Control Section
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Temperature Limit',
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
                          '${currentTemperature.toStringAsFixed(1)}°C',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Appcolor.splashColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
                      onPressed: () {
                        // Save temperature logic here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Temperature limit updated to ${currentTemperature.toStringAsFixed(1)}°C'),
                            backgroundColor: Appcolor.splashColor,
                          ),
                        );
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

            // App Settings Section
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
                children: [
                  SwitchListTile(
                    title: Text(
                      'Dark Mode',
                      style: TextStyle(
                        fontSize: 16,
                        color: Appcolor.different,
                      ),
                    ),
                    value: isDarkMode,
                    activeColor: Appcolor.splashColor,
                    onChanged: (bool value) {
                      setState(() {
                        isDarkMode = value;
                      });
                    },
                    secondary: Icon(
                      Icons.dark_mode,
                      color: Appcolor.splashColor,
                    ),
                  ),
                  Divider(color: Appcolor.different.withOpacity(0.1)),
                  Divider(color: Appcolor.different.withOpacity(0.1)),
                  ListTile(
                    leading: Icon(
                      Icons.info_outline,
                      color: Appcolor.splashColor,
                    ),
                    title: Text(
                      'About App',
                      style: TextStyle(
                        fontSize: 16,
                        color: Appcolor.different,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Appcolor.different,
                    ),
                    onTap: () {},
                  ),
                ],
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
