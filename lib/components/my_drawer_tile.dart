import 'package:flutter/material.dart';

/*
 This is a simple tile for each item in the menu drawer.
 */

class MyDrawerTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final void Function()? onTap;
  const MyDrawerTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title , style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
      leading: Icon(icon , color: Theme.of(context).colorScheme.primary,),
      onTap: onTap,
    );
  }
}
