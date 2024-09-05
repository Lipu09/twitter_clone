import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  const MyButton({Key? key,required this.text,required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(25),
        decoration: BoxDecoration(
          //color
          color: Theme.of(context).colorScheme.secondary,

          //curver curners
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
            child: Text(text,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),)
        ),
      ),
    );
  }
}
