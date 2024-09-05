import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/components/my_input_alert_box.dart';
import 'package:twitter_clone/helper/time_formatter.dart';
import 'package:twitter_clone/services/auth/auth_service.dart';
import 'package:twitter_clone/services/database/database_provider.dart';

import '../models/post.dart';

/*
POST TILE

All post will be displayed using this post tile widget.
 */

class MyPostTile extends StatefulWidget {
  final Post post;
  final void Function()? onUserTap;
  final void Function()? onPostTap;
  const MyPostTile({Key? key, required this.post , required this.onUserTap,required this.onPostTap}) : super(key: key);

  @override
  State<MyPostTile> createState() => _MyPostTileState();
}

class _MyPostTileState extends State<MyPostTile> {

  //providers
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider = Provider.of<DatabaseProvider>(context,listen: false);

  //on startup.
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //load comments for this post
    _loadComments();
  }

  /*
  Likes
   */

  //user tapped like (or unlike)
  void _toggleLikePost() async{
    try{
      await databaseProvider.toggleLike(widget.post.id);
    }
    catch(e){
      print(e);
    }
  }


  /*
  Comments
   */

  //comment text controller
  final _commentController = TextEditingController();

  //open comment box -> user wants to type new comment
  void _openNewCommentBox(){
    showDialog(context: context, builder: (context) =>
        MyInputAlertBox(
            textController: _commentController,
            hintText: "Type a commnet..",
            onPressed:  () async {
              //add post in db
              await _addComment();

            },
            onPressedText: "Post",
        ),);
  }
  //user tapped post to add comment
  Future<void> _addComment() async{
    //does nothing if theres nothing in the textfield
    if(_commentController.text.trim().isEmpty) return;

    //attempt to post comment
    try{
      await databaseProvider.addComment(widget.post.id, _commentController.text.trim());
    }
    catch(e){
      print(e);
    }
  }

  //load comments
  Future<void> _loadComments() async{
    await databaseProvider.loadComments(widget.post.id);
  }
  /*
  Show options
  case 1 - post belongs to the current user
  - delete
  - cancel

  case 2 - post does't belongs to the current user
  - report
  - block
  - cancel
   */


 //show options for post
  void _showOptions(){

    //check if this post is owned by the user or not
    String  currentUid = AuthService().getCurrentUid();
    final bool isOwenPost = widget.post.uid == currentUid;

    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Wrap(
              children: [
                // this post belongs to user
                if(isOwenPost)

                // delete message button
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text("Delete"),
                  onTap: () async{
                    // pop option box
                    Navigator.pop(context);

                    //handle delete action
                    await databaseProvider.deletePost(widget.post.id);
                  },
                )
                  //Tis post does't belongs to user
                else...{
                  //report post button
                  ListTile(
                    leading: Icon(Icons.flag),
                    title: Text("Report"),
                    onTap: (){
                      // pop option box
                      Navigator.pop(context);

                      //handle the report
                      _reportPostConfirmationBox();
                    },
                  ),

                  // block user button
                  ListTile(
                    leading: Icon(Icons.block),
                    title: Text("Block User"),
                    onTap: (){
                      // pop option box
                      Navigator.pop(context);

                      //handel block action
                      _blockUserConfirmationBox();
                    },
                  ),
          },
                // canacel button
                ListTile(
                  leading: Icon(Icons.cancel),
                  title: Text("Cancel"),
                  onTap: (){
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          );
        },
    );
}

//report post confirmation
  void _reportPostConfirmationBox(){
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text("Report Message"),
      content: Text("Are you sure you want to report this message"),
      actions: [
        //cancel button
        TextButton(onPressed: ()=>Navigator.pop(context), child: Text("Cancel")),

        //report button
        TextButton(
            onPressed: () async{

              //report user
              await databaseProvider.reportUser(widget.post.id, widget.post.uid);

              //close the box
              Navigator.pop(context);

              // let user know it was successfully reported
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Message reported!")));
            },
            child: Text("Report"))
      ],
    ),);
  }

  //block user confirmation
  void _blockUserConfirmationBox(){
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text("Block User"),
      content: Text("Are you sure you want to block this user?"),
      actions: [
        //cancel button
        TextButton(onPressed: ()=>Navigator.pop(context), child: Text("Cancel")),

        //block button
        TextButton(
            onPressed: () async{

              //block user
              await databaseProvider.blockUser( widget.post.uid);

              //close the box
              Navigator.pop(context);

              // let user know it was successfully block
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User blocked")));
            },
            child: Text("Block"))
      ],
    ),);
  }


  @override
  Widget build(BuildContext context) {
    //does the current user like the post
    bool likedByCurrentUser = listeningProvider.isPostLikedByCurrentUser(widget.post.id);

    //listen to like count
    int likeCount = listeningProvider.getLikeCount(widget.post.id);

    //listen to comment count
    int commentCount = listeningProvider.getComments(widget.post.id).length;

    return GestureDetector(
      onTap: widget.onPostTap,
      child: Container(

        //padding outside
        margin: EdgeInsets.symmetric(horizontal: 25 ,vertical: 5),
        //padding inside
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          // color of post tile
          color: Theme.of(context).colorScheme.secondary,
          // curve corners
          borderRadius: BorderRadius.circular(8)
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Top section : profile pic / name / username
            GestureDetector(
              onTap: widget.onUserTap,
              child: Row(
                children: [
                  //Profile picture
                  Icon(Icons.person ,color: Theme.of(context).colorScheme.primary,),
                  SizedBox(height: 10,),
                  //name
                  Text(widget.post.name ,style: TextStyle(color: Theme.of(context).colorScheme.primary,fontWeight: FontWeight.bold),),
                  SizedBox(height: 5,),
                  //username handle
                  Text('@${widget.post.username}',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
                  Spacer(),
                  //button  -> more optins : delete
                  GestureDetector(
                    onTap: _showOptions,
                      child: Icon(Icons.more_horiz , color: Theme.of(context).colorScheme.primary,),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20,),

            //Message
            Text(widget.post.message,style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
            SizedBox(height: 20,),
            //button ->like  , comments
            Row(
              children: [
                //like section
                SizedBox(
                  width: 60,
                  child: Row(
                    children: [
                      //like button
                      GestureDetector(
                        onTap: _toggleLikePost,
                        child: likedByCurrentUser ? Icon(Icons.favorite , color: Colors.red,) : Icon(Icons.favorite_border , color: Theme.of(context).colorScheme.primary,)  ,
                      ),
                      SizedBox(width: 5,),

                      //like count
                      Text(likeCount!=0 ?likeCount.toString() : '' , style: TextStyle(color: Theme.of(context).colorScheme.primary),),
                    ],
                  ),
                ),

                //comment sections
                Row(
                  children: [
                    // comment button
                    GestureDetector(
                      onTap: _openNewCommentBox,
                      child: Icon(Icons.comment , color: Theme.of(context).colorScheme.primary,),
                    ),
                    SizedBox(width: 5,),
                    //comment count
                    Text( commentCount!=0 ? commentCount.toString() : '', style: TextStyle(color: Theme.of(context).colorScheme.primary))
                  ],
                ),
                
                //timstamp
                Spacer(),
                Text(formatTimeStamp(widget.post.timestamp), style: TextStyle(color: Theme.of(context).colorScheme.primary),)
              ],
            )
          ],
        ),
      ),
    );
  }
}
