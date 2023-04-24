import 'package:chatbot/helper/helper_function.dart';
import 'package:chatbot/pages/auth/login_page.dart';
import 'package:chatbot/pages/home_page.dart';
import 'package:chatbot/services/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  String fullName = "";
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _isLoading ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,)) : SingleChildScrollView(
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
                  const Text("Create your account now to chat and explore", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),),
                  Image.asset("assets/register.png"),

                  TextFormField(
                    decoration: textInputDecoration.copyWith(
                        labelText: "FullName",
                        prefixIcon: Icon(Icons.person,color: Theme.of(context).primaryColor,)
                    ),
                    onChanged: (val){
                      setState(() {
                        fullName = val;
                      });
                    },
                    validator: (val){
                      if(val!.isNotEmpty){
                        return null;
                      }else{
                        return "Name cannot be empty";
                      }
                    },
                  ),

                  const SizedBox(height: 20,),

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
                        child: Text("Register", style: TextStyle(fontSize: 16, color: Colors.white),),
                      ),
                      onPressed: (){
                        register();
                      },
                    ),
                  ),
                  const SizedBox( height: 10,),
                  Text.rich(
                      TextSpan(
                        text: "Already have an account?",
                        style: const TextStyle(color: Colors.black, fontSize: 14),
                        children: <TextSpan>[
                          TextSpan(
                              text: "Login now",
                              style: const TextStyle(color: Colors.black, decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()..onTap = () {
                                nextScreen(context, const LoginPage());
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
  register() async {
    if(formKey.currentState!.validate() ){

      setState(() {
        _isLoading = true;
      });

      await authService.registerUserWithEmailandPassword(fullName, email, password).then((value) async {
        if(value == true) {
          // saving the shared preference state
          await HelperFunction.saveUserLoggedInStatus(true);
          await HelperFunction.saveUserNameSF(fullName);
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