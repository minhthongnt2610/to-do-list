import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:to_do_list/constants/app_colors.dart';
import 'package:to_do_list/screens/all_tasks/all_tasks_screen.dart';
import 'package:to_do_list/screens/all_tasks/models/all_tasks_screen_arguments.dart';
import 'package:to_do_list/screens/chat/chat_screen.dart';
import 'package:to_do_list/screens/home/home_screen.dart';
import 'package:to_do_list/screens/new_task/models/new_task_screen_arguments.dart';
import 'package:to_do_list/screens/new_task/new_task_screen.dart';
import 'package:to_do_list/screens/profile/profile_screen.dart';

/// Enum định nghĩa các tab trong bottom navigation
enum _NavTab { home, tasks, chat, profile }

/// Shell màn hình chính chứa Bottom Navigation Bar
class MainScreen extends StatefulWidget {
  static const routeName = '/main';

  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  /// Tab đang active (chỉ Home và Profile là inline IndexedStack)
  _NavTab _activeTab = _NavTab.home;

  // Map _NavTab → IndexedStack index
  int get _stackIndex => _activeTab == _NavTab.profile ? 1 : 0;

  final List<Widget> _tabs = const [
    HomeScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.hex020206,
        body: IndexedStack(
          index: _stackIndex,
          children: _tabs,
        ),
        floatingActionButton: _buildFab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  /// FAB nút thêm task ở giữa bottom nav
  Widget _buildFab() {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.hexBA83DE, AppColors.hexDE83B0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.hexBA83DE.withValues(alpha: 0.45),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(29),
          onTap: _navigateToNewTaskScreen,
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }

  /// Bottom Navigation Bar tùy chỉnh với góc tròn
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.hex181818,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                tab: _NavTab.home,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
              ),
              _buildNavItem(
                tab: _NavTab.tasks,
                icon: Icons.task_alt_outlined,
                activeIcon: Icons.task_alt,
                label: 'Tasks',
                onTap: _navigateToAllTasksScreen,
              ),
              // Khoảng trống cho FAB giữa
              const SizedBox(width: 64),
              _buildNavItem(
                tab: _NavTab.chat,
                icon: Icons.auto_awesome_outlined,
                activeIcon: Icons.auto_awesome,
                label: 'AI Chat',
                onTap: _navigateToChatScreen,
              ),
              _buildNavItem(
                tab: _NavTab.profile,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required _NavTab tab,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    VoidCallback? onTap,
  }) {
    // Tasks và Chat là push route → không có trạng thái active trên bottom nav
    final bool isPushRoute = tab == _NavTab.tasks || tab == _NavTab.chat;
    final bool isActive = !isPushRoute && _activeTab == tab;

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap();
        } else {
          if (_activeTab != tab) {
            setState(() {
              _activeTab = tab;
            });
          }
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isActive
              ? AppColors.hexBA83DE.withValues(alpha: 0.12)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                color: isActive
                    ? AppColors.hexBA83DE
                    : Colors.white.withValues(alpha: 0.45),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? AppColors.hexBA83DE
                    : Colors.white.withValues(alpha: 0.45),
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToNewTaskScreen() async {
    await Navigator.of(context).pushNamed(
      NewTaskScreen.routeName,
      arguments: const NewTaskScreenArguments(taskModel: null),
    );
  }

  Future<void> _navigateToAllTasksScreen() async {
    await Navigator.of(context).pushNamed(
      AllTasksScreen.routeName,
      arguments: const AllTasksScreenArguments(),
    );
  }

  Future<void> _navigateToChatScreen() async {
    await Navigator.of(context).pushNamed(ChatScreen.routeName);
  }
}
