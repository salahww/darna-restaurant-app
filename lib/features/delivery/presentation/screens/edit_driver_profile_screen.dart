import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darna/core/theme/app_theme.dart';
import 'package:darna/core/services/storage_service.dart';
import 'package:darna/features/delivery/presentation/providers/driver_profile_provider.dart';
import 'package:darna/features/profile/presentation/providers/profile_picture_provider.dart';

class EditDriverProfileScreen extends ConsumerStatefulWidget {
  const EditDriverProfileScreen({super.key});

  @override
  ConsumerState<EditDriverProfileScreen> createState() => _EditDriverProfileScreenState();
}

class _EditDriverProfileScreenState extends ConsumerState<EditDriverProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _licensePlateController;
  String _selectedVehicleType = 'Car';
  bool _isLoading = false;

  final List<String> _vehicleTypes = ['Car', 'Motorcycle', 'Bicycle'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _licensePlateController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(driverProfileServiceProvider).updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        vehicleType: _selectedVehicleType.toLowerCase(), // Save as lowercase
        licensePlate: _licensePlateController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final driverAsync = ref.watch(currentDriverProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: driverAsync.when(
        data: (driver) {
          if (driver == null) {
            return const Center(child: Text('No driver profile found'));
          }

          // Initialize controllers with current data
          if (_nameController.text.isEmpty) {
            _nameController.text = driver.name;
            _phoneController.text = driver.phone;
            _licensePlateController.text = driver.licensePlate;
            // Normalize vehicle type to match dropdown (capitalize first letter)
            final normalizedVehicleType = driver.vehicleType.isEmpty 
                ? 'Car' 
                : driver.vehicleType[0].toUpperCase() + driver.vehicleType.substring(1).toLowerCase();
            _selectedVehicleType = _vehicleTypes.contains(normalizedVehicleType) 
                ? normalizedVehicleType 
                : 'Car';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Picture with Upload
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        final storageService = ref.read(storageServiceProvider);
                        final picker = ImagePicker();
                        
                        final XFile? pickedFile = await picker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 1024,
                          maxHeight: 1024,
                        );
                        
                        if (pickedFile != null && context.mounted) {
                          try {
                            // Show loading
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                            
                            // Upload to Firebase Storage
                            final downloadUrl = await storageService.uploadProfilePicture(
                              File(pickedFile.path),
                              driver.id,
                            );
                            
                            // Update Firestore for driver
                            await FirebaseFirestore.instance
                                .collection('drivers')
                                .doc(driver.id)
                                .update({'profilePictureUrl': downloadUrl});
                            
                            if (context.mounted) {
                              Navigator.pop(context); // Close loading
                              ref.invalidate(currentDriverProfileProvider);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profile picture updated!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              Navigator.pop(context); // Close loading
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Upload failed: $e')),
                              );
                            }
                          }
                        }
                      },
                      child: Stack(
                        children: [
                          // Avatar
                          driver.profilePictureUrl != null && driver.profilePictureUrl!.isNotEmpty
                              ? CircleAvatar(
                                  radius: 60,
                                  backgroundImage: NetworkImage(driver.profilePictureUrl!),
                                  backgroundColor: AppColors.primary.withOpacity(0.2),
                                )
                              : CircleAvatar(
                                  radius: 60,
                                  backgroundColor: AppColors.primary.withOpacity(0.2),
                                  child: Text(
                                    driver.name.isNotEmpty ? driver.name[0].toUpperCase() : 'D',
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                          // Camera icon overlay
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Phone field
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Email field (read-only)
                  TextFormField(
                    initialValue: driver.email,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      helperText: 'Email cannot be changed',
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Vehicle Information',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Vehicle type dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedVehicleType,
                    decoration: InputDecoration(
                      labelText: 'Vehicle Type',
                      prefixIcon: const Icon(Icons.directions_car),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _vehicleTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedVehicleType = value;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // License plate field
                  TextFormField(
                    controller: _licensePlateController,
                    decoration: InputDecoration(
                      labelText: 'License Plate',
                      prefixIcon: const Icon(Icons.confirmation_number),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your license plate';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  // Save button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading profile: $error'),
        ),
      ),
    );
  }
}
