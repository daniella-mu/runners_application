import 'package:flutter/material.dart';
import '/controllers/home_controller.dart';
import '/models/user_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController _homeController = HomeController();
  late Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();
    final currentUser = _homeController.getCurrentUserModel();
    if (currentUser != null) {
      _userFuture = _homeController.fetchUserProfile(currentUser.id);
    } else {
      _userFuture = Future.value(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Runner Dashboard"),
        backgroundColor: Colors.purple,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _homeController.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 210, 189, 214),
              Color.fromARGB(255, 248, 245, 246),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              FutureBuilder<UserModel?>(
                future: _userFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  final user =
                      snapshot.data ?? _homeController.getCurrentUserModel();

                  // Prefer full name, fallback to "Runner"
                  final name =
                      (user?.fullName != null && user!.fullName!.isNotEmpty)
                      ? user.fullName!
                      : 'Runner';

                  return Text(
                    "Welcome, $name",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
              const SizedBox(height: 30),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildActionCard(
                      context,
                      icon: Icons.map,
                      label: "View Safe Routes",
                      route: '/routes-explorer',
                      color: Colors.teal,
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.timeline,
                      label: "Run History",
                      route: '/run-history',
                      color: Colors.indigo,
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.feedback,
                      label: "Community Feedback",
                      route: '/feedback-routes',
                      color: Colors.orange,
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.person,
                      label: "Profile",
                      route: '/profile',
                      color: Colors.pink,
                    ),
                    // Incident Report card
                    _buildActionCard(
                      context,
                      icon: Icons.report_problem,
                      label: "Incident Report",
                      route: '/incident-report',
                      color: const Color.fromARGB(255, 243, 47, 47),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    required Color color,
  }) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        color: color.withAlpha((0.9 * 255).round()),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 42, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
