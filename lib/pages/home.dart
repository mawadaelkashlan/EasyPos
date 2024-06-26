import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../helpers/sql_helper.dart';
import '../pages/all_sales.dart';
import '../pages/products.dart';
import '../pages/sale_ops_page.dart';
import '../widgets/grid_view_item.dart';
import '../pages/clients.dart';
import '../pages/categories.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  bool isTableInitialized = false;

  double? exchangeRate;
  double? todaySales; // Variable to hold today's sales

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    var sqlHelper = GetIt.I.get<SqlHelper>();
    isTableInitialized = await sqlHelper.createTables();
    exchangeRate = await sqlHelper.getExchangeRate('USD_TO_EGP');
    calculateTodaySales(); // Calculate today's sales on init
    isLoading = false;
    setState(() {});
  }

  void calculateTodaySales() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      var result = await sqlHelper.db!.rawQuery("""
        SELECT SUM(totalPrice) AS totalSales 
        FROM orders 
        WHERE date(orderDate) = date(?)
      """, [formattedDate]);

      setState(() {
        todaySales = result.isNotEmpty ? (result.first['totalSales'] ?? 0.0) as double? : 0.0;
      });
    } catch (e) {
      print('Error calculating today\'s sales: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 3 + (kIsWeb ? 40 : 0),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(45),
                bottomRight: Radius.circular(45),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nilu app',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      isLoading
                          ? Transform.scale(
                        scale: .5,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                          : CircleAvatar(
                        backgroundColor:
                        isTableInitialized ? Colors.lightGreen : Colors.red,
                        radius: 10,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  cardContent('Exchange Rate', '1 USD = $exchangeRate'),
                  cardContent('Today\'s Sales', '${todaySales ?? 'Loading...'} UZS'),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              color: const Color(0xfffbfafb),
              child: GridView.count(
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                crossAxisCount: 2,
                children: [
                  GridViewItem(
                    color: Colors.orange,
                    label: 'All Sales',
                    iconData: Icons.calculate,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => AllSales()));
                    },
                  ),
                  GridViewItem(
                    color: Colors.pink,
                    label: 'Products',
                    iconData: Icons.inventory_2,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ProductsPage()));
                    },
                  ),
                  GridViewItem(
                    color: Colors.lightBlue,
                    label: 'Clients',
                    iconData: Icons.group,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => Clients()));
                    },
                  ),
                  GridViewItem(
                    color: Colors.green,
                    label: 'New Sale',
                    iconData: Icons.point_of_sale,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => SaleOpsPage()));
                    },
                  ),
                  GridViewItem(
                    color: Colors.yellow,
                    label: 'Categories',
                    iconData: Icons.category,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => CategoriesPage()));
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget cardContent(String label, String value) {
    return Card(
      color: const Color(0xff206ce1),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}