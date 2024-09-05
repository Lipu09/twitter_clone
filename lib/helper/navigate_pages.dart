import 'package:flutter/material.dart';
import 'package:twitter_clone/pages/home_page.dart';
import 'package:twitter_clone/pages/profile_page.dart';

import '../models/post.dart';
import '../pages/account_settings_page.dart';
import '../pages/block_users_page.dart';
import '../pages/post_page.dart';

//go to user page
void goUserPage(BuildContext context , String uid){
  // navigate to the page
  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(uid: uid),));
}

//go to post page
void goPostPage(BuildContext context , Post post){
 //navigate to the post page
 Navigator.push(context, MaterialPageRoute(builder: (context) => PostPage(post: post,),));
}

// go to blocked user page
 void goToBlockedUsersPage(BuildContext context){
  //navigate to page
   Navigator.push(context, MaterialPageRoute(builder: (context) => BlockedUsersPage(),));
 }

 //go to account settings page
 void goAccountSettingsPage(BuildContext context){
  //navigate to page
   Navigator.push(
       context, MaterialPageRoute(builder: (context) => AccountSettingsPage(),));
 }

 // go home page( but remove all previous routes , this is good for reload)
void goHomePage(BuildContext context){
  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage(),), (route) => route.isFirst);
}