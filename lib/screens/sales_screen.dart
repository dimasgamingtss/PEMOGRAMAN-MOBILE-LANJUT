import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../services/transaction_service.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<TransactionItem> _cartItems = [];
  bool _isLoading = true;
  User? _currentUser;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products.where((product) {
          return product.name.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<void> _loadData() async {
    final user = await AuthService.getCurrentUser();
    if (user != null) {
      final products = await ProductService.getProducts(user.username);
      setState(() {
        _currentUser = user;
        _products = products;
        _filteredProducts = products;
        _isLoading = false;
      });
    }
  }

  void _addToCart(Product product) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.productId == product.id,
    );

    if (existingIndex >= 0) {
      setState(() {
        _cartItems[existingIndex] = TransactionItem(
          productId: product.id,
          productName: product.name,
          price: product.price,
          quantity: _cartItems[existingIndex].quantity + 1,
          subtotal: product.price * (_cartItems[existingIndex].quantity + 1),
        );
      });
    } else {
      setState(() {
        _cartItems.add(TransactionItem(
          productId: product.id,
          productName: product.name,
          price: product.price,
          quantity: 1,
          subtotal: product.price,
        ));
      });
    }
  }

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      setState(() {
        _cartItems.removeAt(index);
      });
    } else {
      setState(() {
        _cartItems[index] = TransactionItem(
          productId: _cartItems[index].productId,
          productName: _cartItems[index].productName,
          price: _cartItems[index].price,
          quantity: newQuantity,
          subtotal: _cartItems[index].price * newQuantity,
        );
      });
    }
  }

  double get _totalPrice {
    return _cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  Future<void> _processTransaction() async {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keranjang kosong!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Cek stok
    for (TransactionItem item in _cartItems) {
      final product = _products.firstWhere((p) => p.id == item.productId);
      if (product.stock < item.quantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stok ${product.name} tidak mencukupi!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Simpan total harga sebelum keranjang dikosongkan
    final totalAmount = _totalPrice;

    final success = await TransactionService.createTransaction(
      _cartItems,
      _currentUser!.username,
    );

    if (success) {
      setState(() {
        _cartItems.clear();
      });
      await _loadData(); // Reload products untuk update stok
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaksi berhasil! Total: Rp ${NumberFormat('#,###').format(totalAmount)}'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Pop kembali ke dashboard dan trigger refresh
        Navigator.pop(context, true); // true menandakan ada transaksi baru
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memproses transaksi!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi Baru'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _searchController,
                      builder: (context, value, child) {
                        return TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Cari produk...',
                            prefixIcon: const Icon(Icons.search, color: Colors.grey),
                            suffixIcon: value.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.grey),
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                  )
                                : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.orange, width: 2),
                        ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          textInputAction: TextInputAction.search,
                        );
                      },
                    ),
                  ),
                  // Daftar Produk
                  Expanded(
                    child: _products.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_2,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Belum ada produk',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Tambahkan produk terlebih dahulu',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _filteredProducts.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 64,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Produk tidak ditemukan',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Coba cari dengan kata kunci lain',
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 1.2,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemCount: _filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final product = _filteredProducts[index];
                              return Card(
                                child: InkWell(
                                  onTap: () => _addToCart(product),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          product.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Rp ${product.price.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Stok: ${product.stock}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  // Keranjang
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border(
                        top: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Keranjang',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Total: Rp ${_totalPrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 120,
                          child: _cartItems.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Keranjang kosong',
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  itemCount: _cartItems.length,
                                  itemBuilder: (context, index) {
                                    final item = _cartItems[index];
                                    return Card(
                                      child: ListTile(
                                        title: Text(item.productName),
                                        subtitle: Text('Rp ${item.price.toStringAsFixed(0)}'),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove),
                                              onPressed: () => _updateQuantity(index, item.quantity - 1),
                                            ),
                                            Text('${item.quantity}'),
                                            IconButton(
                                              icon: const Icon(Icons.add),
                                              onPressed: () => _updateQuantity(index, item.quantity + 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        if (_cartItems.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SafeArea(
                              top: false,
                              left: false,
                              right: false,
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _processTransaction,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: const Text(
                                    'Proses Transaksi',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
} 