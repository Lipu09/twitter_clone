import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:twitter_clone/components/my_button.dart';
import 'package:twitter_clone/components/my_loading_circle.dart';
import 'package:twitter_clone/components/my_text_field.dart';
import 'package:twitter_clone/services/auth/auth_service.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({Key? key , required this.onTap}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  //auth service
  final _auth = AuthService();

  //text controller
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwController = TextEditingController();


  //login method
  void login() async{
    //show loading circle
    showLoadingCircle(context);
    try{
      //trying to login..
      await _auth.loginEmailPassword(emailController.text, pwController.text);

      //finished loading..
      if(mounted) hideLoadingCircle(context);
    }
    //catch any errors..
    catch(e){
      //finished loading..
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
              
                  //welcome back message
                  Text("Welcome back , you've been missed!",style: TextStyle(color: Theme.of(context).colorScheme.primary,fontSize: 16),),
                  SizedBox(height: 50,),
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
                  SizedBox(height: 25,),
                  //forgot password ?
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text("Forgot password?" , style: TextStyle(color: Theme.of(context).colorScheme.primary,fontWeight: FontWeight.bold),),
                  ),
                  SizedBox(height: 10,),
              
                  //sign in button
                  MyButton(
                      text: "Login",
                      onTap: login,
                  ),
                  SizedBox(height: 30,),
              
                  // not a member? register now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Not a member?",style: TextStyle(color: Theme.of(context).colorScheme.primary), ),

                      SizedBox(width: 5,),
                      GestureDetector(
                        onTap: widget.onTap,
                          child: Text("Register now",style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),))
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
