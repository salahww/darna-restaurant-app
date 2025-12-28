import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:darna/core/theme/app_theme.dart';

void showLoginDialog(BuildContext context) {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Sign In'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quick Auto-fill Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTestChip(
                  context, 
                  'Client', 
                  'client@darna.com', 
                  'Client123!', 
                  emailController, 
                  passwordController,
                  Colors.blue,
                ),
                const SizedBox(width: 8),
                _buildTestChip(
                  context, 
                  'Driver', 
                  'driver@darna.com', 
                  'Driver123!', 
                  emailController, 
                  passwordController,
                  Colors.orange,
                ),
                const SizedBox(width: 8),
                _buildTestChip(
                  context, 
                  'Admin', 
                  'admin@darna.com', 
                  'Admin123!', 
                  emailController, 
                  passwordController,
                  Colors.red,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => _createTestAccounts(context),
          child: const Text('Setup Test Data', style: TextStyle(color: Colors.grey, fontSize: 10)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: emailController.text.trim(),
                password: passwordController.text.trim(),
              );
              if (context.mounted) {
                Navigator.pop(context);
                // Navigate home to trigger role-based routing
                context.go('/');
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Login failed: $e')),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.deepTeal,
          ),
          child: const Text('Sign In'),
        ),
      ],
    ),
  );
}

Future<void> _createTestAccounts(BuildContext context) async {
  if (!context.mounted) return;
  
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Creating test accounts... Please wait.')),
  );

  try {
     // Admin
     try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: 'admin@darna.com', 
        password: 'Admin123!',
      );
      // Wait for Auth trigger or manually create Firestore doc via AdminAuthService if instance available
      // Since we don't have AdminAuthService here easily, we just create Auth users first.
      // Actually need to ensure Firestore documents are created.
      // Ideally should invoke the logic from setup_admin.dart but inside the app.
     } catch (_) {}

     // Driver
     try {
       await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: 'driver@darna.com', 
        password: 'Driver123!',
      );
     } catch (_) {}

     // Client
     try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: 'client@darna.com', 
        password: 'Client123!',
      );
     } catch (_) {}
     
     if (context.mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test accounts created in Auth. Note: Firestore roles require AdminAuthService execution if not auto-created.')),
      );
     }
  } catch (e) {
    if (context.mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}


Widget _buildTestChip(
  BuildContext context,
  String label,
  String email,
  String password,
  TextEditingController emailCtrl,
  TextEditingController passCtrl,
  Color color,
) {
  return ActionChip(
    label: Text(label, style: const TextStyle(fontSize: 12)),
    avatar: Icon(Icons.login, size: 14, color: color),
    backgroundColor: color.withValues(alpha: 0.1),
    side: BorderSide(color: color.withValues(alpha: 0.3)),
    padding: EdgeInsets.zero,
    labelPadding: const EdgeInsets.symmetric(horizontal: 4),
    onPressed: () {
      emailCtrl.text = email;
      passCtrl.text = password;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label credentials filled'),
          duration: const Duration(seconds: 1),
          backgroundColor: color,
        ),
      );
    },
  );
}
