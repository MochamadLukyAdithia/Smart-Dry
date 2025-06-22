import 'package:day_night_switch/day_night_switch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_dry/common/widgets/CircularProgress.dart';
import 'package:smart_dry/core/theme/AppColor.dart';
import 'package:smart_dry/features/home/controller/HomeController.dart';
import 'package:smart_dry/features/setting/controller/SettingController.dart';
import 'package:smart_dry/features/setting/model/suhu_model.dart';

class ThermostatScreen extends StatefulWidget {
  const ThermostatScreen({Key? key}) : super(key: key);

  @override
  _ThermostatScreenState createState() => _ThermostatScreenState();
}

class _ThermostatScreenState extends State<ThermostatScreen>
    with SingleTickerProviderStateMixin {
  bool isProtectMode = false;
  bool isHeaterMode = false;
  bool isFan = false;
  int selectedModeIndex = 0; // This will be the single source of truth
  bool fanStaus = false;
  int? currentTemperatur;
  int? batasanSuhu;

  // List of modes
  final List<Map<String, dynamic>> modes = [
    {'icon': Icons.auto_mode, 'name': 'Auto', 'value': 'auto'},
    {'icon': Icons.man, 'name': 'Manual', 'value': 'manual'},
    {'icon': Icons.water_drop, 'name': "Humadity", 'value': 'humidity'},
    {'icon': Icons.settings, 'name': 'Setting', 'value': 'setting'},
  ];

  // Get current mode based on selectedModeIndex
  String get currentMode => modes[selectedModeIndex]['value'];

  // Check if current mode is auto
  bool get isAutoMode => currentMode == "auto";

  late AnimationController _animationController;
  late Animation<double> _animation;

  Future<void> getBatasanSuhu() async {
    final resp = await SettingController.getBatasanSuhu();
    setState(() {
      currentTemperatur = resp.current_temperature ?? 0;
      batasanSuhu = resp.batasan_suhu ?? 0;

      if (currentTemperatur == null) {
        currentTemperatur = 0;
      }
    });

    // Update fan status in database based on temperature comparison
    await updateFanStatus();

    // Then get the updated fan status from database
    await getFanStatus();
  }

  Future<void> updateFanStatus() async {
    if (currentTemperatur != null && batasanSuhu != null) {
      bool shouldFanBeOn = currentTemperatur! > batasanSuhu!;
      // Update fan status to database
      await Homecontroller.updateFanStatus(shouldFanBeOn);
    }
    if (isHeaterMode == false) {
      // If heater mode is off, ensure fan is also off
      await Homecontroller.updateFanStatus(false);
      setState(() {
        isFan = false;
      });
    } else {
      // If heater mode is on, update fan status based on temperature
      setState(() {
        isFan = currentTemperatur! > batasanSuhu!;
      });
    }
  }

  Future<void> getFanStatus() async {
    // Get current fan status from database
    final fanStatus = await Homecontroller.getFanStatus();
    setState(() {
      isFan = fanStatus ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    getBatasanSuhu();
    // Initialize with auto mode
    selectedModeIndex = 0;
    Homecontroller.updateModePengeringan("auto");
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 4).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTopCard(),
          _buildPowerToggle(
            title: "Protect ",
            icon: Icons.shield,
            padding: 155,
            status: isProtectMode,
            onChanged: (value) {
              if (isAutoMode) {
                _showAutoModeDialog();
                return;
              }
              setState(() {
                isProtectMode = value;
                // Update protect mode controller
                Homecontroller.updateProtectMode(value);
              });
            },
          ),
          _buildPowerToggle(
            title: "Pemanas ",
            icon: Icons.hot_tub,
            padding: 140,
            status: isHeaterMode,
            onChanged: (value) {
              if (isAutoMode) {
                _showAutoModeDialog();
                return;
              }
              setState(() {
                isHeaterMode = value;
                // Update heater mode controller
                Homecontroller.updateHeaterMode(value);
              });
            },
          ),
          const SizedBox(height: 15),
          _buildTemperatureControl(),
          const SizedBox(height: 5),
          _buildMenu(),
          _buildModeSelection(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _showAutoModeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Appcolor.splashColor,
                size: 24,
              ),
              SizedBox(width: 10),
              Text(
                'Mode Auto Aktif',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Anda sedang dalam mode Auto. Sistem akan mengatur pemanas dan protect secara otomatis berdasarkan kondisi suhu dan kelembaban.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Appcolor.splashColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Appcolor.splashColor,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ubah ke mode Manual untuk mengontrol secara custom',
                        style: TextStyle(
                          fontSize: 12,
                          color: Appcolor.splashColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Tetap Auto',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _switchToManualMode();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Appcolor.splashColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Ubah ke Manual',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _switchToManualMode() {
    setState(() {
      selectedModeIndex = 1; // Manual mode index
    });
    Homecontroller.updateModePengeringan("manual");
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Smart Dry Box',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_active_outlined,
            color: Colors.black,
            size: 24,
          ),
          onPressed: () {
            context.go("/notifikasi");
          },
        ),
        SizedBox(
          width: 10,
        )
      ],
    );
  }

  Widget _buildMenu() {
    return Padding(
      padding: EdgeInsets.all(10),
    );
  }

  Widget _buildTopCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              // Use combined status for gradient color
              (isProtectMode || isHeaterMode)
                  ? Appcolor.splashColor
                  : Appcolor.different,
              (isProtectMode || isHeaterMode)
                  ? Appcolor.splashColor
                  : Appcolor.different,
              (isProtectMode || isHeaterMode)
                  ? Appcolor.splashColor.withOpacity(0.8)
                  : Appcolor.different.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Appcolor.splashColor.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Smart Dry Box Status",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                (isProtectMode || isHeaterMode)
                                    ? Icons.check_circle
                                    : Icons.error,
                                color: (isProtectMode || isHeaterMode)
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                (isProtectMode || isHeaterMode)
                                    ? "Active"
                                    : "Inactive",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                isFan ? Icons.wind_power : Icons.mode_fan_off,
                                color: isFan ? Colors.green : Colors.red,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Fan : ${isFan ? "On" : "Off"}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: _buildStatusIcon(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    if (isProtectMode && isHeaterMode) {
      // Both modes active - show combined icon or priority icon
      return Icon(
        Icons.security,
        size: 80,
        color: Appcolor.sunColor,
      );
    } else if (isProtectMode) {
      // Only protect mode active
      return Icon(
        Icons.shield,
        size: 80,
        color: Appcolor.splashColor,
      );
    } else if (isHeaterMode) {
      // Only heater mode active
      return Icon(
        Icons.local_fire_department,
        size: 80,
        color: Appcolor.sunColor,
      );
    } else {
      // Both modes inactive
      return Icon(
        Icons.power_off,
        size: 80,
        color: Colors.grey,
      );
    }
  }

  Widget _buildPowerToggle({
    String? title,
    IconData? icon,
    double? padding,
    bool status = false,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(
                icon,
                color: status
                    ? Appcolor.splashColor
                    : (isAutoMode ? Colors.grey : Appcolor.different),
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                '${title}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isAutoMode ? Colors.grey : Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(
            width: padding ?? 110,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Handle tap based on mode
                if (isAutoMode) {
                  _showAutoModeDialog();
                } else {
                  onChanged(!status);
                }
              },
              child: Transform.scale(
                scale: 0.4,
                child: DayNightSwitch(
                  dayColor:
                      isAutoMode ? Colors.grey.shade300 : Appcolor.different,
                  nightColor:
                      isAutoMode ? Colors.grey.shade400 : Appcolor.splashColor,
                  value: status,
                  onChanged: isAutoMode ? null : onChanged,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureControl() {
    return StreamBuilder<SuhuModel>(
      stream: Homecontroller.streamDataSuhu(userId: 1),
      builder: (context, snapshot) {
        final suhu = snapshot.data;

        final currentTemp = suhu?.current_temperature ?? 0;
        final progressValue = _animation.value;

        return Expanded(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 180,
                  height: 180,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: CircularProgressPainter(
                          progress: progressValue,
                          color: (isProtectMode || isHeaterMode)
                              ? Appcolor.splashColor
                              : Appcolor.different,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${currentTemp.toStringAsFixed(0)}°C',
                                style: const TextStyle(
                                  fontSize: 50,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const Text(
                                'Current Temperature',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget _buildTemperatureControl() {
  //   return Expanded(
  //     child: Center(
  //       child: Stack(
  //         alignment: Alignment.center,
  //         children: [
  //           Container(
  //             width: 220,
  //             height: 220,
  //             child: AnimatedBuilder(
  //               animation: _animation,
  //               builder: (context, child) {
  //                 return CustomPaint(
  //                   painter: CircularProgressPainter(
  //                     progress: _animation.value,
  //                     color: (isProtectMode || isHeaterMode)
  //                         ? Appcolor.splashColor
  //                         : Appcolor.different,
  //                   ),
  //                   child: Container(
  //                     padding: const EdgeInsets.all(20),
  //                     child: Column(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         Text(
  //                           '${currentTemperatur}°C',
  //                           style: const TextStyle(
  //                             fontSize: 50,
  //                             fontWeight: FontWeight.bold,
  //                             fontFamily: 'Poppins',
  //                           ),
  //                         ),
  //                         Text(
  //                           'Current Temperature',
  //                           style: TextStyle(
  //                             fontSize: 14,
  //                             color: Colors.black,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 );
  //               },
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildModeSelection() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(modes.length, (index) {
          return _buildModeItem(index);
        }),
      ),
    );
  }

  Widget _buildModeItem(int index) {
    final mode = modes[index];
    final isSelected = index == selectedModeIndex;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedModeIndex = index;
        });

        if (mode['value'] == 'auto') {
          Homecontroller.updateModePengeringan('auto');
        } else if (mode['value'] == 'manual') {
          Homecontroller.updateModePengeringan('manual');
        } else if (mode['value'] == 'humidity') {
          context.go("/kadar_air");
        } else if (mode['value'] == 'setting') {
          context.go("/setting");
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: isSelected
                  ? Appcolor.splashColor.withOpacity(0.1)
                  : Colors.white,
              shape: BoxShape.circle,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: (isProtectMode || isHeaterMode)
                            ? Appcolor.splashColor.withOpacity(0.2)
                            : Appcolor.different.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              mode['icon'],
              color: isSelected
                  ? (isProtectMode || isHeaterMode)
                      ? Appcolor.splashColor
                      : Appcolor.different
                  : Colors.grey,
              size: isSelected ? 26 : 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mode['name'],
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? Appcolor.splashColor : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
