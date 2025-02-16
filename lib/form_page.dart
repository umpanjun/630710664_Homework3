import 'package:flutter/material.dart';
import 'api_service.dart';

class FormPage extends StatefulWidget {
  final Map<String, dynamic>? product;
  final String? productId;

  const FormPage({super.key, this.product, this.productId});

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  final ApiService apiService = ApiService();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.product?['name'] ?? "");
    descriptionController = TextEditingController(text: widget.product?['description'] ?? "");
    priceController = TextEditingController(text: widget.product?['price']?.toString() ?? "");
  }

  Future<void> saveProduct() async {
    if (!_formKey.currentState!.validate() || isLoading) return;

    setState(() => isLoading = true);

    try {
      if (widget.productId == null) {
        await apiService.createProduct(
          nameController.text,
          descriptionController.text,
          double.tryParse(priceController.text) ?? 0.0,
        );
      } else {
        await apiService.updateProduct(
          widget.productId!,
          nameController.text,
          descriptionController.text,
          double.tryParse(priceController.text) ?? 0.0,
        );
      }
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.productId == null ? "Add Product" : "Edit Product")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: nameController, decoration: InputDecoration(labelText: "Product Name")),
              TextFormField(controller: descriptionController, decoration: InputDecoration(labelText: "Description")),
              TextFormField(controller: priceController, decoration: InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
              SizedBox(height: 20),
              isLoading ? CircularProgressIndicator() : ElevatedButton(onPressed: saveProduct, child: Text(widget.productId == null ? "Add Product" : "Save Changes")),
            ],
          ),
        ),
      ),
    );
  }
}
