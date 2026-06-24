import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../social/views/social_tab_view.dart';
import 'dma_technologies_view.dart';

class DmaTechnologiesShellView extends StatefulWidget {
  const DmaTechnologiesShellView({super.key});

  @override
  State<DmaTechnologiesShellView> createState() =>
      _DmaTechnologiesShellViewState();
}

class _DmaTechnologiesShellViewState extends State<DmaTechnologiesShellView> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[const DmaTechnologiesGrid(), const SocialTabView()];

    return Scaffold(
      backgroundColor: const Color(0xffebffff),
      extendBody: true,
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            iconSize: 28,

            selectedItemColor: const Color(0xff0370c3),
            unselectedItemColor: Colors.blueGrey,

            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 12),

            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'DMA',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.groups_outlined),
                activeIcon: const Icon(Icons.groups),
                label: 'social'.tr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
