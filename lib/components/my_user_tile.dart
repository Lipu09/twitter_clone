/*

LIST TILE

 This is to display each user as a nice tile , we will user this when we need to display a list of users,
 for e.g. in the user search results or viewing the followers of a user,

 ...........................................................................................................

 To use this widget , you need:
 - a user

 */

import 'package:flutter/material.dart';
import 'package:twitter_clone/models/user.dart';
import 'package:twitter_clone/pages/profile_page.dart';

class MyUserTile extends StatelessWidget {
  final UserProfile user;
  const MyUserTile({Key? key , required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      //padding outside
      margin: EdgeInsets.symmetric(horizontal: 25,vertical: 5),
      //padding inside
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        //color of tile
        color: Theme.of(context).colorScheme.secondary,

        //curve corners
        borderRadius: BorderRadius.circular(8),

      ),
      child: ListTile(
        title: Text(user.name),
        titleTextStyle: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
        subtitle: Text('@${user.username}'),
        subtitleTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        leading: Icon(Icons.person,color: Theme.of(context).colorScheme.primary,),
        
        // on tap -> go to user's profile
        onTap: ()=>Navigator.push(context, 
            MaterialPageRoute(builder: (context) => ProfilePage(uid: user.uid),)),
        trailing: Icon(Icons.arrow_forward,color: Theme.of(context).colorScheme.inversePrimary,),
      ),
    );
  }
}
