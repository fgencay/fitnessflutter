import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/base_auth_provider.dart';

class AuthDebugScreen extends StatelessWidget {
  const AuthDebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth Debug'),
        backgroundColor: Colors.orange,
      ),
      body: Consumer<BaseAuthProvider>(
        builder: (context, authProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard('Authentication Status', [
                  'Is Authenticated: ${authProvider.isAuthenticated}',
                  'Is Loading: ${authProvider.isLoading}',
                  'Remember Me: ${authProvider.rememberMe}',
                  'Current User: ${authProvider.currentUser?.email ?? "None"}',
                ]),
                
                const SizedBox(height: 16),
                
                _buildStatusCard('Error Information', [
                  'Error Message: ${authProvider.errorMessage ?? "No errors"}',
                ]),
                
                const SizedBox(height: 16),
                
                _buildStatusCard('User Details', authProvider.currentUser != null ? [
                  'ID: ${authProvider.currentUser!.id}',
                  'Name: ${authProvider.currentUser!.name}',
                  'Email: ${authProvider.currentUser!.email}',
                  'Age: ${authProvider.currentUser!.age}',
                  'Height: ${authProvider.currentUser!.height}',
                  'Weight: ${authProvider.currentUser!.weight}',
                  'Gender: ${authProvider.currentUser!.gender}',
                  'Fitness Goal: ${authProvider.currentUser!.fitnessGoal}',
                  'Activity Level: ${authProvider.currentUser!.activityLevel}',
                  'Created At: ${authProvider.currentUser!.createdAt}',
                ] : ['No user data available']),
                
                const SizedBox(height: 24),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          authProvider.clearError();
                        },
                        child: const Text('Clear Error'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await authProvider.checkAuthStatus();
                        },
                        child: const Text('Refresh Status'),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                if (authProvider.isAuthenticated)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await authProvider.logout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Logout'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(String title, List<String> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                item,
                style: const TextStyle(fontSize: 14),
              ),
            )),
          ],
        ),
      ),
    );
  }
}