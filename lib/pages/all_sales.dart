import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../helpers/sql_helper.dart';
import '../models/order.dart';
import '../widgets/app_table.dart';

class AllSales extends StatefulWidget {
  const AllSales({super.key});

  @override
  State<AllSales> createState() => _AllSalesState();
}

class _AllSalesState extends State<AllSales> {
  List<Order>? orders;

  @override
  void initState() {
    getOrders();
    super.initState();
  }

  void getOrders() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.rawQuery("""
      select O.* ,C.name as clientName,C.phone as clientPhone,C.address as clientAddress 
      from orders O
      inner join clients C
      where O.clientId = C.id
      """);

      if (data.isNotEmpty) {
        orders = [];
        for (var item in data) {
          orders!.add(Order.fromJson(item));
        }
      } else {
        orders = [];
      }
    } catch (e) {
      print('Error In get data $e');
      orders = [];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Sales'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) async {
                var sqlHelper = GetIt.I.get<SqlHelper>();
                await sqlHelper.db!.rawQuery("""
        SELECT * FROM orders
        WHERE label LIKE '%$value%';
          """);
              },
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
            const SizedBox(
              height: 10,
            ),
            Expanded(
                child: AppTable(
                    minWidth: 1100,
                    columns: const [
                      DataColumn(label: Text('Id')),
                      DataColumn(label: Text('Label')),
                      DataColumn(label: Text('Total Price')),
                      DataColumn(label: Text('Discount')),
                      DataColumn(label: Text('Client Name')),
                      DataColumn(label: Text('Client phone')),
                      DataColumn(label: Text('Client Address')),
                      DataColumn(label: Center(child: Text('Actions'))),
                    ],
                    source: OrderDataSource(
                      ordersEx: orders,
                      onDelete: (order) {
                        onDeleteRow(order.id!);
                      },
                      onShow: (order) {},
                    ))),
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
              title: const Text('Delete Sale'),
              content:
              const Text('Are you sure you want to delete this Sale?'),
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
          'orders',
          where: 'id =?',
          whereArgs: [id],
        );
        if (result > 0) {
          getOrders();
        }
      }
    } catch (e) {
      print('Error In delete data $e');
    }
  }

}

class OrderDataSource extends DataTableSource {
  List<Order>? ordersEx;

  void Function(Order) onShow;
  void Function(Order) onDelete;

  OrderDataSource(
      {required this.ordersEx, required this.onShow, required this.onDelete});

  @override
  DataRow? getRow(int index) {
    return DataRow2(cells: [
      DataCell(Text('${ordersEx?[index].id}')),
      DataCell(Text('${ordersEx?[index].label}')),
      DataCell(Text('${ordersEx?[index].totalPrice}')),
      DataCell(Text('${ordersEx?[index].discount}')),
      DataCell(Text('${ordersEx?[index].clientName}')),
      DataCell(Text('${ordersEx?[index].clientPhone}')),
      DataCell(Text('${ordersEx?[index].clientAddress}')),
      DataCell(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              onPressed: () {
                onShow(ordersEx![index]);
              },
              icon: const Icon(Icons.visibility)),
          IconButton(
              onPressed: () {
                onDelete(ordersEx![index]);
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              )),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => ordersEx?.length ?? 0;

  @override
  int get selectedRowCount => 0;
}
