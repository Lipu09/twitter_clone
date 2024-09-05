/*

Profile stats

This will be displayed on the profile page

...........................................

No of :
- posts
- followers
- following


 */

import 'package:flutter/material.dart';

class MyProfileStats extends StatelessWidget {
  final int postCount;
  final int followerCount;
  final int followingCount;
  final void Function()? onTap;
  const MyProfileStats({
    Key? key,
    required this.postCount,
    required this.followerCount,
    required this.followingCount,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    //textstyle for count
    var textStyleForCount = TextStyle(
      fontSize: 20,color: Theme.of(context).colorScheme.inversePrimary,
    );

    //textstyle for text
    var textStyleForText = TextStyle(
      color: Theme.of(context).colorScheme.primary,
    );
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // posts
          SizedBox(
            width: 100,
            child: Column(
              children: [
                Text(postCount.toString(),style: textStyleForCount,),
                Text("Posts",style: textStyleForText,)
              ],
            ),
          ),
          // followers
          SizedBox(
            width: 100,
            child: Column(
              children: [
                Text(followerCount.toString(),style: textStyleForCount,),
                Text("Followers",style: textStyleForText,)
              ],
            ),
          ),

          //following
          SizedBox(
            width: 100,
            child: Column(
              children: [
                Text(followingCount.toString(),style: textStyleForCount,),
                Text("Following",style: textStyleForText,)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
