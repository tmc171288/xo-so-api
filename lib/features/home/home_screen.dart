import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/socket_service.dart';
import 'home_controller.dart';
import 'widgets/lottery_result_widget.dart';
import '../history/history_screen.dart';

/// Home Screen - Main screen of the app
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          switch (controller.selectedIndex.value) {
            case 0: return const Text('Xổ Số Trực Tiếp');
            case 1: return const Text('Lịch Sử Kết Quả');
            case 2: return const Text('Dự Đoán');
            case 3: return const Text('Cài Đặt');
            default: return const Text('Xổ Số Trực Tiếp');
          }
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
      body: Obx(() => IndexedStack(
        index: controller.selectedIndex.value,
        children: [
          _buildHomeContent(controller),
          const HistoryScreen(),
          const Center(child: Text("Dự đoán (Coming Soon)")),
          const Center(child: Text("Cài đặt (Coming Soon)")),
        ],
      )),
      bottomNavigationBar: _buildBottomNavigation(controller),
    );
  }

  Widget _buildHomeContent(HomeController controller) {
    return Column(
      children: [
        // Region selector
        _buildRegionSelector(controller),

        // Connection status
        Obx(() {
          final socketService = Get.find<SocketService>();
          return socketService.isConnected.value
              ? Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  color: AppColors.success.withOpacity(0.1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Đang kết nối trực tiếp',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  color: AppColors.warning.withOpacity(0.1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.warning,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Đang kết nối...',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
        }),

        // Results list
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (controller.liveResults.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: controller.refresh,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.liveResults.length,
                itemBuilder: (context, index) {
                  final result = controller.liveResults[index];
                  return LotteryResultWidget(result: result);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Build region selector tabs
  Widget _buildRegionSelector(HomeController controller) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          _buildRegionTab(
            controller,
            'north',
            'Miền Bắc',
            AppColors.northColor,
          ),
          _buildRegionTab(
            controller,
            'central',
            'Miền Trung',
            AppColors.centralColor,
          ),
          _buildRegionTab(
            controller,
            'south',
            'Miền Nam',
            AppColors.southColor,
          ),
        ],
      ),
    );
  }

  /// Build individual region tab
  Widget _buildRegionTab(
    HomeController controller,
    String region,
    String label,
    Color color,
  ) {
    return Expanded(
      child: Obx(() {
        final isSelected = controller.selectedRegion.value == region;
        return InkWell(
          onTap: () => controller.changeRegion(region),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color: isSelected ? color : Colors.grey.shade300,
                  width: isSelected ? 3 : 1,
                ),
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Chưa có kết quả',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kéo xuống để làm mới',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  /// Build bottom navigation
  Widget _buildBottomNavigation(HomeController controller) {
    return Obx(() => BottomNavigationBar(
      currentIndex: controller.selectedIndex.value,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Trang chủ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          activeIcon: Icon(Icons.history),
          label: 'Lịch sử',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.lightbulb_outline),
          activeIcon: Icon(Icons.lightbulb),
          label: 'Dự đoán',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Cài đặt',
        ),
      ],
      onTap: controller.changeIndex,
    ));
  }
}
