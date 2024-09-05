/*
DATABASE PROVIDER
   This provider is to separate the firestore data handling and UI of our app.

   - The database service class handles data to and from firebase
   - The database provider class processes the data to display in our app.
   - This is to make our code much more modular , cleaner , and easier to read and text.
     Perticularly as the no of pages grow , we need this provider to properly manage the
     different states of the app.

   - Also , if one day , we decide to change our backend(form firebase to something else)
     then it's much easier to manage and switch out different database.

 */


import 'dart:core';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitter_clone/models/comment.dart';

import 'package:flutter/cupertino.dart';
import 'package:twitter_clone/services/auth/auth_service.dart';
import 'package:twitter_clone/services/database/database_service.dart';

import '../../models/post.dart';
import '../../models/user.dart';

class DatabaseProvider extends ChangeNotifier{
  /*

  SERVICES

   */

  // get db & auth service
  //final _auth =AuthService();
  final _db = DatabaseService();
  final _auth = AuthService();
  /*

  USER PROFILE

   */

   // get user profile given uid
   Future<UserProfile?> userProfile(String uid) =>_db.getUserFromFirebase(uid);

   //update user bio

   Future<void> updateBio(String bio) => _db.updateUserBioInFirebase(bio);

   /*
   Posts
    */
   //local list of posts
   List<Post> _allPosts=[];
   List<Post> _followingPosts=[];

   //get posts
   List<Post> get allPosts =>_allPosts;
   List<Post> get followingPosts =>_followingPosts;

   //post message
   Future<void> postMessage(String message) async{
     //post message in firebase
     await _db.postMessageInFirebase(message);

     //reload data from firbase
     await loadAllPosts();
   }
   //fetch all message
   Future<void> loadAllPosts() async{
     //get all posts form firebase
     final allPosts = await _db.getAllPostsFromFirebase();

     // get blocked user ids
     final blockedUserIds = await _db.getBlockedUidsFromFirebase();

     // filter out blocked user posts & update locally
     _allPosts = allPosts.where((post) => !blockedUserIds.contains(post.uid)).toList();

     // filter out the following posts
     loadFollowingPosts();


     //initialize local like data
     initializeLikeMap();

     //update UI
     notifyListeners();
   }


   //filter and return posts given uid
   List<Post> filterUserPosts(String uid){
     return _allPosts.where((post) => post.uid == uid).toList();
   }

   //load following posts -> posts from users that the current users follows
  Future<void> loadFollowingPosts() async{
     //get current uid
     String currentUid = _auth.getCurrentUid();

     // get list of uids taht the current logged in user follows (form firebase)
     final followingUserIds = await _db.getFollowingUidsFromFirebase(currentUid);

     //filter all posts to be the ones fo the following tabs
     _followingPosts = _allPosts.where((post) => followingUserIds.contains(post.uid)).toList();

     // update ui
     notifyListeners();
  }


   //delete the post
   Future<void> deletePost(String postId) async{
     //delete from firebase
     await _db.deletePostFromFibase(postId);

     //reload data from firebase
     await loadAllPosts();
   }

   /*
   Likes
    */

//Local map to track the like count for each post
Map<String , int> _likeCount = {
  //for each post id : like count
};
  //local list to track posts liked by current user
  List<String> _likedPosts=[];
  //does the current user like this post
  bool isPostLikedByCurrentUser(String postId) => _likedPosts.contains(postId);
  //get the like count of a post
  int getLikeCount(String postId) =>_likeCount[postId] ?? 0;

  //initalize like map locality
  void initializeLikeMap(){
    //get current uid
    final currentUserId = _auth.getCurrentUid();

    //clear liked post (for when new user sign in , clear local data)
    _likedPosts.clear();
    //for each post get like data
    for(var post in _allPosts){
      //update like count map
      _likeCount[post.id] = post.likeCount;

      //if the current user already likes this post
      if(post.likedBy.contains(currentUserId)){
        //add thid post id to local list of liked posts
        _likedPosts.add(post.id);
      }
    }
  }

  //toggle like
  Future<void> toggleLike(String postId) async{
    /*
    This first part will update the local values first so that the UI feels
    immediate and responsive. we will update the UI optimistically . and revert
    back if anything goes wrong while writing to the database

    optimistically updating the local values like this is important because:
    reading and writing from the database takes some time (1-2 seconds,depending on
    the internet connection ), so we don't want to give the user a slow lagged experience.
     */

    //store original values in case it fails
    final likedPostsOriginal = _likedPosts;
    final likedCountOrigianal = _likeCount;

    //perform like  / unlike
    if(_likedPosts.contains(postId)){
      _likedPosts.remove(postId);
      _likeCount[postId] = (_likeCount[postId] ?? 0)-1;
    }
    else{
      _likedPosts.add(postId);
      _likeCount[postId]=(_likeCount[postId] ?? 0)+1;
    }

    //update UI locally
    notifyListeners();

    /*
    Now let's try to update the database
     */

    //attempt to like in database
    try{
      await _db.toggleLikedInFirebase(postId);
    }
    //revert back to initial state if update fails
    catch(e){
      _likedPosts = likedPostsOriginal;
      _likeCount = likedCountOrigianal;

      //update UI again
      notifyListeners();
    }
  }

  /*
  Comments
  {

  postId ;| comment1, comment2,....|,

  }
   */
//local list of comments
final Map<String , List<Comment>>  _comments = {};

//get comments locally
List<Comment> getComments(String postId) => _comments[postId] ?? [];

//fetch comments from databasefor a post
Future<void> loadComments(String postId) async{
  //get all comments for this post
  final allComments =await _db.getCommentFromFirebase(postId);

  //update local data
  _comments[postId] =allComments;

  //update ui
  notifyListeners();

}
//add a comment
Future<void> addComment(String postId,message) async{
  //add comment in firebase
  await _db.addCommentInFirebase(postId, message);
  //reload comments
  await loadComments(postId);
}

//delete a comment
Future<void> deleteComment(String commentId,postId) async{
  //delete comment in firebase
  await _db.deleteCommentInFirebase(commentId);

  //reload comments
  await loadComments(postId);
}

/*
 ACCOUNT STUFF
 */
// local list of blocked users
List<UserProfile> _blockedUsers =[];

//get list of blocked users
List<UserProfile> get blockedUsers =>_blockedUsers;

//fetch blocked users

Future<void> loadBlockedUsers() async{
  //get list of blocked user ids
  final blockedUserIds = await _db.getBlockedUidsFromFirebase();

  // get full user details using uid
  final blockedUserData  = await Future.wait(blockedUserIds.map((id) => _db.getUserFromFirebase(id)));

  // return as a list

  _blockedUsers = blockedUserData.whereType<UserProfile>().toList();

  //update ui
  notifyListeners();
}

//block user
Future<void> blockUser(String userId) async{
  //perform block in firebase
  await _db.blockUserInFirebase(userId);

  //reload the blocked user
  await loadBlockedUsers();

  //reload data
  await loadAllPosts();

  //update ui
  notifyListeners();
}

//unblock user

Future<void> unblockUser(String blockedUserId) async{
  //perform unblock in firebase
  await _db.unblockUserInFirebase(blockedUserId);

  // reload blocked users
  await loadBlockedUsers();

  //reload post
  await loadAllPosts();

  // update ui
  notifyListeners();
}

//report user & post

Future<void> reportUser(String postId,userId) async{
  await _db.reportUserInFirebase(postId, userId);
}

/*
  Follow
  Everything here is done with uids (String)
  ............................................
  
  Each user id has a list of :
  - followers uid
  - following uid
  
  E.g
  {
  'uid1':[list of uids there are followers / following ],
  }
 */

//local map
final Map<String , List<String>> _followers ={};
final Map<String , List<String>> _following ={};
final Map<String , int> _followerCount = {};
final Map<String , int> _followingCount ={};

// get counts for followers & following locally : given a uid
int getFollowerCount(String uid) => _followerCount[uid] ?? 0;
int getFollowingCount(String uid) => _followingCount[uid] ?? 0;

//load followers
Future<void> loadUserFollowers(String uid) async{
  //get the list of followers uids from firebase
  final listOfFollowerUids = await _db.getFollowerUidsFromFirebase(uid);
  
  //update local data
  _followers[uid] = listOfFollowerUids;
  _followerCount[uid] = listOfFollowerUids.length;
  
  //update ui
  notifyListeners();
}

//load following
Future<void> loadUserFollowing(String uid) async{
    //get the list of following uids from firebase
    final listOfFollowingUids = await _db.getFollowingUidsFromFirebase(uid);

    //update local data
    _following[uid] = listOfFollowingUids;
    _followingCount[uid] = listOfFollowingUids.length;

    //update ui
    notifyListeners();
  }

//follow user
Future<void> followUser(String targetUserId) async{
  /*
  currently logged in user wants to follow target user
   */
  
  // get current uid
  final currentUserId = _auth.getCurrentUid();
  
  // initialize with empty lists if null
  _following.putIfAbsent(currentUserId, () => []);
  _followers.putIfAbsent(targetUserId, () => []);
  
  /*
  Optimistic ui changes :  Update the local data & revert back if databse request fails
   */
  
  // follow if current user is not one of the target user's followers
  if(!_followers[targetUserId]!.contains(currentUserId)){
    //add current user to target user's follower list
    _followers[targetUserId]?.add(currentUserId);

    //update follower count
    _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0)+1;

    // then add target user to current user following
    _following[currentUserId]?.add(targetUserId);

    //update following count
    _followingCount[currentUserId] =(_followingCount[currentUserId] ?? 0)+1;
  }
  
  //update ui
  notifyListeners();
  
  /*
  Ui have been optimisttcally update above with local data.
  Now , let's try to make this request to our database.
   */
  try{
    //follow user in firebase
    await _db.followUserInFirebase(targetUserId);

    //reload current user's followers
    await loadUserFollowers(currentUserId);

    //reload current user's following
    await loadUserFollowing(currentUserId);
  }
  catch(e){
    //remove current user from target user's followers
    _followers[targetUserId]?.remove(currentUserId);

    //update follower count
    _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0)-1;

    //remove from current user's following
    _following[currentUserId]?.remove(targetUserId);

    //update following count
    _followingCount[currentUserId] = (_followingCount[currentUserId] ?? 0)-1;

    //update ui
    notifyListeners();
  }
}

//unfollow user
Future<void> unfollowUser(String targetUserId) async{
  /*
  Currently logged un user wants to unfollow target user
   */

  //get current uid
  final currentUserId = _auth.getCurrentUid();

  //initialize lists if they don't exist
  _following.putIfAbsent(currentUserId, () => []);
  _followers.putIfAbsent(targetUserId, () => []);

  /*
  Optimistic Ui changes: Update the local data first & revert back if the database request fails.
   */

  //unfollow if current user is one of the target user's following
  if(_followers[targetUserId]!.contains(currentUserId)){
    //remove current user from target user's following
    _followers[targetUserId]?.remove(currentUserId);

    //update follower count
    _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 1)-1;

    //remove target user from current user's following list
    _following[currentUserId]?.remove(targetUserId);

    //update following count
    _followingCount[targetUserId] =(_followingCount[currentUserId] ?? 1) -1;
  }

  // update UI
  notifyListeners();

  /*
  UI has been optimistically update with local data above.
  Now let's try to make this request to our databse.
   */
  try{
    // unfollow target user in firebase
    await _db.unFollowUserInFirebase(targetUserId);

    //reload user followers
    await loadUserFollowers(currentUserId);

    // reload user following
    await loadUserFollowing(currentUserId);
  }
  // if there is an error.. revert back to original
  catch(e){
    // add current user back into target user's followers
    _followers[targetUserId]?.add(currentUserId);

    //update followers count
    _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0 )+1;

    //add target user back into current user's following list
    _following[currentUserId]?.add(targetUserId);

    //update following count
    _followingCount[currentUserId] = (_followingCount[currentUserId] ?? 0 )+1;

    //update UI
    notifyListeners();
  }
}

//is current user following target user?
bool isFollowing(String uid){
  final currentUserId =_auth.getCurrentUid();
  return _followers[uid]?.contains(currentUserId) ?? false;
}

/*
Map of profiles

for a given uid
  - list of follower profiles
  - list of following profiles
 */
  final Map<String , List<UserProfile>> _followersProfile = {};
  final Map<String , List<UserProfile>> _followingProfile = {};

//get list of follower profiles fo a given user
List<UserProfile> getListOfFollowersProfile(String uid) => _followersProfile[uid] ?? [];

//get list of following profiles for a given user
List<UserProfile> getListOfFollowingProfile(String uid) => _followingProfile[uid] ?? [];

//load follower profiles for a given uid
Future<void> loadUserFollowerProfiles(String uid) async{
  try{
    // get list of follower uids from firebase
    final followerIds = await _db.getFollowerUidsFromFirebase(uid);

    // create list of user profiles
    List<UserProfile> followerProfiles =[];

    //go trough each follower id
    for(String followerId in followerIds){
      //get user profile from firebase with this uid
      UserProfile? followerProfile = await _db.getUserFromFirebase(followerId);

      //add to follower profile
      if(followerProfile!=null){
        followerProfiles.add(followerProfile);
      }
    }

    // update local data
    _followersProfile[uid] = followerProfiles;

    //update ui
    notifyListeners();
  }
  catch(e){
    print(e);
  }
}

//load following profiles for a given uid
Future<void> loadUserFollowingProfiles(String uid) async{
    try{
      // get list of following uids from firebase
      final followingIds = await _db.getFollowingUidsFromFirebase(uid);

      // create list of user profiles
      List<UserProfile> followingProfiles =[];

      //go trough each following id
      for(String followingId in followingIds){
        //get user profile from firebase with this uid
        UserProfile? followingProfile = await _db.getUserFromFirebase(followingId);

        //add to following profile
        if(followingProfile!=null){
          followingProfiles.add(followingProfile);
        }
      }

      // update local data
      _followingProfile[uid] = followingProfiles;

      //update ui
      notifyListeners();
    }
    catch(e){
      print(e);
    }
  }


/*

Search users

 */

//List of search results
List<UserProfile> _searchResults = [];

// get list of search results
List<UserProfile> get searchResult =>_searchResults;

//method to search for a user
Future<void> searchUsers(String searchTerm) async{
  try{

    //serach users in firebase
    final results = await _db.searchUsersInFirebase(searchTerm);

    //update local data
    _searchResults = results;

    //update ui
    notifyListeners();
  }
  catch(e){
    print(e);
  }
}

}