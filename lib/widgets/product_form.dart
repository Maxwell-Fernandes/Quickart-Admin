import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_quickart/models/product.dart';

class ProductForm extends StatefulWidget {
  final Product? product;

  const ProductForm({Key? key, this.product}) : super(key: key);

  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late String _categoryId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.productName);
    _priceController =
        TextEditingController(text: widget.product?.price.toString());
    _categoryId = widget.product?.categoryId ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Product Name'),
            validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
          ),
          TextFormField(
            controller: _priceController,
            decoration: const InputDecoration(labelText: 'Price'),
            keyboardType: TextInputType.number,
            validator: (value) =>
                value!.isEmpty ? 'Please enter a price' : null,
          ),
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('categories').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();

              return DropdownButtonFormField<String>(
                value: _categoryId.isNotEmpty ? _categoryId : null,
                hint: const Text('Select Category'),
                items: snapshot.data!.docs.map((doc) {
                  return DropdownMenuItem<String>(
                    value: doc.id,
                    child: Text(doc['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categoryId = value!;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a category' : null,
              );
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submitForm,
            child:
                Text(widget.product == null ? 'Add Product' : 'Update Product'),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final productData = {
        'product_name': _nameController.text,
        'price': double.parse(_priceController.text),
        'category_id': _categoryId,
      };

      if (widget.product == null) {
        FirebaseFirestore.instance.collection('products').add(productData);
      } else {
        FirebaseFirestore.instance
            .collection('products')
            .doc(widget.product!.id)
            .update(productData);
      }

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
