/*

Follow Button

This is a follow / unfollow button , depending on whose profile page we are
currently viewing.

................................................................................

To use this widget , we need :

- a function ( e.g . toggleFollow() when the button is presend)
- isFollowing (e.g . false -> then we will show follow button instead of unfollow button)

 */
import 'package:flutter/material.dart';

class MyFollowButton extends StatelessWidget {
  final void Function()? onPressed;
  final bool isFollwing;
  const MyFollowButton({Key? key ,required this.onPressed , required this.isFollwing}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(25),

        //curved corners
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: MaterialButton(

            //padding inside
            padding: EdgeInsets.all(25),
            onPressed: onPressed,
            color: isFollwing? Theme.of(context).colorScheme.primary : Colors.redAccent,
            child: Text(isFollwing? "Unfollow" : "Follow",style: TextStyle(color:Theme.of(context).colorScheme.tertiary , fontWeight: FontWeight.bold),),
          
          ),
        ),
    );
  }
}
