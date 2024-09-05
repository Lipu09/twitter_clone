import 'package:flutter/material.dart';

//show loading circle
void showLoadingCircle(BuildContext context){
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Center(
          child:CircularProgressIndicator() ,
        ),
      ),
  );
}

//hide loading cirlce
void hideLoadingCircle(BuildContext context){
  Navigator.pop(context);
}