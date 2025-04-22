import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_dry/features/kadar_air/controller/KadarAirController.dart';
import 'package:smart_dry/features/kadar_air/model/kadarair_model.dart';

class KadarAirScreen extends StatefulWidget {
  KadarAirScreen({super.key});

  @override
  State<KadarAirScreen> createState() => _KadarAirScreenState();
}

class _KadarAirScreenState extends State<KadarAirScreen> {
  final controller = Kadaraircontroller();
  bool isSystemActive = false;
  double currentMoisture = 65.5; // Example value - replace with real data

  void toggleSystem() {
    setState(() {
      isSystemActive = !isSystemActive;
    });
    // Implement your system activation logic here
    // controller.toggleSystem(isSystemActive);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Appcolor.primaryColor,
      appBar: AppBar(
        backgroundColor: Appcolor.primaryColor,
        foregroundColor: Appcolor.splashColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/home');
          },
        ),
        title: Text(
          "Kadar Air",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24),

              // Simple moisture card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: Offset(0, 4),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Kadar Air Saat Ini",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${currentMoisture.toStringAsFixed(1)}",
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Appcolor.splashColor,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            "%",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Appcolor.splashColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Progress indicator
                    Stack(
                      children: [
                        Container(
                          height: 8,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Container(
                          height: 8,
                          width: MediaQuery.of(context).size.width *
                                  (currentMoisture / 100) -
                              40,
                          decoration: BoxDecoration(
                            color: _getMoistureColor(currentMoisture),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getMoistureStatus(currentMoisture),
                          style: TextStyle(
                            color: _getMoistureColor(currentMoisture),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSystemActive
                                ? Appcolor.splashColor.withOpacity(0.1)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isSystemActive ? "Aktif" : "Nonaktif",
                            style: TextStyle(
                              fontSize: 12,
                              color: isSystemActive
                                  ? Appcolor.splashColor
                                  : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Activation button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: toggleSystem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSystemActive
                        ? Colors.redAccent.withOpacity(0.9)
                        : Appcolor.splashColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isSystemActive ? "Matikan Sistem" : "Aktifkan Sistem",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getMoistureColor(double value) {
    if (value > 70) return Colors.blue;
    if (value > 40) return Appcolor.splashColor;
    return Colors.orange;
  }

  String _getMoistureStatus(double value) {
    if (value > 70) return "Tinggi";
    if (value > 40) return "Normal";
    return "Rendah";
  }
}

class Appcolor {
  static final Color primaryColor = Color.fromARGB(255, 255, 254, 252);
  static final Color splashColor = Color.fromARGB(255, 118, 55, 32);
  static final Color different = Color.fromARGB(255, 220, 157, 134);
  static final Color sunColor = const Color(0xFFFDB813);
  static final Color moonColor = const Color(0xFFf5f3ce);
  static final Color dayColor = const Color(0xFF87CEEB);
  static final Color nightColor = const Color(0xFF003366);
}
