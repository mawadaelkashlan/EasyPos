import 'package:final_project_level1/helpers/sql_helper.dart';
import 'package:final_project_level1/pages/all_sales.dart';
import 'package:final_project_level1/pages/products.dart';
import 'package:final_project_level1/pages/sale_ops_page.dart';
import 'package:final_project_level1/widgets/grid_view_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'categories.dart';
import 'clients.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  bool isTableInitialized = false;

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    var sqlHelper = GetIt.I.get<SqlHelper>();
    isTableInitialized = await sqlHelper.createTables();
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Container(),
      appBar: AppBar(),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 3 + (kIsWeb ? 40 : 0) ,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(45),
                    bottomRight: Radius.circular(45))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Nilu app',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w400),
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: isLoading
                              ? Transform.scale(
                                  scale: .5,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : CircleAvatar(
                                  backgroundColor: isTableInitialized
                                      ? Colors.lightGreen
                                      : Colors.red,
                                  radius: 10,
                                )),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  cardContent('Exchange Rate', '1 USD = 50 EGP'),
                  cardContent('Today\'s sales', '10,000 UZS'),
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
              children:  [
                GridViewItem(
                  color: Colors.orange,
                  label: 'All Sales',
                  iconData: Icons.calculate, onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => AllSales()));
                },
                ),
                GridViewItem(
                  color: Colors.pink,
                  label: 'Products',
                  iconData: Icons.inventory_2, onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => ProductsPage()));
                },
                ),
                GridViewItem(
                  color: Colors.lightBlue,
                  label: 'Clients',
                  iconData: Icons.group, onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> Clients()));
                },
                ),
                GridViewItem(
                  color: Colors.green,
                  label: 'New Sale',
                  iconData: Icons.point_of_sale, onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> SaleOpsPage()));
                },
                ),
                GridViewItem(
                  color: Colors.yellow,
                  label: 'Categories',
                  iconData: Icons.category, onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => CategoriesPage()));
                },
                ),
              ],
            ),
          ))
        ],
      ),
    );
  }

  Widget cardContent(
    String label,
    String value,
  ) {
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
