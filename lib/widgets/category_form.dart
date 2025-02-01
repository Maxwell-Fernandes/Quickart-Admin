import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_quickart/models/category.dart';

class CategoryForm extends StatefulWidget {
  final Category? category;

  const CategoryForm({Key? key, this.category}) : super(key: key);

  @override
  _CategoryFormState createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
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
            decoration: const InputDecoration(labelText: 'Category Name'),
            validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submitForm,
            child: Text(
                widget.category == null ? 'Add Category' : 'Update Category'),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final categoryData = {
        'name': _nameController.text,
      };

      if (widget.category == null) {
        FirebaseFirestore.instance.collection('categories').add(categoryData);
      } else {
        FirebaseFirestore.instance
            .collection('categories')
            .doc(widget.category!.id)
            .update(categoryData);
      }

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
