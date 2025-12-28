import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

/// One-time script to update existing driver documents with email and licensePlate fields
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  runApp(const UpdateDriverEmailsApp());
}

class UpdateDriverEmailsApp extends StatelessWidget {
  const UpdateDriverEmailsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Update Driver Emails')),
        body: const UpdateDriverEmailsScreen(),
      ),
    );
  }
}

class UpdateDriverEmailsScreen extends StatefulWidget {
  const UpdateDriverEmailsScreen({super.key});

  @override
  State<UpdateDriverEmailsScreen> createState() => _UpdateDriverEmailsScreenState();
}

class _UpdateDriverEmailsScreenState extends State<UpdateDriverEmailsScreen> {
  String _status = 'Ready to update driver emails';
  bool _isUpdating = false;

  Future<void> _updateDriverEmails() async {
    setState(() {
      _isUpdating = true;
      _status = 'Fetching drivers...';
    });

    try {
      final driversSnapshot = await FirebaseFirestore.instance.collection('drivers').get();
      
      setState(() {
        _status = 'Found ${driversSnapshot.docs.length} drivers. Updating...';
      });

      int updated = 0;
      for (var doc in driversSnapshot.docs) {
        final driverId = doc.id;
        final data = doc.data();
        
        // Check if email is missing
        if (!data.containsKey('email') || data['email'] == null || data['email'] == '') {
          // Try to get email from Firebase Auth
          final currentUser = FirebaseAuth.instance.currentUser;
          String email = '';
          
          if (currentUser != null && currentUser.uid == driverId) {
            email = currentUser.email ?? '';
          }
          
          // Update the document
          await FirebaseFirestore.instance.collection('drivers').doc(driverId).update({
            'email': email.isNotEmpty ? email : 'driver@darna.ma',
            'licensePlate': data['licensePlate'] ?? 'ABC-123', // Default if missing
          });
          
          updated++;
        }
      }

      setState(() {
        _status = 'Successfully updated $updated driver(s)!';
        _isUpdating = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _status,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isUpdating ? null : _updateDriverEmails,
              child: _isUpdating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Update Driver Emails'),
            ),
          ],
        ),
      ),
    );
  }
}
