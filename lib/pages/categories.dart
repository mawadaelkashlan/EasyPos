import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../helpers/sql_helper.dart';
import '../models/category.dart';
import 'category_ops.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<CategoryData>? categories;

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
        for (var item in data) {
          categories!.add(CategoryData.fromJson(item));
        }
      } else {
        categories = [];
      }
    } catch (e) {
      print('Error In get data $e');
      categories = [];
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
            SizedBox(
              height: 40,
              child: TextField(
                onChanged: (value) async {
                  var sqlHelper = GetIt.I.get<SqlHelper>();
                  var result = await sqlHelper.db!.rawQuery("""
                    SELECT * FROM Categories
                    WHERE name LIKE '%$value%' OR description LIKE '%$value%';
                      """);
                  print('values:${result}');
                },
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  labelText: 'Search',
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: PaginatedDataTable2(
                empty: const Center(
                  child: Text('No Data Found'),
                ),
                headingRowHeight: 40,
                renderEmptyRowsInTheEnd: false,
                isHorizontalScrollBarVisible: true,
                minWidth: 500,
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
                  DataColumn(label: Text('Description')),
                  DataColumn(label: Center(child: Text('Actions'))),
                ],
                source: MyDataTableSource(categories, getCategories),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyDataTableSource extends DataTableSource {
  List<CategoryData>? categoriesEx;

  void Function() getCategories;

  MyDataTableSource(this.categoriesEx, this.getCategories);

  @override
  DataRow? getRow(int index) {
    return DataRow2(cells: [
      DataCell(Text('${categoriesEx?[index].id}')),
      DataCell(Text('${categoriesEx?[index].name}')),
      DataCell(Text('${categoriesEx?[index].description}')),
      DataCell(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(onPressed: () async {}, icon: const Icon(Icons.edit)),
          IconButton(
              onPressed: () async {
                await onDeleteRow(categoriesEx?[index].id ?? 0);
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
        'categories',
        where: 'id =?',
        whereArgs: [id],
      );
      if (result > 0) {
        getCategories();
      }
    } catch (e) {
      print('Error In delete data $e');
    }
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => categoriesEx?.length ?? 0;

  @override
  int get selectedRowCount => 0;
}
