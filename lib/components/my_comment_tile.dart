/*
Comment tile
This is the comment tile widget which belongs a post . It's similar to the post
tile widget , but let's make the comments look slightly different to  posts.

............................................................................

To use this view , you need :
- the comment
- a function (for when user taps and wnats to go to the user profile of this comments)

 */




import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/models/comment.dart';
import 'package:twitter_clone/services/database/database_provider.dart';

import '../services/auth/auth_service.dart';

class MyCommentTile extends StatelessWidget {
  final void Function()? onUserTap;
  final Comment comment;
  const MyCommentTile({Key? key , required this.comment, required this.onUserTap}) : super(key: key);



  //show options for post
  void _showOptions(BuildContext context){

    //check if this post is owned by the user or not
    String  currentUid = AuthService().getCurrentUid();
    final bool isOwenComment = comment.uid == currentUid;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              // this comment belongs to user
              if(isOwenComment)

              // delete comment button
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text("Delete"),
                  onTap: () async{
                    // pop option box
                    Navigator.pop(context);

                    //handle delete action
                    await Provider.of<DatabaseProvider>(context,listen: false).deleteComment(comment.id, comment.postId);
                  },
                )
              //Tis post does't belongs to user
              else...{
                //report comment button
                ListTile(
                  leading: Icon(Icons.flag),
                  title: Text("Report"),
                  onTap: (){
                    // pop option box
                    Navigator.pop(context);

                    //handle the report
                  },
                ),

                // block user button
                ListTile(
                  leading: Icon(Icons.block),
                  title: Text("Block User"),
                  onTap: (){
                    // pop option box
                    Navigator.pop(context);
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


  @override
  Widget build(BuildContext context) {
    return Container(

      //padding outside
      margin: EdgeInsets.symmetric(horizontal: 25 ,vertical: 5),
      //padding inside
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        // color of post tile
          color: Theme.of(context).colorScheme.tertiary,
          // curve corners
          borderRadius: BorderRadius.circular(8)
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Top section : profile pic / name / username
          GestureDetector(
            onTap: onUserTap,
            child: Row(
              children: [
                //Profile picture
                Icon(Icons.person ,color: Theme.of(context).colorScheme.primary,),
                SizedBox(height: 10,),
                //name
                Text(comment.name ,style: TextStyle(color: Theme.of(context).colorScheme.primary,fontWeight: FontWeight.bold),),
                SizedBox(height: 5,),
                //username handle
                Text('@${comment.username}',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
                Spacer(),
                //button  -> more optins : delete
                GestureDetector(
                  onTap: ()=> _showOptions(context),
                  child: Icon(Icons.more_horiz , color: Theme.of(context).colorScheme.primary,),
                ),
              ],
            ),
          ),
          SizedBox(height: 20,),

          //Message
          Text(comment.message,style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
        ],
      ),
    );
  }
}
