import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../helpers/sql_helper.dart';
import '../models/order.dart';
import '../models/order_items.dart';
import '../widgets/app_table.dart';

class AllSales extends StatefulWidget {
  const AllSales({Key? key}) : super(key: key);

  @override
  State<AllSales> createState() => _AllSalesState();
}

class _AllSalesState extends State<AllSales> {
  List<Order>? orders;
  List<Order>? filteredOrders;
  TextEditingController searchController = TextEditingController();
  TextEditingController minPriceController = TextEditingController();
  TextEditingController maxPriceController = TextEditingController();
  TextEditingController clientNameController = TextEditingController();

  bool _sortNameAsc = true;

  int? _sortColumnIndex;

  bool _sortAsc = true;


  @override
  void initState() {
    super.initState();
    getOrders();
    setState(() {});
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
      filteredOrders = orders;
    } catch (e) {
      print('Error In get data $e');
      orders = [];
    }
    setState(() {});
  }

  void filterOrders(String query, double? minPrice, double? maxPrice, String clientName) {
    filteredOrders = orders?.where((order) {
      final clientNameMatch = clientName.isEmpty || order.clientName!.toLowerCase().contains(clientName.toLowerCase());
      final labelMatch = query.isEmpty || order.label!.toLowerCase().contains(query.toLowerCase());
      final priceMatch = (minPrice == null || order.totalPrice! >= minPrice) &&
          (maxPrice == null || order.totalPrice! <= maxPrice);
      return clientNameMatch && labelMatch && priceMatch;
    }).toList();
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: searchController,
              onChanged: (value) {
                filterOrders(value, double.tryParse(minPriceController.text), double.tryParse(maxPriceController.text), clientNameController.text);
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                labelText: 'Search by Label',
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: minPriceController,
                    onChanged: (value) {
                      filterOrders(searchController.text, double.tryParse(value), double.tryParse(maxPriceController.text), clientNameController.text);
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Min Price',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: maxPriceController,
                    onChanged: (value) {
                      filterOrders(searchController.text, double.tryParse(minPriceController.text), double.tryParse(value), clientNameController.text);
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Max Price',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: AppTable(
                minWidth: 1100,
                columns:  [
                  DataColumn(label: Text('Id'),
                      onSort: (columnIndex, sortAscending){
                        setState(() {
                          if (columnIndex == _sortColumnIndex) {
                            _sortAsc = _sortNameAsc = sortAscending;
                          } else {
                            _sortColumnIndex = columnIndex;
                            _sortAsc = _sortNameAsc;
                          }
                          orders!.sort((a, b) => a.totalPrice!.compareTo(b.totalPrice!));
                          if (!_sortAsc) {
                            orders = orders!.reversed.toList();
                          }
                        });
                      }
                  ),
                  DataColumn(label: Text('Label')),
                  DataColumn(label: Text('Total Price')),
                  DataColumn(label: Text('Discount')),
                  DataColumn(label: Text('Client Name')),
                  DataColumn(label: Text('Client Phone')),
                  DataColumn(label: Text('Client Address')),
                  DataColumn(label: Center(child: Text('Actions'))),
                ],
                source: OrderDataSource(
                  ordersEx: filteredOrders,
                  onDelete: (order) {
                    onDeleteRow(order.id!);
                  },
                  onShow: (order) {
                    showOrderDetails(context, order);
                  },
                ),
              ),
            ),
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
            content: const Text('Are you sure you want to delete this Sale?'),
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
        },
      );

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

  void showOrderDetails(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Order Details - ${order.label}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 16),
                FutureBuilder<List<OrderItem>>(
                  future: getOrderItems(order.id!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('No items found.');
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: snapshot.data!.map((orderItem) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (orderItem.product != null &&
                                    orderItem.product!.image != null &&
                                    orderItem.product!.image!.isNotEmpty)
                                  Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            orderItem.product!.image!),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        orderItem.product?.name ?? '',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Quantity: ${orderItem.productCount}',
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Total Price: ${(orderItem.productCount ?? 0) * (orderItem.product?.price ?? 0)}',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<OrderItem>> getOrderItems(int orderId) async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.rawQuery("""
      select OI.*, P.name as productName, P.image as productImage, P.price as productPrice
      from orderProductItems OI
      inner join products P on OI.productId = P.id
      where OI.orderId = ?
      """, [orderId]);

      List<OrderItem> orderItems = [];
      for (var item in data) {
        orderItems.add(OrderItem.fromJson(item));
      }
      return orderItems;
    } catch (e) {
      print('Error In get order items data $e');
      return [];
    }
  }

}

class OrderDataSource extends DataTableSource {
  List<Order>? ordersEx;
  void Function(Order) onShow;
  void Function(Order) onDelete;

  OrderDataSource({
    required this.ordersEx,
    required this.onShow,
    required this.onDelete,
  });

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
            icon: const Icon(Icons.visibility),
          ),
          IconButton(
            onPressed: () {
              onDelete(ordersEx![index]);
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
  int get rowCount => ordersEx?.length ?? 0;

  @override
  int get selectedRowCount => 0;
}