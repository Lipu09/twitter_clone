import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:twitter_clone/components/my_loading_circle.dart';
import 'package:twitter_clone/services/auth/auth_service.dart';
import 'package:twitter_clone/services/database/database_service.dart';

import '../components/my_button.dart';
import '../components/my_text_field.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({Key? key,required this.onTap}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //access auth & db service
  final _auth = AuthService();
  final _db = DatabaseService();

  //text controller
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  final TextEditingController confirmpwController = TextEditingController();

  //register button tapped
  void register() async{
    //passwords match -> create user
    if(pwController.text == confirmpwController.text){
      //show loading circle
      showLoadingCircle(context);
      //attempt to register new user
      try{
        //trying to register
        await _auth.registerEmailPassword(emailController.text, pwController.text);
        //finished loading
        if(mounted) hideLoadingCircle(context);

        //once registered  , create and save user profile in database,
        await _db.saveUserInfoInFirebase(name: nameController.text, email: emailController.text);

      }
      catch(e){
        //finished loading
        if(mounted) hideLoadingCircle(context);

        //let user know the error
        if(mounted){
          showDialog(
            context: context,
            builder: (context) =>
                AlertDialog(title: Text(e.toString())
              ,),);
        }
      }
    }
    //passwords don't match -> show error
    else{
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text("Password does't match!")
              ,),);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 50,),
                    //logo
                    Icon(
                      FontAwesomeIcons.twitter,
                      size: 70,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    // Icon(Icons.message,size: 72,color: Theme.of(context).colorScheme.primary,),
                    SizedBox(height: 50,),

                    //create an account
                    Text("Let's create an account for you",style: TextStyle(color: Theme.of(context).colorScheme.primary,fontSize: 16),),
                    SizedBox(height: 50,),
                    //name textfield
                    MyTextField(
                      controller: nameController,
                      hintText: "Enter name ..",
                      obsecureText: false,
                    ),
                    SizedBox(height: 10,),
                    // email textfield
                    MyTextField(
                      controller: emailController,
                      hintText: "Enter email ..",
                      obsecureText: false,
                    ),
                    SizedBox(height: 10,),
                    //password textfield
                    MyTextField(
                      controller: pwController,
                      hintText: "Enter password ..",
                      obsecureText: true,
                    ),
                    SizedBox(height: 10,),
                    //confirm password textfield
                    MyTextField(
                      controller: confirmpwController,
                      hintText: "Confirm password ..",
                      obsecureText: true,
                    ),
                    SizedBox(height: 25,),

                    //sign up button
                    MyButton(
                      text: "Register",
                      onTap: register,
                    ),
                    SizedBox(height: 30,),

                    // already a member ? login now
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already a member?",style: TextStyle(color: Theme.of(context).colorScheme.primary), ),

                        SizedBox(width: 5,),
                        GestureDetector(
                            onTap: widget.onTap,
                            child: Text("Login now",style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),))
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
    );
  }
}
