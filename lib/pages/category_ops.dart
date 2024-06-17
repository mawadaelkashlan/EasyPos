import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../helpers/sql_helper.dart';
import '../models/category.dart';
import '../widgets/app_elevated_button.dart';
import '../widgets/app_text_formfield.dart';

class CategoriesOpsPage extends StatefulWidget {
  final CategoryData? categoryData;
  const CategoriesOpsPage({this.categoryData, super.key});

  @override
  State<CategoriesOpsPage> createState() => _CategoriesOpsPageState();
}

class _CategoriesOpsPageState extends State<CategoriesOpsPage> {
  var formKey = GlobalKey<FormState>();
  TextEditingController? nameController;
  TextEditingController? descriptionController;

  @override
  void initState() {
    nameController = TextEditingController(text: widget.categoryData?.name);
    descriptionController =
        TextEditingController(text: widget.categoryData?.description);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryData != null ? 'Update' : 'Add New'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
            key: formKey,
            child: Column(
              children: [
                AppTextFormField(
                    controller: nameController!,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                    label: 'Name'),
                const SizedBox(
                  height: 20,
                ),
                AppTextFormField(
                    controller: descriptionController!,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Description is required';
                      }
                      return null;
                    },
                    label: 'Description'),
                const SizedBox(
                  height: 20,
                ),
                AppElevatedButton(
                  label: 'Submit',
                  onPressed: () async {
                    await onSubmit();
                  },
                ),
              ],
            )),
      ),
    );
  }

  Future<void> onSubmit() async {
    try {
      if (formKey.currentState!.validate()) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        if (widget.categoryData != null) {
          // update logic
          await sqlHelper.db!.update(
              'categories',
              {
                'name': nameController?.text,
                'description': descriptionController?.text
              },
              where: 'id =?',
              whereArgs: [widget.categoryData?.id]);
        } else {
          await sqlHelper.db!.insert('categories', {
            'name': nameController?.text,
            'description': descriptionController?.text
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.green,
            content: Text('Category Saved Successfully')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error In Create Category : $e')));
    }
  }
}