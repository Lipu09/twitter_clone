/*

Follow list page

This page displays a tab bar for ( a given uid):
  - a list of all followers
  - a list of all following

 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/components/my_user_tile.dart';
import 'package:twitter_clone/services/database/database_provider.dart';
import 'package:twitter_clone/services/database/database_service.dart';

import '../models/user.dart';

class FollowListPage extends StatefulWidget {
  final String uid;
  const FollowListPage({Key? key , required this.uid}) : super(key: key);

  @override
  State<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends State<FollowListPage> {

  //providers
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider = Provider.of<DatabaseProvider>(context ,listen: false);

  //on stratup,
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //load follower list
    loadFollowerList();

    //load following list
    loadFollowingList();
  }

  //load followers
  Future<void> loadFollowerList() async{
    await databaseProvider.loadUserFollowerProfiles(widget.uid);
  }

  //load following
  Future<void> loadFollowingList() async{
    await databaseProvider.loadUserFollowingProfiles(widget.uid);
  }

  @override
  Widget build(BuildContext context) {

    //listen to followers & following
    final followers =listeningProvider.getListOfFollowersProfile(widget.uid);
    final following =listeningProvider.getListOfFollowingProfile(widget.uid);

    //tab controller
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            foregroundColor: Theme.of(context).colorScheme.primary,
            bottom: TabBar(
              dividerColor: Colors.transparent,
              labelColor:Theme.of(context).colorScheme.inversePrimary ,
              unselectedLabelColor: Theme.of(context).colorScheme.primary,
              indicatorColor: Theme.of(context).colorScheme.secondary,

              //tabs
              tabs: [
                Tab(text: "Followers",),
                Tab(text: "Following",),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildUserList(
                  followers,
                  "No followers.."
              ),
              _buildUserList(following, "No following.."),
            ],
          ),
        )
    );
  }

  // build user list , given a list of profiles
    Widget _buildUserList(List<UserProfile> userList , String emptyMessage){
    return userList.isEmpty
        ? // empty message if there are no users
    Center(child: Text(emptyMessage),)
        : //user list
    ListView.builder(
      itemCount: userList.length,
      itemBuilder: (context, index) {
      // get each user
      final user = userList[index];
      //return as a user list tile
      return MyUserTile(user: user);
    },);
    }
}
