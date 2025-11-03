import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/receipt_template.dart';
import '../services/receipt_template_service.dart';
import '../models/transaction.dart';

class ReceiptTemplateScreen extends StatefulWidget {
  const ReceiptTemplateScreen({super.key});

  @override
  State<ReceiptTemplateScreen> createState() => _ReceiptTemplateScreenState();
}

class _ReceiptTemplateScreenState extends State<ReceiptTemplateScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _storeNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _footer1Controller;
  late TextEditingController _footer2Controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTemplate();
  }

  Future<void> _loadTemplate() async {
    final template = await ReceiptTemplateService.getTemplate();
    setState(() {
      _storeNameController = TextEditingController(text: template.storeName);
      _descriptionController = TextEditingController(text: template.description);
      _addressController = TextEditingController(text: template.address);
      _phoneController = TextEditingController(text: template.phone);
      _footer1Controller = TextEditingController(text: template.footer1);
      _footer2Controller = TextEditingController(text: template.footer2);
      _loading = false;
    });
  }

  Future<void> _saveTemplate() async {
    if (_formKey.currentState!.validate()) {
      final template = ReceiptTemplate(
        storeName: _storeNameController.text,
        description: _descriptionController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        footer1: _footer1Controller.text,
        footer2: _footer2Controller.text,
      );
      await ReceiptTemplateService.saveTemplate(template);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Template struk berhasil disimpan!'), backgroundColor: Colors.green),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Struk'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _storeNameController,
                decoration: const InputDecoration(labelText: 'Nama Toko'),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Alamat'),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Telepon'),
              ),
              TextFormField(
                controller: _footer1Controller,
                decoration: const InputDecoration(labelText: 'Footer 1'),
              ),
              TextFormField(
                controller: _footer2Controller,
                decoration: const InputDecoration(labelText: 'Footer 2'),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showPreview,
                      icon: const Icon(Icons.preview),
                      label: const Text('Preview Struk'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveTemplate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPreview() {
    // Buat sample transaction untuk preview
    final sampleTransaction = Transaction(
      id: 'preview-12345',
      date: DateTime.now(),
      totalPrice: 50000.0,
      userId: 'preview',
      items: [
        TransactionItem(
          productId: '1',
          productName: 'Produk A',
          price: 15000.0,
          quantity: 2,
          subtotal: 30000.0,
        ),
        TransactionItem(
          productId: '2',
          productName: 'Produk B',
          price: 20000.0,
          quantity: 1,
          subtotal: 20000.0,
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Preview Struk'),
        content: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Text(
                _storeNameController.text.isEmpty 
                    ? 'POS APP' 
                    : _storeNameController.text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              if (_descriptionController.text.isNotEmpty)
                Text(
                  _descriptionController.text,
                  style: const TextStyle(fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              if (_addressController.text.isNotEmpty)
                Text(
                  _addressController.text,
                  style: const TextStyle(fontSize: 9),
                  textAlign: TextAlign.center,
                ),
              if (_phoneController.text.isNotEmpty)
                Text(
                  _phoneController.text,
                  style: const TextStyle(fontSize: 9),
                  textAlign: TextAlign.center,
                ),
              const Divider(),
              
              // Transaction Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tanggal:', style: TextStyle(fontSize: 9)),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                    style: const TextStyle(fontSize: 9),
                  ),
                ],
              ),
              
              const Divider(),
              
              // Items
              ...sampleTransaction.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        style: const TextStyle(fontSize: 9),
                      ),
                    ),
                    Text(
                      '${item.quantity}x ${NumberFormat('#,###').format(item.price)}',
                      style: const TextStyle(fontSize: 9),
                    ),
                  ],
                ),
              )),
              
              const Divider(),
              
              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOTAL:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    NumberFormat('#,###').format(sampleTransaction.totalPrice),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Footer
              if (_footer1Controller.text.isNotEmpty)
                Text(
                  _footer1Controller.text,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (_footer2Controller.text.isNotEmpty)
                Text(
                  _footer2Controller.text,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
} 