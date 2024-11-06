import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/data.dart';
import 'package:flutter_application_1/models/ClosetItem.dart';
import 'package:flutter_application_1/screens/recommend/preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/auth/login_logic.dart';
import 'package:flutter_application_1/screens/3d_model/create_model.dart';
import 'package:flutter_application_1/screens/middle/closet.dart';
import 'package:flutter_application_1/screens/shop/mall.dart';
import 'package:flutter_application_1/screens/record/video.dart';

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
  int _selectedIndex = 1;
  final _closetDataService = ClosetDataService();
  List<ClosetItem> closetItems = [];
  DocumentSnapshot? lastDocument;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    closetItems = widget.preloadedItems;
    lastDocument = widget.preloadedLastDocument;
  }

  // Define color constants
  static const Color darkGrey = Color.fromARGB(224, 86, 98, 112);
  static const Color lightPurple = Color.fromARGB(224, 165, 147, 224);
  static const Color lightGrey = Color.fromARGB(224, 224, 227, 218);

  Future<void> _preloadClosetData() async {
    final loginAuth = Provider.of<LoginAuth>(context, listen: false);
    final user = loginAuth.user;
    if (user == null) return;

    setState(() => isLoading = true);

    final result = await _closetDataService.loadInitialClosetData(user.uid);
    
    if (mounted) {
      setState(() {
        closetItems = result['items'];
        lastDocument = result['lastDocument'];
        isLoading = false;
      });
    }
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return const VideoRecorderWidget();
      case 1:
        return ClosetScreen(
          initialItems: closetItems,
          initialLastDocument: lastDocument,
          isInitialLoading: isLoading,
        );
      case 2:
        return CreateModelScreen();
      case 3:
        return MallScreen();
      default:
        return ClosetScreen(
          initialItems: closetItems,
          initialLastDocument: lastDocument,
          isInitialLoading: isLoading,
        );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loginAuth = Provider.of<LoginAuth>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Screen', style: TextStyle(color: lightGrey)),
        backgroundColor: darkGrey,
        iconTheme: const IconThemeData(color: lightGrey),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              try {
                await loginAuth.signOut();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (route) => false);
              } catch (e) {
                print('Sign out error: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('로그아웃 중 오류가 발생했습니다. 잠시 후 다시 시도하세요.'),
                    backgroundColor: darkGrey,
                  ),
                );
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: lightGrey,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: lightPurple,
                ),
                child: Text(
                  '메뉴',
                  style: TextStyle(
                    color: darkGrey,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home, color: darkGrey),
                title: const Text('홈', style: TextStyle(color: darkGrey)),
                onTap: () {
                  Navigator.pop(context);
                  _onItemTapped(1);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person, color: darkGrey),
                title: const Text('프로필', style: TextStyle(color: darkGrey)),
                onTap: () {
                  Navigator.pop(context);
                  // 프로필 화면으로 이동하는 로직 추가
                },
              ),
              ListTile(
                leading: const Icon(Icons.style, color: darkGrey),
                title: const Text('내 취향', style: TextStyle(color: darkGrey)),
                onTap: () async {
                  Navigator.pop(context); // Close drawer
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StylePreferencesScreen()),
                  );
                  if (result != null) {
                    // Handle the returned preferences
                    print('사용자 취향이 업데이트되었습니다');
                    // Preferences 업데이트 로직 추가
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: darkGrey),
                title: const Text('설정', style: TextStyle(color: darkGrey)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('이 기능은 아직 개발 중입니다.'),
                      backgroundColor: darkGrey,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.help, color: darkGrey),
                title: const Text('도움말', style: TextStyle(color: darkGrey)),
                onTap: () {
                  Navigator.pop(context);
                  // 도움말 화면으로 이동하는 로직 추가
                },
              ),
              ListTile(
                leading: const Icon(Icons.info, color: darkGrey),
                title: const Text('앱 정보', style: TextStyle(color: darkGrey)),
                onTap: () {
                  Navigator.pop(context);
                  // 앱 정보 화면으로 이동하는 로직 추가
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        color: Colors.teal.shade50,
        child: isLoading ? const Center(child: CircularProgressIndicator()) : _getScreen(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.videocam),
            label: 'Record',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Middle',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.create),
            label: 'Create Model',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shop),
            label: 'Mall',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: lightPurple,
        unselectedItemColor: darkGrey,
        backgroundColor: lightGrey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}
