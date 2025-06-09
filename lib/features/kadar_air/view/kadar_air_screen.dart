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
  bool isSystemActive = false;
  double? currentMoisture = 0.0;

  void toggleSystem() async {
    final moisture = currentMoisture ?? 0.0;
    KadarairModel? data = await Kadaraircontroller.getDataKadarAir();
    if (data != null) {
      setState(() {
        currentMoisture = data.kadar_air!.toDouble();
        isSystemActive = data.status_kadar_air!;
      });
    }
  }

  Future<void> fetchMoistureData() async {
    KadarairModel? data = await Kadaraircontroller.getDataKadarAir();
    if (data != null) {
      setState(() {
        currentMoisture = data.kadar_air!.toDouble();
        isSystemActive = data.status_kadar_air!;
      });
    }
  }

  @override
  void initState() {
    fetchMoistureData();
    super.initState();
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
                      "Kadar Air",
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
                          "${currentMoisture!.toStringAsFixed(1)}",
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
                          width:
                              MediaQuery.of(context).size.width * (65 / 100) -
                                  40,
                          decoration: BoxDecoration(
                            color: _getMoistureColor(currentMoisture!),
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
                          _getMoistureStatus(currentMoisture!),
                          style: TextStyle(
                            color: _getMoistureColor(currentMoisture!),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: toggleSystem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Appcolor.splashColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Melihat Kadar Air",
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
    if (value > 40) return "Masih Basah";
    if (value >= 20 && value <= 40) return "Sedang Luamayan Kering";
    if (value > 14 && value < 20) return "Sudah Kering";
    if (value <= 14) return "Sangat Kering";
    return "Tidak Terdeteksi";
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
