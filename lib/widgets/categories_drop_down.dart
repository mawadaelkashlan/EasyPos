
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../helpers/sql_helper.dart';
import '../models/category.dart';

class CategoriesDropDown extends StatefulWidget {
  final int? selectedValue;
  final void Function(int?)? onChanged;
  const CategoriesDropDown(
      {super.key, this.selectedValue, required this.onChanged});

  @override
  State<CategoriesDropDown> createState() => _CategoriesDropDownState();
}

class _CategoriesDropDownState extends State<CategoriesDropDown> {
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
    return categories == null
        ? const Center(
      child: CircularProgressIndicator(),
    )
        : (categories?.isEmpty ?? false)
        ? const Center(
      child: Text('No Data Found'),
    )
        : Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.black)),
      child: Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: DropdownButton(
            underline: const SizedBox(),
            isExpanded: true,
            hint: const Text(
              'Select Category',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            value: widget.selectedValue,
            items: [
              for (var category in categories!)
                DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name ?? 'No Name'),
                ),
            ],
            onChanged: widget.onChanged),
      ),
    );
  }
}