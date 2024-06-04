import 'package:flutter/material.dart';

class GridViewItem extends StatelessWidget {
  final Color color;
  final String label;
  final IconData iconData;
  final void Function()? onPressed;

  const GridViewItem({
    super.key,
    required this.color,
    required this.label,
    required this.iconData,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Card(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(.3),
              radius: 40,
              child: Icon(
                iconData,
                color: color,
                size: 40,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              label,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
