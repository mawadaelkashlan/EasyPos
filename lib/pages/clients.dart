import 'package:data_table_2/data_table_2.dart';
import 'package:final_project_level1/helpers/sql_helper.dart';
import 'package:final_project_level1/models/client.dart';
import 'package:final_project_level1/widgets/app_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../widgets/app_text_formfield.dart';

class Clients extends StatefulWidget {
  const Clients({super.key});

  @override
  State<Clients> createState() => _ClientsState();
}

class _ClientsState extends State<Clients> {
  List<ClientData>? clients;

  @override
  void initState() {
    getClients();
    super.initState();
  }

  void getClients() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.query('clients');
      if (data.isNotEmpty) {
        clients = [];
        for (var item in data) {
          clients!.add(ClientData.fromJson(item));
        }
      } else {
        clients = [];
      }
    } catch (e) {
      print('Error In get clients data $e');
      clients = [];
    }
    setState(() {});
  }
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Clients"),
        actions: [
          IconButton(
            onPressed: () {
              showAddClientSheet();
            },
            icon: Icon(Icons.add),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            
            Expanded(
              child: PaginatedDataTable2(
                empty: const Center(
                  child: Text('No Data Found'),
                ),
                headingRowHeight: 40,
                renderEmptyRowsInTheEnd: false,
                isHorizontalScrollBarVisible: true,
                minWidth: 700,
                wrapInCard: false,
                rowsPerPage: 15,
                headingTextStyle:
                const TextStyle(color: Colors.white, fontSize: 18),
                headingRowColor:
                MaterialStatePropertyAll(Theme.of(context).primaryColor),
                border: TableBorder.all(color: Colors.grey),
                columnSpacing: 20,
                horizontalMargin: 20,
                columns: const [
                  DataColumn(label: Text('Id')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Phone')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Address')),
                  DataColumn(label: Center(child: Text('Actions'))),
                ],
                source: MyDataTableSource(clients, getClients),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showAddClientSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextFormField(
                  controller: nameController,
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
                  controller: phoneController,
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
                  controller: emailController,
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
                  controller: addressController,
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
                    label: 'Add Client'),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> onSubmit() async {
    try {
      if (formKey.currentState!.validate()) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        await sqlHelper.db!.insert('clients', {
          'name': nameController.text,
          'phone': phoneController.text,
          'email': emailController.text,
          'address': addressController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: Text('client added Successfully')));
        Navigator.pop(context, true);
        getClients();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error In adding client : $e')));
    }
  }
}

class MyDataTableSource extends DataTableSource {
  List<ClientData>? clientsEx;

  void Function() getClients;

  MyDataTableSource(this.clientsEx, this.getClients);

  @override
  DataRow? getRow(int index) {
    return DataRow2(cells: [
      DataCell(Text('${clientsEx?[index].id}')),
      DataCell(Text('${clientsEx?[index].name}')),
      DataCell(Text('${clientsEx?[index].phone}')),
      DataCell(Text('${clientsEx?[index].email}')),
      DataCell(Text('${clientsEx?[index].address}')),
      DataCell(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(onPressed: () async {}, icon: const Icon(Icons.edit)),
          IconButton(
              onPressed: () async {
                await onDeleteRow(clientsEx?[index].id ?? 0);
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              )),
        ],
      )),
    ]);
  }

  Future<void> onDeleteRow(int id) async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var result = await sqlHelper.db!.delete(
        'Clients',
        where: 'id =?',
        whereArgs: [id],
      );
      if (result > 0) {
        getClients();
      }
    } catch (e) {
      print('Error In delete data $e');
    }
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => clientsEx?.length ?? 0;

  @override
  int get selectedRowCount => 0;
}