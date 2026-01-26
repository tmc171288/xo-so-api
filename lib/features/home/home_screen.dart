import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/socket_service.dart';
import 'home_controller.dart';
import 'widgets/lottery_result_widget.dart';
import 'widgets/next_draw_widget.dart';
import '../history/history_screen.dart';

/// Home Screen - Main screen of the app
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Obx(
      () => Scaffold(
        appBar: AppBar(
          backgroundColor: _getThemeColor(controller.selectedIndex.value),
          title: Text(_getTitle(controller.selectedIndex.value)),
          actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
               showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Lịch Quay Thưởng', textAlign: TextAlign.center),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      ListTile(
                        leading: Icon(Icons.access_time, color: AppColors.southColor),
                        title: Text('Miền Nam'),
                        trailing: Text('16:15', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      ListTile(
                        leading: Icon(Icons.access_time, color: AppColors.centralColor),
                        title: Text('Miền Trung'),
                        trailing: Text('17:15', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      ListTile(
                        leading: Icon(Icons.access_time, color: AppColors.northColor),
                        title: Text('Miền Bắc'),
                        trailing: Text('18:15', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      // ignore: use_build_context_synchronously
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Đóng'),
                    )
                  ],
                ),
              );
            },
          ),
          ],
        ),
        body: IndexedStack(
          index: controller.selectedIndex.value,
          children: [
            _buildHomeContent(controller),
            const HistoryScreen(),
            const Center(child: Text("Dự đoán (Coming Soon)")),
            const Center(child: Text("Cài đặt (Coming Soon)")),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigation(controller),
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Xổ Số Trực Tiếp';
      case 1:
        return 'Lịch Sử Kết Quả';
      case 2:
        return 'Dự Đoán';
      case 3:
        return 'Cài Đặt';
      default:
        return 'Xổ Số Trực Tiếp';
    }
  }

  Color _getThemeColor(int index) {
    switch (index) {
      case 0:
        return AppColors.tabDirect;
      case 1:
        return AppColors.tabHistory;
      case 2:
        return AppColors.tabPrediction;
      case 3:
        return AppColors.tabSettings;
      default:
        return AppColors.primary;
    }
  }

  Widget _buildHomeContent(HomeController controller) {
    return Column(
      children: [
        // Region selector (Pinned)
        _buildRegionSelector(controller),

        // Scrollable Content (Status + NextDraw + Results)
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final results = controller.liveResults;
            // Always show header (Status + Next Draw)
            // If results empty, show EmptyState as second item
            
            return RefreshIndicator(
              onRefresh: controller.refresh,
              child: ListView.builder(
                padding: const EdgeInsets.all(0),
                itemCount: results.isEmpty ? 2 : results.length + 1,
                itemBuilder: (context, index) {
                  // Header: Status + NextDrawWidget
                  if (index == 0) {
                    return Column(
                      children: [
                        _buildConnectionStatus(),
                        Obx(() => NextDrawWidget(region: controller.selectedRegion.value)),
                      ],
                    );
                  }

                  // Empty State
                  if (results.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 32.0),
                      child: _buildEmptyState(),
                    );
                  }

                  // Result Items
                  final result = results[index - 1];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: LotteryResultWidget(result: result),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildConnectionStatus() {
    return Obx(() {
      final socketService = Get.find<SocketService>();
      return socketService.isConnected.value
          ? Container(
              width: double.infinity,
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
              width: double.infinity,
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
    });
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
        // Check for south region to change text color (Black for South/Yellow, White for others)
        // Actually the requested design might want standard tab text color, but the 'Selected' state logic is here.
        // Screen shows 'Bến Tre' (Header) with yellow bg. The Tabs are separate.
        // Let's keep logic: if selected, use 'color' (background) and White text usually.
        // BUT for South (Yellow), White text is bad.
        // So:
        Color textColor = isSelected ? Colors.white : AppColors.textSecondary;
        if (isSelected && region == 'south') textColor = Colors.black;

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
                color: textColor,
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
    return Obx(
      () => CurvedNavigationBar(
        index: controller.selectedIndex.value,
        height: 60.0,
        items: const <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.history, size: 30, color: Colors.white),
          Icon(Icons.lightbulb, size: 30, color: Colors.white),
          Icon(Icons.settings, size: 30, color: Colors.white),
        ],
        color: _getThemeColor(controller.selectedIndex.value),
        buttonBackgroundColor: _getThemeColor(controller.selectedIndex.value),
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          controller.changeIndex(index);
        },
        letIndexChange: (index) => true,
      ),
    );
  }
}
