import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../helpers/sql_helper.dart';
import '../models/client.dart';
import '../widgets/app_elevated_button.dart';
import '../widgets/app_text_formfield.dart';

class ClientsOpsPage extends StatefulWidget {
  final ClientData? clientData;
  const ClientsOpsPage({super.key, this.clientData});

  @override
  State<ClientsOpsPage> createState() => _ClientsOpsPageState();
}

class _ClientsOpsPageState extends State<ClientsOpsPage> {
  var formKey = GlobalKey<FormState>();
  TextEditingController? nameController;
  TextEditingController? phoneController;
  TextEditingController? emailController;
  TextEditingController? addressController;
  void initState() {
    nameController = TextEditingController(text: widget.clientData?.name);
    phoneController = TextEditingController(text: widget.clientData?.phone);
    emailController = TextEditingController(text: widget.clientData?.email);
    addressController = TextEditingController(text: widget.clientData?.address);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clientData != null ? 'Update' : 'Add New'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextFormField(
                controller: nameController!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                label: 'Name',
              ),
              const SizedBox(height: 8,),
              AppTextFormField(
                controller: phoneController!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
                label: 'Phone',
              ),
              const SizedBox(height: 8,),
              AppTextFormField(
                controller: emailController!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
                label: 'Email',
              ),
              const SizedBox(height: 8,),
              AppTextFormField(
                controller: addressController!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
                label: 'Address',
              ),
              const SizedBox(height: 16),
              AppElevatedButton(
                  onPressed: () async {
                    onSubmit();
                  },
                  label: 'Submit'),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> onSubmit() async {
    try {
      if (formKey.currentState!.validate()) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        if (widget.clientData != null) {
          await sqlHelper.db!.update(
              'clients',
              {
                'name': nameController!.text,
                'phone': phoneController!.text,
                'email': emailController!.text,
                'address': addressController!.text,
              },
              where: 'id =?',
              whereArgs: [widget.clientData?.id]);
        } else{
          await sqlHelper.db!.insert('clients', {
            'name': nameController!.text,
            'phone': phoneController!.text,
            'email': emailController!.text,
            'address': addressController!.text,
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: Text('client saved Successfully')));
        Navigator.pop(context, true);
        }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error In adding client : $e')));
    }
  }
}
