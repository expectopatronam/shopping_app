import 'package:flutter/material.dart';
import 'package:shopping_app/data/categories.dart';
import 'package:shopping_app/models/category.dart';
import 'package:shopping_app/models/grocery_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();

  // final _nameController = TextEditingController();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  final url = Uri.https('shopping-app-27348-default-rtdb.firebaseio.com','shopping-list.json');

  void _saveItem() async {
    _formKey.currentState!.validate();
    _formKey.currentState!.save();

    final response = await http.post(url,headers: {
      'Content-Type' : 'application/json'},
       body: json.encode({
      'name': _enteredName,
      'quantity': _enteredQuantity,
      'category': _selectedCategory.title
    })
    );
   if(!context.mounted){
    return;
   }
   Navigator.of(context).pop();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Item')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              // controller: _nameController,
              maxLength: 50,
              decoration: const InputDecoration(label: Text('Name')),
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    value.trim().length < 1 ||
                    value.length > 50) {
                  return "Please enter a valid name ";
                }
                return null;
              },
              keyboardType: TextInputType.text,
              onSaved: (value){
                _enteredName = value! ;
              },
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(label: Text('Quantity')),
                    initialValue: _enteredQuantity.toString(),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null ||
                          int.tryParse(value)! <= 0) {
                        return "Please enter a valid number";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    onSaved: (value){
                      _enteredQuantity = int.parse(value!);
                    },
                  )),
                const SizedBox(width: 36),
                Expanded(
                  child: DropdownButtonFormField(
                    value: _selectedCategory,
                    items: [
                    for (final category in categories.entries)
                      DropdownMenuItem(
                          value: category.value,
                          child: Row(
                            children: [
                              Container(
                                  width: 24,
                                  height: 24,
                                  color: category.value.color),
                              const SizedBox(
                                width: 6,
                              ),
                              Text(category.value.title)
                            ],
                          ))
                                                    ], 
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  }),
                )
              ],
            ),
            const SizedBox(
              height:20
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () {
                      _formKey.currentState!.reset();
                    },
                    child: const Text('Reset')),
                ElevatedButton(
                    onPressed: _saveItem, child: const Text('Submit'))
              ],
            )
          ]),
        ),
      ),
    );
  }
}

