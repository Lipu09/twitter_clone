import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/components/my_bio_box.dart';
import 'package:twitter_clone/components/my_follow_buttton.dart';
import 'package:twitter_clone/components/my_input_alert_box.dart';
import 'package:twitter_clone/components/my_post_tile.dart';
import 'package:twitter_clone/components/my_profile_stats.dart';
import 'package:twitter_clone/helper/navigate_pages.dart';
import 'package:twitter_clone/models/user.dart';
import 'package:twitter_clone/services/auth/auth_service.dart';
import 'package:twitter_clone/services/database/database_provider.dart';

import 'follow_list_page.dart';

class ProfilePage extends StatefulWidget {
  //USER ID
  final String uid;
  const ProfilePage({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //providers
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider = Provider.of<DatabaseProvider>(context,listen: false);

  //user info
  UserProfile? user;
  String currentUserId = AuthService().getCurrentUid();

  //text controller for bio
  final bioTextController = TextEditingController();

  //loading
  bool _isLoading = true;

  // isfollowing state
  bool _isFollowing = false;

  //on startup
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //let's load user info
    loadUser();
  }

  Future<void> loadUser() async{
    //get the user profile info
    user = await databaseProvider.userProfile(widget.uid);

    //load followers & following for this user
    await databaseProvider.loadUserFollowers(widget.uid);
    await databaseProvider.loadUserFollowing(widget.uid);
    
    //update following state
    _isFollowing = databaseProvider.isFollowing(widget.uid);

    //finished loading..
    setState(() {
      _isLoading = false;
    });
  }
  //show edit bio box
  void _showEditBioBox(){
    showDialog(context: context, builder:(context) =>
        MyInputAlertBox(
            textController: bioTextController,
            hintText: "Edit bio..",
            onPressed: saveBio,
            onPressedText: "Save"
        ));
  }
  //save updated bio

  Future<void> saveBio() async{
    //start loading...
    setState(() {
      _isLoading = true;
    });
    //update bio
    await databaseProvider.updateBio(bioTextController.text);

    //reload user
    await loadUser();

    //done loading
    setState(() {
      _isLoading = false;
    });
  }

  //toggle follow -> follow / unfollow
  Future<void> toggleFollow() async{
    //unfollow
    if(_isFollowing){
      showDialog(context: context, builder:(context) =>AlertDialog(
        title: Text("Unfollow"),
        content: Text("Are you sure you want to unfollow"),
        actions: [
          // cancel
          TextButton(onPressed: ()=>Navigator.pop(context), child: Text("Cancel")),
          
          //yes
          TextButton(onPressed: () async{
            Navigator.pop(context);
            //perform unfollow
            await databaseProvider.unfollowUser(widget.uid);
          }, child: Text("Yes"))
        ],
      ));
    }
    else{
      await databaseProvider.followUser(widget.uid);
    }
    //update isfollowing state
    setState(() {
      _isFollowing =!_isFollowing;
    });
  }

  @override
  Widget build(BuildContext context) {

    //listen get user posts
    final allUserPosts = listeningProvider.filterUserPosts(widget.uid);

    // listen to followers & following count
    final followerCount = listeningProvider.getFollowerCount(widget.uid);
    final followingCount = listeningProvider.getFollowingCount(widget.uid);

    //listen to is following
    _isFollowing = listeningProvider.isFollowing(widget.uid);

    //scaffold
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 68.0),
          child: Text(_isLoading ? '' : user!.name),
        ),
        foregroundColor: Colors.grey.shade200,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: ()=>goHomePage(context),
        ),

        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView(
        children: [
          //username handle
          Center(child: Text(_isLoading ? '':'@' + user!.username,style: TextStyle(color: Theme.of(context).colorScheme.primary),),),

          SizedBox(height: 25,),
          //profile picture
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(25),
              ),
              padding: EdgeInsets.all(25),
              child: Icon(Icons.person,size: 72,color: Theme.of(context).colorScheme.primary,),
            ),
          ),
          SizedBox(height: 25,),

          //profile stats -> no of posts/ followers / following
          MyProfileStats(
              postCount: allUserPosts.length,
              followerCount: followerCount,
              followingCount: followingCount,
              onTap: ()=> Navigator.push(
                  context, MaterialPageRoute(
                builder: (context) => FollowListPage(uid: widget.uid,),)),

          ),

          SizedBox(height: 25,),

          //follow / unfollow button
          //only show if the user is viewing someone else's profile
          if(user!=null && user!.uid !=currentUserId)
            MyFollowButton(
                onPressed: toggleFollow,
                isFollwing: _isFollowing,
            ),

          //edit bio
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Text("Bio",style:TextStyle(color: Theme.of(context).colorScheme.primary),),
                //button
                //only show edit button if it's current user page
                if(user != null && user!.uid == currentUserId)
                GestureDetector(
                    onTap: _showEditBioBox,
                    child: Icon(Icons.settings,color: Theme.of(context).colorScheme.primary)),
              ],
            ),
          ),
          SizedBox(height: 10,),

          //bio box
          MyBioBox(text: _isLoading ? '...' : user!.bio),


          Padding(
            padding: const EdgeInsets.only(left: 25.0 , top: 20),
            child: Text("Posts" ,  style: TextStyle(color: Theme.of(context).colorScheme.primary),),
          ),

          //list of posts from user
          allUserPosts.isEmpty ?
          //user post is empty
          Center(child: Text("No posts yet.."),) :

          //user post is not empty
          ListView.builder(
            itemCount: allUserPosts.length,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
            //get individual post
              final post = allUserPosts[index];

              //post tile ui
              return MyPostTile(
                post: post,
                onUserTap: () {},
                onPostTap: ()=>goPostPage(context, post),
              );
          },)
        ],
      )
    );
  }
}
