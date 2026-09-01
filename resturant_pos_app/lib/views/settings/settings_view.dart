import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resturant_pos_app/core/theme/app_theme.dart';
import 'package:resturant_pos_app/providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:resturant_pos_app/core/supabase/supabase_client.dart';
import 'package:resturant_pos_app/providers/database_provider.dart';
import 'package:resturant_pos_app/core/utils/backup_helper.dart';
import 'package:resturant_pos_app/core/utils/backup_helper/backup_exporter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late TextEditingController _nameController;
  late TextEditingController _taxController;
  late TextEditingController _logoController;
  late TextEditingController _receiptHeaderController;
  late TextEditingController _startingBillNumberController;
  final _newMethodController = TextEditingController();

  List<String> _paymentMethods = [];
  bool _isUploading = false;
  bool _kitchenBypass = false;
  bool _isBackingUp = false;
  bool _useClassicPrint = false;

  @override
  void initState() {
    super.initState();
    final authState = authProvider.state.value;
    final rest = authState.restaurant;

    _nameController = TextEditingController(text: rest?.name ?? '');
    _taxController = TextEditingController(text: rest?.taxPercentage.toString() ?? '0.0');
    _logoController = TextEditingController(text: rest?.logoUrl ?? '');
    _receiptHeaderController = TextEditingController(text: rest?.receiptHeader ?? '');
    _startingBillNumberController = TextEditingController(text: rest?.startingBillNumber.toString() ?? '1000');
    _kitchenBypass = rest?.kitchenBypass ?? false;

    final rawMethods = rest?.paymentMethods ?? 'Cash,Card';
    _paymentMethods = rawMethods.split(',').map((m) => m.trim()).where((m) => m.isNotEmpty).toList();
    _loadPrintTemplatePreference();
  }
 
  void _loadPrintTemplatePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _useClassicPrint = prefs.getBool('use_classic_print_template') ?? false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taxController.dispose();
    _logoController.dispose();
    _receiptHeaderController.dispose();
    _startingBillNumberController.dispose();
    _newMethodController.dispose();
    super.dispose();
  }

  Future<void> _exportDatabaseBackup() async {
    setState(() {
      _isBackingUp = true;
    });
    try {
      final db = databaseProvider;
      final authState = authProvider.state.value;
      final restaurantId = authState.restaurant?.id;
      final sqlDump = await BackupHelper.generateSqlDump(db, restaurantId: restaurantId);
      final fileName = 'restaurant_pos_backup_${DateTime.now().millisecondsSinceEpoch}.sql';
      
      await saveAndShareFile(fileName, sqlDump);
      
      Get.snackbar(
        'Backup Successful',
        'Database SQL backup exported successfully.',
        backgroundColor: AppTheme.accentEmerald,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Backup Failed',
        'Could not export database backup: $e',
        backgroundColor: AppTheme.accentRose,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isBackingUp = false;
      });
    }
  }

  Future<void> _pickAndUploadLogo() async {
    final picker = ImagePicker();
    try {
      final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (image == null) return;

      setState(() {
        _isUploading = true;
      });

      final bytes = await image.readAsBytes();
      final supa = SupabaseService.instance;
      
      final currentLogo = _logoController.text.trim();
      final publicUrl = await supa.uploadLogo(image.name, bytes, oldLogoUrl: currentLogo.isNotEmpty ? currentLogo : null);
      if (publicUrl != null) {
        setState(() {
          _logoController.text = publicUrl;
        });
        Get.snackbar(
          'Upload Successful',
          'Logo uploaded and url updated.',
          backgroundColor: AppTheme.accentEmerald,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.defaultDialog(
        title: 'Upload Failed',
        middleText: '${e.toString().replaceAll('Exception: ', '')}\n\nNote: Please make sure your "logos" storage bucket is configured as "Public" in Supabase, and has a Row-level Security (RLS) policy enabling anonymous or authenticated uploads.',
        textConfirm: 'Okay',
        confirmTextColor: Colors.white,
        buttonColor: Theme.of(context).primaryColor,
        onConfirm: () => Get.back(),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }


  void _addPaymentMethod() {
    final method = _newMethodController.text.trim();
    if (method.isNotEmpty && !_paymentMethods.contains(method)) {
      setState(() {
        _paymentMethods.add(method);
      });
      _newMethodController.clear();
    }
  }

  void _removePaymentMethod(String method) {
    if (_paymentMethods.length <= 1) {
      Get.snackbar(
        'Warning',
        'You must configure at least one payment method.',
        backgroundColor: AppTheme.accentRose,
        colorText: Colors.white,
      );
      return;
    }
    setState(() {
      _paymentMethods.remove(method);
    });
  }

  void _saveSettings() async {
    final name = _nameController.text.trim();
    final tax = double.tryParse(_taxController.text) ?? 0.0;
    final logo = _logoController.text.trim();
    final receiptHeader = _receiptHeaderController.text.trim();
    final startingBillNum = int.tryParse(_startingBillNumberController.text) ?? 1000;
    final paymentMethodsStr = _paymentMethods.join(',');
 
    if (name.isEmpty) {
      Get.snackbar(
        'Error',
        'Restaurant name cannot be empty.',
        backgroundColor: AppTheme.accentRose,
        colorText: Colors.white,
      );
      return;
    }
 
    final success = await authProvider.updateRestaurantProfile(
      name: name,
      taxPercentage: tax,
      logoUrl: logo.isNotEmpty ? logo : null,
      paymentMethods: paymentMethodsStr,
      kitchenBypass: _kitchenBypass,
      receiptHeader: receiptHeader.isNotEmpty ? receiptHeader : null,
      startingBillNumber: startingBillNum,
    );

    if (success) {
      Get.snackbar(
        'Settings Saved',
        'Restaurant configuration updated successfully.',
        backgroundColor: AppTheme.accentEmerald,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Save Failed',
        'Could not save restaurant settings to cloud.',
        backgroundColor: AppTheme.accentRose,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            children: [
              Text(
                'Restaurant Settings',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Configure profile details, taxes, logos, and payment modes.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 24),

              // Restaurant details card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile Information',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Restaurant Name',
                          prefixIcon: Icon(Icons.restaurant),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Logo Upload and Preview Section
                      Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
                            ),
                            child: _logoController.text.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(11),
                                    child: Image.network(
                                      _logoController.text,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(
                                        Icons.broken_image_outlined,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.restaurant_outlined,
                                    color: Colors.grey,
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Restaurant Logo',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                _isUploading
                                    ? Row(
                                        children: [
                                          const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Uploading logo image...',
                                            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                                          ),
                                        ],
                                      )
                                    : ElevatedButton.icon(
                                        onPressed: _pickAndUploadLogo,
                                        icon: const Icon(Icons.cloud_upload_outlined, size: 18, color: Colors.white),
                                        label: Text(
                                          'Upload Logo',
                                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context).primaryColor,
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _logoController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Logo Image URL (Read-only)',
                          prefixIcon: Icon(Icons.link),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _taxController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Tax Percentage (%)',
                          prefixIcon: Icon(Icons.percent),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _receiptHeaderController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Receipt Header / Address',
                          prefixIcon: Icon(Icons.location_on),
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _startingBillNumberController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Starting Bill Number',
                          prefixIcon: Icon(Icons.pin),
                          hintText: 'e.g. 1000',
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: Text(
                          'Bypass Kitchen Monitor',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          'If enabled, orders will skip the kitchen monitor and can be paid/completed immediately.',
                          style: GoogleFonts.inter(fontSize: 12),
                        ),
                        value: _kitchenBypass,
                        activeColor: Theme.of(context).primaryColor,
                        onChanged: (val) {
                          setState(() {
                            _kitchenBypass = val;
                          });
                        },
                      ),
                      const Divider(height: 24),
                      SwitchListTile(
                        title: Text(
                          'Classic Print Template',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          'Use a high-contrast, larger monospaced font layout that is easier to read on low-resolution thermal printers.',
                          style: GoogleFonts.inter(fontSize: 12),
                        ),
                        value: _useClassicPrint,
                        activeColor: Theme.of(context).primaryColor,
                        onChanged: (val) async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('use_classic_print_template', val);
                          setState(() {
                            _useClassicPrint = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Payment methods card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Methods',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Define what modes of payment your cashiers can select.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _newMethodController,
                              decoration: const InputDecoration(
                                labelText: 'Add Custom Method',
                                hintText: 'e.g. EasyPaisa',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _addPaymentMethod,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _paymentMethods.map((method) {
                          return Chip(
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                            side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                            label: Text(
                              method,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            deleteIcon: const Icon(Icons.cancel, size: 16),
                            deleteIconColor: AppTheme.accentRose,
                            onDeleted: () => _removePaymentMethod(method),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Database Backup Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Database Backup',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Generate a complete SQL file backup of all local tables, configurations, menus, and transaction histories.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isBackingUp ? null : _exportDatabaseBackup,
                        icon: _isBackingUp 
                            ? const SizedBox(
                                width: 20, 
                                height: 20, 
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              )
                            : const Icon(Icons.backup_outlined, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentEmerald,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        label: Text(
                          _isBackingUp ? 'Exporting...' : 'Export Database (.sql)',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action buttons
              ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save_outlined),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                label: Text(
                  'Save Settings',
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
