import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../widgets/top_bar.dart';
import '../widgets/nearby_devices.dart';
import '../widgets/sos_received.dart';
import '../widgets/push_sos_button.dart';
import '../widgets/map_card.dart';
import '../widgets/bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,

      body: SafeArea(
        child: Column(
          children: [
            // 🔵 MAIN CONTENT
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const TopBar(),
                    const SizedBox(height: 10),

                    Row(
                      children: const [
                        Expanded(child: NearbyDevices()),
                        Expanded(child: SOSReceived()),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const PushSOSButton(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // 📍 MAP CARD (ABOVE BOTTOM NAV, RIGHT SIDE)
            const Padding(
              padding: EdgeInsets.only(right: 10, bottom: 8),
              child: Align(alignment: Alignment.centerRight, child: MapCard()),
            ),

            // 🔻 BOTTOM NAV
            const BottomNav(),
          ],
        ),
      ),
    );
  }
}
