


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitter_clone/models/post.dart';
import 'package:twitter_clone/models/user.dart';
import 'package:twitter_clone/services/auth/auth_service.dart';
import 'package:twitter_clone/models/comment.dart';
class DatabaseService{
  //get instance of firebase db & auth
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /*

  USER PROFILE

  when a new user register , we create an account for them , but let's also store their
  details in the database to display on their profile page.
   */

   //Save user info
   Future<void> saveUserInfoInFirebase({required String name,required String email}) async{
     //get current uid
     String uid = _auth.currentUser!.uid;
     //extract username from email
     String username = email.split('@')[0];

     // create a user profile
     UserProfile user = UserProfile(
         uid: uid,
         name: name,
         email: email,
         username: username,
         bio: '',
     );

     // convert user into a map so that we can store in firebase
     final userMap = user.toMap();
     //save user info in firebase
     await _db.collection("Users").doc(uid).set(userMap);
   }

   // get user info
   Future<UserProfile?> getUserFromFirebase(String uid) async{
     try{
       //retieve user doc from firebase
       DocumentSnapshot userDoc = await _db.collection("Users").doc(uid).get();
       //convert doc to user profile
       return UserProfile.fromDocument(userDoc);
     }
     catch(e){
       print(e);
       return null;
     }
   }

   //Update user bio
   Future<void> updateUserBioInFirebase(String bio) async{
     //get current id
     String uid = AuthService().getCurrentUid();

     //attempt to update in firebase
     try{
       await _db.collection("Users").doc(uid).update({'bio':bio});
     }
     catch(e){
       print(e);
     }
   }

   //Delete user info
  Future<void> deleteUserInfoFromFirebase(String uid) async{
     WriteBatch batch = _db.batch();

     //delete user doc
    DocumentReference userDoc = _db.collection("Users").doc(uid);
    batch.delete(userDoc);

    //delete user post
    QuerySnapshot userPosts = await _db.collection("Posts").where('uid',isEqualTo: uid).get();

    for(var post in userPosts.docs){
      batch.delete(post.reference);
    }

    //delete user comments
     QuerySnapshot userComments = await _db.collection("Comments").where('uid',isEqualTo: uid).get();

     for(var comment in userComments.docs){
       batch.delete(comment.reference);
     }

     //delete like done by this user
     QuerySnapshot allPosts = await _db.collection("Posts").get();
     for(QueryDocumentSnapshot post in allPosts.docs){
       Map<String , dynamic> postData = post.data() as Map<String , dynamic>;
       var likedBy = postData['likedBy'] as List<dynamic>? ??[];

       if(likedBy.contains(uid)){
         batch.update(
             post.reference,
             {
               'likedBy':FieldValue.arrayRemove([uid]),
               'likes':FieldValue.increment(-1),
             }
         );
       }
     }


    //update follower & following records accordingly...(later)

    //commit batch
    await batch.commit();
  }

/*

POST MESSAGE

 */

//Post a message
Future<void> postMessageInFirebase(String message) async{
  try{
    //get current userid
    String uid = _auth.currentUser!.uid;

    //use this uid to get the user's profile
    UserProfile? user = await getUserFromFirebase(uid);

    //create a new post
    Post newPost = Post(
        id: '', //firebase will auto generate this
        uid: uid,
        name: user!.name,
        username: user.username,
        message: message,
        timestamp: Timestamp.now(),
        likeCount: 0,
        likedBy: [],
    );
    //convert post object -> map
    Map<String , dynamic> newPostMap = newPost.toMap();

    // add to firestore
    await _db.collection("Posts").add(newPostMap);
  }
  catch(e){
    print(e);
  }
}

// Delete a post
  Future<void> deletePostFromFibase(String postId) async{
  try{
    await _db.collection("Posts").doc(postId).delete();
  }
  catch(e){
    print(e);
  }
  }

// Get all posts from firebase
Future<List<Post>> getAllPostsFromFirebase() async{
  try{
    QuerySnapshot snapshot = await _db
    //go to collection ->posts
        .collection("Posts")
    //chronological order
        .orderBy('timestamp',descending: true)
    //get this data
        .get();
    //return a list of post
    return snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
  }
  catch(e){
    return[];
  }
}

// Get individual post

/*

LIKES

 */
//Like a post
Future<void> toggleLikedInFirebase(String postId) async{
  try{
    //get current uid
    String uid = _auth.currentUser!.uid;

    //go to doc for this post
    DocumentReference postDoc = _db.collection("Posts").doc(postId);

    // execute like
    await _db.runTransaction((transaction) async{
      //get post data
      DocumentSnapshot postSnapshot = await transaction.get(postDoc);

      // get like of users who like this post
      List<String> likedBy = List<String>.from(postSnapshot['likedBy'] ?? []);

      //get like count
      int currentLikeCount = postSnapshot['likes'];

      //if user has not liked this post yet => then like
      if(!likedBy.contains(uid)){
        //add user to like list
        likedBy.add(uid);
        // increment like count
        currentLikeCount++;
      }

      //if user has already liked this post => then unlike
      else{
        //remove user from like list
        likedBy.remove(uid);
        //decrease the like count
        currentLikeCount--;
      }

      //update
      transaction.update(postDoc, {
        'likes':currentLikeCount,
        'likedBy':likedBy,
      });
    });

  }
  catch(e){
    print(e);
  }
}

/*

COMMENTS

 */
//add a comment from a post
Future<void> addCommentInFirebase(String postId ,message) async{
  try{
    //get current user
    String uid = _auth.currentUser!.uid;
    UserProfile? user = await getUserFromFirebase(uid);

    //create a new comment
    Comment newComment =
    Comment(
        id: '', //auto generated by firebase
        postId: postId,
        uid: uid,
        name: user!.name,
        username: user.username,
        message: message,
        timestamp: Timestamp.now(),
    );

    // convert to comment to map
    Map<String,dynamic> newCommentMap = newComment.toMap();

    // to store in firebase
    await _db.collection("Comments").add(newCommentMap);
  }
  catch(e){
    print(e);
  }
}


// delete a comment from a post
Future<void> deleteCommentInFirebase(String commentId) async{
  try{
    await _db.collection("Comments").doc(commentId).delete();
  }
  catch(e){
    print(e);
  }
}

// fetch comments for a post
Future<List<Comment>> getCommentFromFirebase(String postId) async{
  try{
    //get comments from firebase
    QuerySnapshot snapshot = await _db.collection("Comments").where("postId",isEqualTo: postId).get();

    //return as a list of comments
    return snapshot.docs.map((doc) => Comment.fromDocument(doc)).toList();
  }
  catch(e){
    print(e);
    return [];
  }
}

/*

ACCOUNT STUFF

 */

// Report post
Future<void> reportUserInFirebase(String postId,userId) async{
  //get current user id
  final currentUserId = _auth.currentUser!.uid;

  //create a report map
  final report ={
    'reportedBy':currentUserId,
    'messageId':postId,
    'messageOwnerId':userId,
    'timestamp':FieldValue.serverTimestamp(),
  };

  // update in firestore
  await _db.collection("Reports").add(report);
}


// Block user
Future<void> blockUserInFirebase(String userId) async{
  //get current user id
  final currentUserId = _auth.currentUser!.uid;

  //add this user to blocked list
  await _db
      .collection("Users")
      .doc(currentUserId)
      .collection("BlockedUsers")
      .doc(userId)
      .set({});
}

// Unblock user
Future<void> unblockUserInFirebase(String blockedUserId) async{
  //get current user id
  final currentUserId = _auth.currentUser!.uid;

  //unblock in firebase
  await _db
      .collection("Users")
      .doc(currentUserId)
      .collection("BlockedUsers")
      .doc(blockedUserId)
      .delete();
}

// Get list of blocked user id's
Future<List<String>> getBlockedUidsFromFirebase() async{
  //get current user id
  final currentUserId = _auth.currentUser!.uid;

  //get data of blocked users
  final snapshot = await _db
      .collection("Users")
      .doc(currentUserId)
      .collection("BlockedUsers")
      .get();

  //return as a list of uids
  return snapshot.docs.map((doc) => doc.id).toList();
}


/*

FOLLOW

 */

// Follow user
Future<void> followUserInFirebase(String uid) async{
  //get current logged in user
  final currentUserId = _auth.currentUser!.uid;
  //add target user to the current user's following
  await _db.collection("Users").doc(currentUserId).collection("Following").doc(uid).set({});

  //add current user to the target user's followers
  await _db.collection("Users").doc(uid).collection("Followers").doc(currentUserId).set({});
}


// Unfollow User
Future<void> unFollowUserInFirebase(String uid) async{
  //get current logged in user
  final currentUserId = _auth.currentUser!.uid;

  // remove target user from current user's following
  await _db.collection("Users").doc(currentUserId).collection("Following").doc(uid).delete();

  // remove target user from current user's followers
  await _db.collection("Users").doc(uid).collection("Followers").doc(currentUserId).delete();

  // remove current user from target user's followers
}

// Get a user's followers : list of uids
Future<List<String>> getFollowerUidsFromFirebase(String uid) async{
  //get the followers from firebase
  final snapshot = await _db.collection("Users").doc(uid).collection("Followers").get();

  //return as a nice simple list of uids
  return snapshot.docs.map((doc) => doc.id).toList();
}

// Get a user's following : list of uids
  Future<List<String>> getFollowingUidsFromFirebase(String uid) async{
    //get the following from firebase
    final snapshot = await _db.collection("Users").doc(uid).collection("Following").get();

    //return as a nice simple list of uids
    return snapshot.docs.map((doc) => doc.id).toList();
  }


/*

SEARCH

 */

// Search for users by name
 Future<List<UserProfile>> searchUsersInFirebase(String searchTerm) async{
   try{

     QuerySnapshot snapshot = await _db
         .collection("Users")
         .where('username',isGreaterThanOrEqualTo: searchTerm)
         .where('username',isLessThanOrEqualTo: '$searchTerm\uf8ff')
         .get();
     return snapshot.docs.map((doc) => UserProfile.fromDocument(doc)).toList();

   }
   catch(e){
     return [];
   }
 }





}