import 'package:flutter/material.dart';
import 'form_page.dart';
import 'api_service.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ApiService apiService = ApiService();
  List<dynamic> products = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() => isLoading = true);
    try {
      final response = await apiService.fetchProducts();
      setState(() => products = response);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showDeleteConfirmationDialog(String productId, String productName) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Are you sure you want to delete $productName?"),
        actions: [
          TextButton(child: const Text("Cancel"), onPressed: () => Navigator.pop(context)),
          TextButton(
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              await apiService.deleteProduct(productId);
              fetchProducts();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Product List")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var newProduct = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FormPage()),
          );
          if (newProduct != null) fetchProducts(); // ✅ รีเฟรชหลังจากเพิ่มสินค้า
        },
        child: Icon(Icons.add),
      ),
      body: RefreshIndicator( // ✅ เพิ่ม Pull-to-Refresh
        onRefresh: fetchProducts,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  var product = products[index];
                  return ListTile(
                    title: Text(product['name']),
                    subtitle: Text(product['description']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            var updatedProduct = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FormPage(
                                  product: product,
                                  productId: product['id'].toString(),
                                ),
                              ),
                            );
                            if (updatedProduct != null) fetchProducts(); // ✅ รีเฟรชหลังจากแก้ไขสินค้า
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => showDeleteConfirmationDialog(product['id'].toString(), product['name']),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
