import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/components/my_drawer.dart';
import 'package:twitter_clone/components/my_input_alert_box.dart';
import 'package:twitter_clone/components/my_post_tile.dart';
import 'package:twitter_clone/helper/navigate_pages.dart';
import 'package:twitter_clone/services/database/database_provider.dart';

import '../models/post.dart';
/*

We can organise this page using a tab bar to split into:
  - for you page
  - following page

 */

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {


    //providers
    late final listeningProvider = Provider.of<DatabaseProvider>(context);
    late final databaseProvider = Provider.of<DatabaseProvider>(context,listen: false);

    //user wants to post message
    Future<void> postMessage(String message) async{
      await databaseProvider.postMessage(message);
    }
    //text controller
    final _messageController = TextEditingController();

    //load all post
    Future<void> loadAllPost() async{
      await databaseProvider.loadAllPosts();
    }

    //on stratup,
    @override
    void initState() {
      super.initState();
      // Perform any initialization here
      //let's load all the post
      loadAllPost();
    }


    //show psot message dialog box
    void _openPostMessageBox(){
      showDialog(
          context: context,
          builder: (context) => MyInputAlertBox(
              textController: _messageController,
              hintText: "What's on your mind",
              onPressed: () async{
                //post in db
                await postMessage(_messageController.text);
              },
              onPressedText: "Post",
          )
      );
    }


    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        drawer: MyDrawer(),
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(left: 95.0),
            child: Text("H O M E"),
          ),
          foregroundColor: Theme.of(context).colorScheme.primary,
          bottom: TabBar(
            dividerColor: Colors.transparent,
            labelColor:Theme.of(context).colorScheme.inversePrimary ,
            unselectedLabelColor: Theme.of(context).colorScheme.primary,
            indicatorColor: Theme.of(context).colorScheme.secondary,

            //tabs
            tabs: [
              Tab(text: "For you",),
              Tab(text: "Following",),
            ],
          ),
        ),
        //floating action button
        floatingActionButton: FloatingActionButton(
          onPressed: _openPostMessageBox,
          child: Icon(Icons.add),
        ),
        //Body : lsit of all post

        body: TabBarView(
          children: [
            _buildPostList(listeningProvider.allPosts),
            _buildPostList(listeningProvider.followingPosts),
          ],
        )
      ),
    );
  }
  // build list UI given a list of posts
Widget _buildPostList(List<Post> posts){
    return posts.isEmpty ?
    // post list is empty
    Center(child: Text("Nothing here.."),) :
    // Post list is not empty
    ListView.builder(itemCount:posts.length,itemBuilder:(context, index) {
      //get each individual post
      final post = posts[index];

      //retrun post file ui
      return MyPostTile(
        post: post,
        onUserTap: ()=> goUserPage(context, post.uid),
        onPostTap:()=> goPostPage(context,post) ,
      );
    }, );
}
}

