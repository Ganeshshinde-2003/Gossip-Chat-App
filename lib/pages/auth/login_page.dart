import 'package:chatbot/pages/auth/register_page.dart';
import 'package:chatbot/services/auth_service.dart';
import 'package:chatbot/services/database_service.dart';
import 'package:chatbot/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../helper/helper_function.dart';
import '../home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  bool _isLoading = false;
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading ? Center( child: CircularProgressIndicator(color: Theme.of(context).primaryColor,) ,) : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 80),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget> [
                const Text("Groupie", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),),
                const SizedBox(height: 10,),
                const Text("Login now to see what they are talking!", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),),
                Image.asset("assets/login.png"),

                TextFormField(
                    decoration: textInputDecoration.copyWith(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email,color: Theme.of(context).primaryColor,)
                    ),
                  onChanged: (val){
                    setState(() {
                      email = val;
                    });
                  },
                  validator: (val){
                    return RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+").hasMatch(val!) ? null : "Please enter a valid email";
                  },
                ),
                const SizedBox(height: 15,),
                TextFormField(
                  obscureText: true,
                  decoration: textInputDecoration.copyWith(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock,color: Theme.of(context).primaryColor,)
                  ),
                  validator: (val){
                    if(val!.length < 6){
                      return "Password must be at least 6 characters";
                    }
                    else{
                      return null;
                    }
                  },
                  onChanged: (val){
                    setState(() {
                      password = val;
                    });
                  },
                ),
                const SizedBox(height: 20,),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)
                      )
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Sign in", style: TextStyle(fontSize: 16, color: Colors.white),),
                    ),
                    onPressed: (){
                      login();
                    },
                  ),
                ),
                const SizedBox( height: 10,),
                Text.rich(
                  TextSpan(
                    text: "Don't have an account?",
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                    children: <TextSpan>[
                      TextSpan(
                        text: "Register here",
                        style: const TextStyle(color: Colors.black, decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()..onTap = () {
                            nextScreen(context, const RegisterPage());
                        }
                      )
                    ],
                  )
                )

              ],
            ),
          ),
        ),
      )
    );
  }

  login() async {
    if(formKey.currentState!.validate() ){

      setState(() {
        _isLoading = true;
      });

      await authService.loggingWithUserNameandPassword(email, password).then((value) async {
        if(value == true) {

          QuerySnapshot snapshot =  await DataBaseService(uid: FirebaseAuth.instance.currentUser!.uid).gettingUserData(email);

          // saving the values to our shared preference

          await HelperFunction.saveUserLoggedInStatus(true);
          await HelperFunction.saveUserNameSF(
            snapshot.docs[0]['fullName']
          );
          await HelperFunction.saveUserEmailSF(email);

          nextScreenReplace(context, const HomePage());
        }
        else{
          setState(() {
            showSnakbar(context, Colors.red, value);
            _isLoading = false;
          });
        }
      });

    }
  }
}