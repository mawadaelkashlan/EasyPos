import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../helpers/sql_helper.dart';
import '../models/category.dart';
import '../widgets/app_table.dart';
import 'category_ops.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<CategoryData>? categories;
  List<CategoryData>? allCategories;

  @override
  void initState() {
    getCategories();
    super.initState();
  }

  void getCategories() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.query('categories');

      if (data.isNotEmpty) {
        categories = [];
        allCategories = [];
        for (var item in data) {
          var category = CategoryData.fromJson(item);
          categories!.add(category);
          allCategories!.add(category);
        }
      } else {
        categories = [];
        allCategories = [];
      }
    } catch (e) {
      print('Error In get data $e');
      categories = [];
      allCategories = [];
    }
    setState(() {});
  }

  String selectedFilter = 'name';

  void searchCategories(String query) {
    if (query.isEmpty) {
      categories = allCategories;
    } else {
      categories = allCategories!.where((category) {
        final categoryValue = (selectedFilter == 'name'
            ? category.name
            : selectedFilter == 'description'
            ? category.description
            : '')!
            .toLowerCase();
        final searchQuery = query.toLowerCase();

        return categoryValue.contains(searchQuery);
      }).toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
              onPressed: () async {
                var result = await Navigator.push(context,
                    MaterialPageRoute(builder: (ctx) => CategoriesOpsPage()));
                if (result ?? false) {
                  getCategories();
                }
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: searchCategories,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      labelText: 'Search',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedFilter,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedFilter = newValue!;
                    });
                  },
                  items: <String>['name', 'description']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: AppTable(
                columns: const [
                  DataColumn(label: Text('Id')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Description')),
                  DataColumn(label: Center(child: Text('Actions'))),
                ],
                source: CategoriesTableSource(
                  categoriesEx: categories,
                  onUpdate: (categoryData) async {
                    var result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (ctx) => CategoriesOpsPage(
                              categoryData: categoryData,
                            )));
                    if (result ?? false) {
                      getCategories();
                    }
                  },
                  onDelete: (categoryData) {
                    onDeleteRow(categoryData.id!);
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> onDeleteRow(int id) async {
    try {
      var dialogResult = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete Category'),
              content:
              const Text('Are you sure you want to delete this category?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          });

      if (dialogResult ?? false) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        var result = await sqlHelper.db!.delete(
          'categories',
          where: 'id =?',
          whereArgs: [id],
        );
        if (result > 0) {
          getCategories();
        }
      }
    } catch (e) {
      print('Error In delete data $e');
    }
  }
}

class CategoriesTableSource extends DataTableSource {
  List<CategoryData>? categoriesEx;

  void Function(CategoryData) onUpdate;
  void Function(CategoryData) onDelete;
  CategoriesTableSource({
    required this.categoriesEx,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    return DataRow2(cells: [
      DataCell(Text('${categoriesEx?[index].id}')),
      DataCell(Text('${categoriesEx?[index].name}')),
      DataCell(Text('${categoriesEx?[index].description}')),
      DataCell(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              onUpdate(categoriesEx![index]);
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () {
              onDelete(categoriesEx![index]);
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => categoriesEx?.length ?? 0;

  @override
  int get selectedRowCount => 0;
}