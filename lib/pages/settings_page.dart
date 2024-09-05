import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/components/my_settings_tile.dart';
import 'package:twitter_clone/themes/theme_provider.dart';

import '../helper/navigate_pages.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 65.0),
          child: Text("S E T T I N G S"),
        ),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          //Dark mode title
          MySettingsTile(
              title: "Dark Mode",
              action: CupertinoSwitch(
                onChanged: (value)=>Provider.of<ThemeProvider>(context,listen: false).toggleTheme(),
                value:Provider.of<ThemeProvider>(context,listen: false).isDarkMode ,
              ),
          ),

          //Block user tile
          MySettingsTile(
              title: "Blocked Users",
              action: IconButton(
                  onPressed: ()=>goToBlockedUsersPage(context),
                  icon: Icon(Icons.arrow_forward,color: Theme.of(context).colorScheme.primary,)),
          ),

          //Account settings tile
          MySettingsTile(
              title: "Account Settings",
              action: IconButton(
                onPressed: ()=> goAccountSettingsPage(context),
                icon: Icon(Icons.arrow_forward , color: Theme.of(context).colorScheme.primary,),
              )
          )
        ],
      ),
    );
  }
}
