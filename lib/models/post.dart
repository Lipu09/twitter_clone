

import 'package:cloud_firestore/cloud_firestore.dart';

class Post{
  final String id;
  final String uid;
  final String name;
  final String username;
  final String message;
  final Timestamp timestamp;
  final int likeCount;
  final List<String> likedBy;


  Post({
   required this.id,
   required this.uid,
   required this.name,
   required this.username,
   required this.message,
   required this.timestamp,
   required this.likeCount,
   required this.likedBy,
});

  //Convert a firestore doc to a post object (to use in our app)
  factory Post.fromDocument(DocumentSnapshot doc){
    return Post(
        id: doc.id,
        uid: doc['uid'],
        name: doc['name'],
        username: doc['username'],
        message: doc['message'],
        timestamp: doc['timestamp'],
        likeCount: doc['likes'],
        likedBy: List<String>.from(doc['likedBy'] ?? []),
    );
  }


  // Convert a post object to map (to store in firebase)

 Map<String , dynamic> toMap(){
    return{
      'uid':uid,
      'name':name,
      'username':username,
      'message':message,
      'timestamp':timestamp,
      'likes':likeCount,
      'likedBy':likedBy,
    };
 }
}