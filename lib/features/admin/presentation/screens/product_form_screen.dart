import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:darna/core/theme/app_theme.dart';
import 'package:darna/features/product/domain/entities/product.dart';
import 'package:darna/features/admin/data/services/translation_service.dart';
import 'package:darna/features/admin/presentation/providers/translation_provider.dart';
import 'package:darna/features/product/presentation/providers/product_repository_provider.dart';

/// Product add/edit form screen with category dropdown and image upload
class ProductFormScreen extends ConsumerStatefulWidget {
  final Product? product; // null for new product

  const ProductFormScreen({super.key, this.product});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameEnController;
  late TextEditingController _nameFrController;
  late TextEditingController _descEnController;
  late TextEditingController _descFrController;
  late TextEditingController _priceController;

  String? _selectedCategory;
  File? _selectedImage;
  String? _uploadedImageUrl; // Firebase Storage URL after upload
  bool _isTranslating = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  // Predefined categories (matching mock data)
  final List<String> _categories = [
    'Starters',
    'Tagines',
    'Couscous',
    'Pastilla',
    'Grills',
    'Drinks',
    'Desserts',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameEnController = TextEditingController(text: p?.name ?? '');
    _nameFrController = TextEditingController(text: p?.nameFr ?? '');
    _descEnController = TextEditingController(text: p?.description ?? '');
    _descFrController = TextEditingController(text: p?.descriptionFr ?? '');
    _priceController = TextEditingController(text: p?.price.toString() ?? '');
    _selectedCategory = p?.categoryId;
    _uploadedImageUrl = p?.imageUrl; // Existing product image
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameFrController.dispose();
    _descEnController.dispose();
    _descFrController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToFirebase() async {
    if (_selectedImage == null) return _uploadedImageUrl;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final fileName = 'products/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(fileName);
      
      final uploadTask = storageRef.putFile(_selectedImage!);
      
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
      });

      await uploadTask;
      final downloadUrl = await storageRef.getDownloadURL();
      
      setState(() {
        _uploadedImageUrl = downloadUrl;
        _isUploading = false;
      });

      return downloadUrl;
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image upload failed: $e')),
        );
      }
      return null;
    }
  }

  Future<void> _autoTranslate() async {
    if (_nameEnController.text.isEmpty || _descEnController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill English name and description first')),
      );
      return;
    }

    setState(() => _isTranslating = true);

    try {
      final translationService = ref.read(translationServiceProvider);
      
      final nameFr = await translationService.translateToFrench(_nameEnController.text);
      final descFr = await translationService.translateToFrench(_descEnController.text);

      setState(() {
        _nameFrController.text = nameFr;
        _descFrController.text = descFr;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Translation complete!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Translation failed: $e')),
        );
      }
    } finally {
      setState(() => _isTranslating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.product != null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Product' : 'Add Product'),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image Section
            Text(
              'Product Image',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            // Image preview
            GestureDetector(
              onTap: _isUploading ? null : _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _selectedImage != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_selectedImage!, width: double.infinity, fit: BoxFit.cover),
                          ),
                          if (_isUploading)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(value: _uploadProgress),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${(_uploadProgress * 100).toInt()}%',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      )
                    : _uploadedImageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _uploadedImageUrl!.startsWith('http')
                                ? Image.network(
                                    _uploadedImageUrl!,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(Icons.broken_image, size: 64),
                                    ),
                                  )
                                : Image.asset(
                                    _uploadedImageUrl!,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(Icons.restaurant, size: 64),
                                    ),
                                  ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate, size: 64, color: Colors.grey),
                              const SizedBox(height: 8),
                              Text('Tap to select image', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Upload button
            if (_selectedImage != null && !_isUploading)
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload_file),
                label: const Text('Change Image'),
              ),
            const SizedBox(height: 24),

            // English Section
            Text(
              'English',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameEnController,
              decoration: const InputDecoration(
                labelText: 'Name (EN)',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descEnController,
              decoration: const InputDecoration(
                labelText: 'Description (EN)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 24),

            // Auto-translate button
            OutlinedButton.icon(
              onPressed: _isTranslating ? null : _autoTranslate,
              icon: _isTranslating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.translate),
              label: Text(_isTranslating ? 'Translating...' : 'Auto-Translate to French'),
            ),
            const SizedBox(height: 24),

            // French Section
            Text(
              'French',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameFrController,
              decoration: const InputDecoration(
                labelText: 'Name (FR)',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descFrController,
              decoration: const InputDecoration(
                labelText: 'Description (FR)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 24),

            // Details Section
            Text(
              'Details',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price (DH)',
                border: OutlineInputBorder(),
                prefixText: 'DH ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            
            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value);
              },
              validator: (value) => value == null ? 'Please select a category' : null,
            ),
            const SizedBox(height: 32),

            // Save button
            ElevatedButton(
              onPressed: _isUploading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        // Upload image first if selected
                        String? imageUrl = await _uploadImageToFirebase();
                        
                        if (imageUrl == null && _selectedImage != null) {
                          // Upload failed
                          return;
                        }

                        // Create/update product
                        final product = Product(
                          id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                          name: _nameEnController.text.trim(),
                          nameFr: _nameFrController.text.trim(),
                          description: _descEnController.text.trim(),
                          descriptionFr: _descFrController.text.trim(),
                          price: double.parse(_priceController.text.trim()),
                          imageUrl: imageUrl ?? _uploadedImageUrl ?? '',
                          categoryId: _selectedCategory!,
                          isAvailable: widget.product?.isAvailable ?? true,
                          preparationTime: widget.product?.preparationTime ?? 15,
                          rating: widget.product?.rating ?? 4.5,
                        );

                        // Save to repository
                        final productRepo = ref.read(productRepositoryProvider);
                        final result = widget.product == null
                            ? await productRepo.createProduct(product)
                            : await productRepo.updateProduct(product);

                        if (mounted) {
                          result.fold(
                            (failure) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: ${failure.message}')),
                              );
                            },
                            (savedProduct) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Product ${widget.product == null ? 'added' : 'updated'} successfully!')),
                              );
                              Navigator.pop(context, true); // Return true to indicate success
                            },
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isUploading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(isEdit ? 'Update Product' : 'Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
