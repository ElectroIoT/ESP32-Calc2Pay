import 'package:flutter/material.dart';

import '../ble/calc2pay_ble_service.dart';
import '../models/merchant_config.dart';

/// Push/pull merchant config (UPI VPA, business name, GST%, discount%) over
/// BLE. This is device-local config only — no cloud, no accounts, per Rev-1
/// scope in ../../app/README.md.
class MerchantConfigScreen extends StatefulWidget {
  const MerchantConfigScreen({super.key});

  @override
  State<MerchantConfigScreen> createState() => _MerchantConfigScreenState();
}

class _MerchantConfigScreenState extends State<MerchantConfigScreen> {
  final _ble = Calc2PayBleService.instance;
  final _formKey = GlobalKey<FormState>();

  final _vpaController = TextEditingController();
  final _nameController = TextEditingController();
  final _gstController = TextEditingController();
  final _discountController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _vpaController.dispose();
    _nameController.dispose();
    _gstController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final config = await _ble.readMerchantConfig();
      _vpaController.text = config.vpa;
      _nameController.text = config.businessName;
      _gstController.text = config.gstPercent.toString();
      _discountController.text = config.discountPercent.toString();
    } catch (e) {
      _error = 'Could not read config from device: $e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    final config = MerchantConfig(
      vpa: _vpaController.text.trim(),
      businessName: _nameController.text.trim(),
      gstPercent: double.tryParse(_gstController.text) ?? 0,
      discountPercent: double.tryParse(_discountController.text) ?? 0,
    );

    try {
      await _ble.writeMerchantConfig(config);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved to device')),
        );
      }
    } catch (e) {
      setState(() => _error = 'Save failed: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Merchant settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(_error!,
                            style: const TextStyle(color: Colors.red)),
                      ),
                    TextFormField(
                      controller: _vpaController,
                      decoration: const InputDecoration(
                        labelText: 'UPI VPA',
                        hintText: 'merchant@upi',
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                          labelText: 'Business name'),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _gstController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'GST %'),
                      validator: _percentValidator,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _discountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration:
                          const InputDecoration(labelText: 'Discount %'),
                      validator: _percentValidator,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save to device'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String? _percentValidator(String? v) {
    if (v == null || v.isEmpty) return null;
    final parsed = double.tryParse(v);
    if (parsed == null) return 'Enter a number';
    if (parsed < 0 || parsed > 100) return '0-100 only';
    return null;
  }
}
