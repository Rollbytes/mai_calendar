import 'package:flutter/material.dart';
import 'calendar_screen.dart';

/// 主頁面，包含底部導航欄和標籤頁
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1; // 當前選中的標籤索引，設為行事曆

  // 標籤頁列表
  final List<Widget> _pages = [
    // 空間頁面
    const PlaceholderScreen(title: '空間頁面'),
    // 行事曆頁面
    const CalendarScreen(),
    // 聊天頁面
    const PlaceholderScreen(title: '聊天頁面'),
    // 通知頁面
    const PlaceholderScreen(title: '通知頁面'),
  ];

  // 標籤頁標題
  final List<String> _titles = ['空間', '行事曆', '聊天', '通知'];

  // 標籤頁圖標
  final List<IconData> _icons = [
    Icons.space_dashboard, // 空間圖標
    Icons.calendar_month, // 行事曆圖標
    Icons.chat, // 聊天圖標
    Icons.notifications, // 通知圖標
  ];

  // 處理標籤點擊事件
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // 確保鍵盤彈出時調整畫面
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // 固定類型，以顯示所有標籤
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: List.generate(
          _titles.length,
          (index) => BottomNavigationBarItem(
            icon: Icon(_icons[index]),
            label: _titles[index],
          ),
        ),
      ),
    );
  }
}

/// 佔位屏幕，用於尚未實現的標籤頁
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // 頂部標題
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // 內容區域
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getIconForTitle(title),
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '此功能正在開發中',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 獲取對應標題的圖標
  IconData _getIconForTitle(String title) {
    switch (title) {
      case '空間頁面':
        return Icons.space_dashboard;
      case '聊天頁面':
        return Icons.chat;
      case '通知頁面':
        return Icons.notifications;
      default:
        return Icons.info;
    }
  }
}
