import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/ClosetItem.dart';
import 'package:flutter_application_1/screens/3d_model/model_player.dart';
import 'package:flutter_application_1/screens/auth/edit_profile.dart';
import 'package:flutter_application_1/screens/recommend/style_screen.dart';
import 'package:flutter_application_1/services/camera_service.dart';
import 'package:flutter_application_1/utils/constants.dart';
import 'package:flutter_application_1/widgets/bottom_navigation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/auth/login_logic.dart';
import 'package:flutter_application_1/screens/closet/closet_screen.dart';
import 'package:flutter_application_1/screens/shop/mall.dart';

class MyHomePage extends StatefulWidget {
  final List<ClosetItem> preloadedItems;
  final DocumentSnapshot? preloadedLastDocument;

  const MyHomePage({
    Key? key,
    this.preloadedItems = const [],
    this.preloadedLastDocument,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final CameraService _cameraService = CameraService();
  int _selectedIndex = 1;
  List<ClosetItem> closetItems = [];
  DocumentSnapshot? lastDocument;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    closetItems = widget.preloadedItems;
    lastDocument = widget.preloadedLastDocument;
  }

  // Helper functions
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.navy),
      title: Text(title, style: const TextStyle(color: AppColors.navy)),
      onTap: onTap,
    );
  }

  Widget _buildDrawerHeader() {
    return const DrawerHeader(
      decoration: BoxDecoration(color: AppColors.navy),
      child: Text(
        '메뉴',
        style: TextStyle(color: AppColors.white, fontSize: 24),
      ),
    );
  }

  List<Widget> _buildDrawerItems(BuildContext context) {
    return [
      _buildDrawerHeader(),
      _buildDrawerItem(
        icon: Icons.person,
        title: '프로필',
        onTap: () {
          Navigator.pop(context); // Drawer를 닫고
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EditProfileScreen(),
            ),
          );
        },
      ),
      _buildDrawerItem(
        icon: Icons.style,
        title: '옷 추천',
        onTap: () => _handleStyleSelection(context),
      ),
      _buildDrawerItem(
        icon: Icons.camera,
        title: '모델 생성',
        onTap: () async {
          final user = Provider.of<LoginAuth>(context, listen: false).user;
          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('사용자 정보를 찾을 수 없습니다.')),
            );
            return;
          }

          // Close drawer if it's open
          Navigator.pop(context);

          // Call camera service
          await _cameraService.takeAndUploadPhoto(
            uid: user.uid,
            context: context,
          );
        },
      ),
      _buildDrawerItem(
        icon: Icons.settings,
        title: '설정',
        onTap: () => _showDevelopmentSnackBar(context, '이 기능은 아직 개발 중입니다.'),
      ),
      _buildDrawerItem(
        icon: Icons.help,
        title: '도움말',
        onTap: () => Navigator.pop(context),
      ),
      _buildDrawerItem(
        icon: Icons.info,
        title: '앱 정보',
        onTap: () => Navigator.pop(context),
      ),
    ];
  }

  Future<void> _handleStyleSelection(BuildContext context) async {
    Navigator.pop(context);
    try {
      final List<String>? selectedStyles = await Navigator.push<List<String>>(
        context,
        MaterialPageRoute(builder: (context) => const StyleScreen()),
      );

      if (selectedStyles != null && selectedStyles.isNotEmpty && mounted) {
        _showDevelopmentSnackBar(context, '선호 스타일이 업데이트되었습니다');
      }
    } catch (e) {
      if (mounted) {
        _showDevelopmentSnackBar(context, '스타일 업데이트 중 오류가 발생했습니다');
      }
    }
  }

  void _showDevelopmentSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _getScreen(int index) {
    switch (index) {
      // case 0: return const VideoRecorderWidget();
      case 0:
        return const VideoGridScreen();
      case 1:
        return ClosetScreen(
          initialItems: closetItems,
          initialLastDocument: lastDocument,
          isInitialLoading: isLoading,
        );

      case 2:
        return const MallScreen();
      default:
        return ClosetScreen(
          initialItems: closetItems,
          initialLastDocument: lastDocument,
          isInitialLoading: isLoading,
        );
    }
  }

  Future<void> _handleSignOut(LoginAuth loginAuth, BuildContext context) async {
    try {
      await loginAuth.signOut();
      if (mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      print('Sign out error: $e');
      if (mounted) {
        _showDevelopmentSnackBar(context, '로그아웃 중 오류가 발생했습니다. 잠시 후 다시 시도하세요.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginAuth = Provider.of<LoginAuth>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        // title: const Text('Main Screen', style: TextStyle(color: lightGrey)),
        backgroundColor: AppColors.navy,
        iconTheme: const IconThemeData(color: AppColors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _handleSignOut(loginAuth, context),
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: AppColors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: _buildDrawerItems(context),
          ),
        ),
      ),
      body: Container(
        color: AppColors.lavender,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : _getScreen(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigation(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }
}
