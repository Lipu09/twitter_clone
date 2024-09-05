/*

Account settings page

this page contains various settings related to suer account.

 - delete own account (This feature is a requirement if you want to publish this to the app store!)

 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:twitter_clone/services/auth/auth_service.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({Key? key}) : super(key: key);

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {

  // ask for confirmation form the user before deleting their account
  void confirmDeletion(BuildContext context){
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text("Delete Account"),
      content: Text("Are you sure you want to delete this account"),
      actions: [
        //cancel button
        TextButton(onPressed: ()=>Navigator.pop(context), child: Text("Cancel")),

        //delete button
        TextButton(
            onPressed: () async{

              //delete account user
              await AuthService().deleteAccount();

              // then navigate to initial route(Auth gate -> login / register page)
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);

            },
            child: Text("Delete"))
      ],
    ),);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 55.0),
          child: Text("Account Settings"),
        ),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          //delete tile
          GestureDetector(
            onTap: ()=> confirmDeletion(context),
            child: Container(
              padding: EdgeInsets.all(25),
              margin: EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Text("Delete Account" , style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),)),
            ),
          )
        ],
      ),
    );
  }
}
