import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/components/my_comment_tile.dart';
import 'package:twitter_clone/components/my_post_tile.dart';
import 'package:twitter_clone/helper/navigate_pages.dart';
import 'package:twitter_clone/services/database/database_provider.dart';

import '../models/post.dart';

/*
POST PAGE
 This post page display :
 -individual post
 -comments on this post

 */

class PostPage extends StatefulWidget {
  final Post post;
  const PostPage({Key? key , required this.post}) : super(key: key);

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {

  //providers
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider = Provider.of<DatabaseProvider>(context,listen: false);

  @override
  Widget build(BuildContext context) {

    //listen to all comments for this post
    final allComments = listeningProvider.getComments(widget.post.id);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView(
        children: [
          //post
          MyPostTile(
              post: widget.post,
              onUserTap: ()=>goUserPage(context, widget.post.uid),
              onPostTap: (){}
          ),
          //comments on this post
          allComments.isEmpty ?
              //no comments yet..
              Center(child: Text("No comments yet..."),)
              :
              //comments exit
              ListView.builder(
                itemCount: allComments.length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                //get each comment
                final comment = allComments[index];
                //return as comment tile ui
                return MyCommentTile(comment: comment, onUserTap: ()=> goUserPage(context,comment.uid));
              },)
        ],
      ),
    );
  }
}
