import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../home/widgets/lottery_table_widget.dart';
import 'history_controller.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HistoryController());

    return Column(
      children: [
        // Region Selector (Reusing similar style from Home)
        Container(
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
        ),

        Expanded(
          child: Obx(() {
            if (controller.isLoading.value &&
                controller.historyResults.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.historyResults.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_toggle_off,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có dữ liệu lịch sử',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

              return RefreshIndicator(
                onRefresh: () => controller.loadHistory(refresh: true),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.groupedResults.length + 1,
                  itemBuilder: (context, index) {
                    if (index == controller.groupedResults.length) {
                      return controller.hasMore.value
                          ? Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: TextButton(
                                  onPressed: () => controller.loadHistory(),
                                  child: const Text('Xem thêm'),
                                ),
                              ),
                            )
                          : const SizedBox(height: 20);
                    }
                    
                    final dateKey = controller.groupedResults.keys.elementAt(index);
                    final results = controller.groupedResults[dateKey] ?? [];
                    
                    return LotteryTableWidget(
                      date: results.first.date,
                      results: results,
                    );
                  },
                ),
              );
          }),
        ),
      ],
    );
  }

  Widget _buildRegionTab(
    HistoryController controller,
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
              border: Border(
                bottom: BorderSide(
                  color: isSelected ? color : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? color : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }),
    );
  }
}
