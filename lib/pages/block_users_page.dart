/*

Blocked users page

this page displays a list of users that have blocked .
-you can unblock users here.

 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/services/database/database_provider.dart';

class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({Key? key}) : super(key: key);

  @override
  State<BlockedUsersPage> createState() => _BlockUsersPageState();
}

class _BlockUsersPageState extends State<BlockedUsersPage> {

  //providers
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider = Provider.of<DatabaseProvider>(context,listen: false);

  //on startup
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // load blocked users
    loadBlockedUsers();
  }

  //load block users
  Future<void> loadBlockedUsers() async{
    await databaseProvider.loadBlockedUsers();
  }

  //show confirm unblock box
  void _showUnblockConfirmationBox(String userId){
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text("Unblock Users"),
      content: Text("Are you sure you want to unblock this user"),
      actions: [
        //cancel button
        TextButton(onPressed: ()=>Navigator.pop(context), child: Text("Cancel")),

        //unblock button
        TextButton(
            onPressed: () async{

              //unblock user
              await databaseProvider.unblockUser(userId);

              //close the box
              Navigator.pop(context);

              // let user know it was successfully unblocked
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User unblocked!")));
            },
            child: Text("Unblock"))
      ],
    ),);
  }

  @override
  Widget build(BuildContext context) {

    // listen to blocked users
    final blockedUsers = listeningProvider.blockedUsers;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 60.0),
          child: Text("Blocked Users"),
        ),
        foregroundColor: Theme.of(context).colorScheme.primary,

      ),
      body: blockedUsers.isEmpty ?
          Center(child: Text("No blocked users..."),)
          :
          ListView.builder(
              itemCount: blockedUsers.length,
              itemBuilder: (context, index) {
                // get each user
                final user = blockedUsers[index];

                // return as a list tile ui
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text('@${user.username}'),
                  trailing: IconButton(
                    icon: Icon(Icons.block),
                    onPressed: ()=> _showUnblockConfirmationBox(user.uid),
                  ),
                );
              },
          )
    );
  }
}
