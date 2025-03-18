import 'package:day_night_switch/day_night_switch.dart';
import 'package:flutter/material.dart';
import 'package:smart_dry/core/theme/AppColor.dart';

import 'dart:math';

class ThermostatScreen extends StatefulWidget {
  const ThermostatScreen({Key? key}) : super(key: key);

  @override
  _ThermostatScreenState createState() => _ThermostatScreenState();
}

class _ThermostatScreenState extends State<ThermostatScreen>
    with SingleTickerProviderStateMixin {
  bool isPowerOn = true;
  int selectedRoomIndex = 0;
  int selectedModeIndex = 0;
  double currentTemperature = 24;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<Map<String, dynamic>> modes = [
    {'icon': Icons.auto_mode, 'name': 'Auto', 'isSelected': true},
    {'icon': Icons.wb_sunny, 'name': 'Heat', 'isSelected': false},
    {'icon': Icons.water_drop, 'name': 'Dry', 'isSelected': false},
  ];

  @override
  void initState() {
    super.initState();
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
          _buildPowerToggle(),
          _buildTemperatureControl(),
          const SizedBox(height: 20),
          _buildModeSelection(),
          const SizedBox(height: 30),
        ],
      ),
    );
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
          onPressed: () {},
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
              isPowerOn ? Appcolor.splashColor : Appcolor.different,
              isPowerOn ? Appcolor.splashColor : Appcolor.different,
              isPowerOn
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
            // Decorative elements
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
                  const Text(
                    "Smart Dry Box Status",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isPowerOn ? Icons.check_circle : Icons.error,
                                color: isPowerOn
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isPowerOn ? "Active" : "Inactive",
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
                              const Icon(
                                Icons.thermostat,
                                color: Colors.white70,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Current: ${currentTemperature.toStringAsFixed(1)}°C",
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
                              const Icon(
                                Icons.water_drop,
                                color: Colors.white70,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Humidity: 45%",
                                style: TextStyle(
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
                            // color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPowerOn ? Icons.nightlight_round : Icons.sunny,
                            size: 80,
                            color: isPowerOn
                                ? Appcolor.moonColor
                                : Appcolor.sunColor,
                          )),
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

  Widget _buildPowerToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                Icons.shield,
                color: isPowerOn ? Appcolor.splashColor : Appcolor.different,
                size: 22,
              ),
              const SizedBox(width: 10),
              const Text(
                'Protect Mode',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Transform.scale(
              scale: 0.4,
              child: DayNightSwitch(
                dayColor: Appcolor.different,
                nightColor: Appcolor.splashColor,
                value: isPowerOn,
                onChanged: (value) {
                  setState(() {
                    isPowerOn = value;
                  });
                },
              ),
            ),
          )
          // Switch(
          //   value: isPowerOn,
          //   onChanged: (value) {
          //     setState(() {
          //       isPowerOn = value;
          //     });
          //   },
          //   activeColor: Colors.blue,
          // ),
        ],
      ),
    );
  }

  Widget _buildTemperatureControl() {
    return Expanded(
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 40,
              child: Text(
                '10°',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
              ),
            ),
            Positioned(
              top: 40,
              child: Text(
                '20°',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
              ),
            ),
            Positioned(
              right: 40,
              child: Text(
                '30°',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
              ),
            ),

            // Circular progress indicator
            Container(
              width: 220,
              height: 220,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: CircularProgressPainter(
                      progress: _animation.value,
                      color:
                          isPowerOn ? Appcolor.splashColor : Appcolor.different,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${currentTemperature.toInt()}°',
                            style: const TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Outside',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                '14°',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // // Draggable thumb
            // GestureDetector(
            //   onPanUpdate: (details) {
            //     _updateTemperatureFromGesture(details, 220);
            //   },
            //   child: Container(
            //     padding: const EdgeInsets.all(25),
            //     decoration: BoxDecoration(
            //       shape: BoxShape.circle,
            //       color: Colors.transparent,
            //     ),
            //     child: Positioned(
            //       top: 40,
            //       right: 80,
            //       child: Container(
            //         width: 22,
            //         height: 22,
            //         decoration: BoxDecoration(
            //           color: Colors.white,
            //           shape: BoxShape.circle,
            //           boxShadow: [
            //             BoxShadow(
            //               color: Appcolor.splashColor.withOpacity(0.3),
            //               blurRadius: 5,
            //               offset: const Offset(0, 2),
            //             ),
            //           ],
            //         ),
            //         child: Center(
            //           child: Container(
            //             width: 8,
            //             height: 8,
            //             decoration: BoxDecoration(
            //               color: Appcolor.splashColor,
            //               shape: BoxShape.circle,
            //             ),
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // void _updateTemperatureFromGesture(DragUpdateDetails details, double size) {
  //   // Calculate the center of the circle
  //   final RenderBox box = context.findRenderObject() as RenderBox;
  //   final center = box.size.center(Offset.zero);

  //   // Adjust by the widget's position on screen
  //   final localPosition = box.globalToLocal(details.globalPosition);

  //   // Calculate the angle
  //   final deltaX = localPosition.dx - center.dx;
  //   final deltaY = localPosition.dy - center.dy;
  //   final angle = atan2(deltaY, deltaX);

  //   // Convert to temperature (adjust as needed for your scale)
  //   final newTemp = _calculateTemperatureFromAngle(angle);

  //   if (newTemp >= 10 && newTemp <= 30) {
  //     setState(() {
  //       currentTemperature = newTemp;
  //     });
  //   }
  // }

  // double _calculateTemperatureFromAngle(double angle) {
  //   // Map the angle (-π to π) to temperature range (10 to 30)
  //   // Starting from the right (0 radians) going clockwise
  //   // Adjust this mapping based on your dial orientation
  //   double temp = 20 + (angle / (pi / 10));

  //   // Normalize the temperature to be between 10 and 30
  //   if (temp < 10) temp = 10;
  //   if (temp > 30) temp = 30;

  //   return double.parse(temp.toStringAsFixed(1));
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
                        color: isPowerOn
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
                  ? isPowerOn
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

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircularProgressPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress circle
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5, // Start from top
      progress, // Animated portion of the circle
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
