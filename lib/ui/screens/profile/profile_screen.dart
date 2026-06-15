import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gamified_fitness_app/providers/user_provider.dart';
import 'package:gamified_fitness_app/business/xp_service.dart';

/// User profile screen showing stats, rank, and name change option
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (userProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('My Profile')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = userProvider.user!;
    final rank = XPService.getRank(user.level);
    final nextRank = XPService.getNextRank(user.level);
    final xpNeeded = XPService.getXPNeededForNextRank(user.level, user.xp);

    return Scaffold(
      appBar: AppBar(title: Text('My Profile')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            // Rank badge container
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.amber, Colors.deepOrange]),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  Icon(Icons.emoji_events, color: Colors.white, size: 40),
                  SizedBox(height: 4),
                  Text(rank, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Profile avatar
            CircleAvatar(
              radius: 60,
              child: Icon(Icons.person, size: 60),
            ),
            SizedBox(height: 16),

            // User name (automatically updates via Provider)
            Text(
              user.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),

            // Level display
            Text('Level ${user.level}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),

            // Next rank progress
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Text('🏆 Next Rank: $nextRank', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('$xpNeeded XP needed', style: TextStyle(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
            SizedBox(height: 32),

            // User statistics
            _buildInfoRow('Total XP', user.xp.toString()),
            _buildInfoRow('Total Workouts', user.totalWorkouts.toString()),
            _buildInfoRow('Join Date', '${user.joinDate.day}/${user.joinDate.month}/${user.joinDate.year}'),
            SizedBox(height: 32),

            // Change name button
            ElevatedButton(
              onPressed: () => _showNameDialog(context, userProvider),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
              child: Text('Change Name'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a row with label and value for user info
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// Show dialog to change user name
  void _showNameDialog(BuildContext context, UserProvider userProvider) {
    final controller = TextEditingController(text: userProvider.user!.name);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Change Name'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'New name'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  await userProvider.changeName(controller.text);
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Name changed successfully!')),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}