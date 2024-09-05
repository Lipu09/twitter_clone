import 'package:flutter/material.dart';

class MyInputAlertBox extends StatelessWidget {

  final TextEditingController textController;
  final String hintText;
  final void Function()? onPressed;
  final String onPressedText;

  const MyInputAlertBox({Key? key,
    required this.textController,
    required this.hintText,
    required this.onPressed ,
    required this.onPressedText
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      //Curve corners
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      // textfield (user types here)
      content: TextField(
        controller: textController,

        //let's limit the max character
        maxLength: 140,
        maxLines: 3,

        decoration: InputDecoration(
          // border when textfield is unselected
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
            borderRadius: BorderRadius.circular(12),
          ),

          // border when textfield is selected
           focusedBorder: OutlineInputBorder(
             borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
             borderRadius: BorderRadius.circular(12),
           ),

          //hint text
          hintText: hintText,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),

          //color inside of textfield
          fillColor: Theme.of(context).colorScheme.secondary,
          filled: true,
          //counter style
          counterStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),

      ),

      //buttons
      actions: [
        //cancel button
        TextButton(
            onPressed: (){
              Navigator.pop(context);
              //clear the controller
              textController.clear();
            },
            child: Text("Cancel"),
        ),
        // yse button
        TextButton(
            onPressed: (){
              Navigator.pop(context);

              //execute function
              onPressed!();
              textController.clear();
            },
            child: Text(onPressedText)
        )
      ],
    );
  }
}
