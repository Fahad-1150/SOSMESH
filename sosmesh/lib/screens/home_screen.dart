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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize services after first frame
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TopBar(),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: NearbyDevices()),
                        Expanded(child: SOSReceived()),
                      ],
                    ),
                    const SizedBox(height: 20),
                    PushSOSButton(),
                    const SizedBox(height: 20),
                    MapCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            BottomNav(),
          ],
        ),
      ),
    );
  }
}
