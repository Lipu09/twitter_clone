import 'package:flutter/material.dart';
import 'package:twitter_clone/components/my_drawer_tile.dart';
import 'package:twitter_clone/pages/profile_page.dart';
import 'package:twitter_clone/services/auth/auth_service.dart';

import '../pages/search_page.dart';
import '../pages/settings_page.dart';
/*

This is a menu drawer is usually acess on the left side of the app bar
.....................................................................
Contains 5 options :

-home
-profile
-search
-settings
-logout
 */

class MyDrawer extends StatelessWidget {
  MyDrawer({Key? key}) : super(key: key);

  //access auth service

  final _auth =AuthService();

  //logout
  void logout(){
    _auth.logout();
  }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              //app logo
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50.0),
                child: Icon(Icons.person , size: 72,color: Theme.of(context).colorScheme.primary,),
              ),
              //divider line
              Divider(
                color: Theme.of(context).colorScheme.secondary,
              ),
              SizedBox(height: 10,),
              // home list tile
              MyDrawerTile(
                title: "H O M E",
                icon: Icons.home,
                onTap: (){
                  //pop the menu drawer
                  Navigator.pop(context);
                },
              ),
              MyDrawerTile(
                  title: "P R O F I L E",
                  icon: Icons.person,
                  onTap: (){
                    Navigator.pop(context);

                    //go to the profile page
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(uid: _auth.getCurrentUid()),));
                  },
              ),

              // search list tile
              MyDrawerTile(
                title: "S E A R C H",
                icon: Icons.search,
                onTap: (){
                  //pop the menu drawer
                  Navigator.pop(context);
                  // GO TO SETTINGS PAGE
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage(),));
                },
              ),

              // settings list tile
              MyDrawerTile(
                  title: "S E T T I N G S",
                  icon: Icons.settings,
                  onTap: (){
                    //pop the menu drawer
                    Navigator.pop(context);
                    // GO TO SETTINGS PAGE
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage(),));
                  },
              ),
              Spacer(),
              MyDrawerTile(
                  title: "L O G O U T",
                  icon: Icons.logout,
                  onTap: logout,
              ),
              SizedBox(height: 35,),
            ],
          ),
        ),
      ),
    );
  }
}

