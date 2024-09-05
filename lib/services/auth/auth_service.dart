import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitter_clone/services/database/database_service.dart';
class AuthService{
  //get instance of the auth
  final _auth = FirebaseAuth.instance;

  //get current user & uid
  User? getCurrentUser() => _auth.currentUser;
  String getCurrentUid() =>_auth.currentUser!.uid;

  //login => email & pw
  Future<UserCredential> loginEmailPassword(String email,password) async{
    // attempt login
    try{
      final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);

      return userCredential;
    }
    //catch any errors..
    on FirebaseException catch(e){
      throw Exception(e.code);
    }
  }

  // register => email & pw
  Future<UserCredential> registerEmailPassword(String email, password) async{
    // attempt to register new user
    try{
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return userCredential;
    }
    //catch any errors
    on FirebaseAuthException catch(e){
      throw Exception(e.code);
    }
  }

  //log out
  Future<void> logout() async{
    await _auth.signOut();
  }

  //delete account
  Future<void> deleteAccount() async{
    //get current uid
    User? user = getCurrentUser();

    if(user !=null){
      //delete user's data from firestore
      await DatabaseService().deleteUserInfoFromFirebase(user.uid);
      //delete the user's auth record
      await user.delete();
    }
  }


}