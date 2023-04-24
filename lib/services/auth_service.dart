import 'package:chatbot/helper/helper_function.dart';
import 'package:chatbot/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  // login
  Future loggingWithUserNameandPassword(String email, String password) async {
    try{
      User user =  (await firebaseAuth.signInWithEmailAndPassword(email: email, password: password)).user!;
      if(user != null){
        return true;
      }
    } on FirebaseAuthException catch(e) {
      return e.message;
    }
  }
  // reigter
  Future registerUserWithEmailandPassword(String fullName, String email, String password) async {
    try{
      User user =  (await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password)).user!;
      if(user != null){
        //call data base to update the date
        await DataBaseService(uid: user.uid).savingUserdata(fullName, email);
        return true;
      }
    } on FirebaseAuthException catch(e) {
      return e.message;
    }
  }
  // signout
  Future signOut() async {
    try{
      await HelperFunction.saveUserLoggedInStatus(false);
      await HelperFunction.saveUserEmailSF("");
      await HelperFunction.saveUserNameSF("");
      await firebaseAuth.signOut();
    }catch(e){
      return null;
    }
  }
}