import 'package:chatbot/pages/home_page.dart';
import 'package:chatbot/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/widgets.dart';
import 'auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  String userName;
  String email;
  ProfilePage({Key? key, required this.userName, required this.email}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthService authService = AuthService();
String url = 'https://github.com/Ganeshshinde-2003';

Future<void> _copyToClipboard() async {
  await Clipboard.setData(ClipboardData(text: url));
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    content: Text('URL copied to clipboard!'),
    duration: Duration(seconds: 2),
  ));
}
//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: const Text("Profile", style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold),),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children:<Widget> [
            Icon(Icons.account_circle, size: 150, color: Colors.grey[700],),
            const SizedBox(height: 15,),
            Text(widget.userName, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold),),
            const SizedBox(height: 30,),
            const Divider(height: 2,),
            ListTile(
              onTap: (){
                nextScreen(context, const HomePage());
              },
              contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              leading: const Icon(Icons.group),
              title: const Text("Groups", style: TextStyle(color: Colors.black),),
            ),
            ListTile(
              onTap: (){},
              selectedColor: Theme.of(context).primaryColor,
              selected: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              leading: const Icon(Icons.person_pin),
              title: const Text("Profile", style: TextStyle(color: Colors.black),),
            ),
            ListTile(
              onTap: () async {
                showDialog(barrierDismissible: false, context: context, builder: (context){
                  return AlertDialog(
                    title: const Text("Logout"),
                    content: const Text("Are you sure you wanna logout☹️"),
                    actions: [
                      IconButton(onPressed: (){
                        Navigator.pop(context);
                      },
                        icon: const Icon(Icons.cancel, color: Colors.red,),
                      ),
                      IconButton(onPressed: () async {
                        await authService.signOut();
                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
                      },
                        icon: const Icon(Icons.exit_to_app, color: Colors.green,),
                      ),
                    ],
                  );
                });
              },

              contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              leading: const Icon(Icons.exit_to_app),
              title: const Text("Logout", style: TextStyle(color: Colors.black),),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 170),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.account_circle, size: 150, color: Colors.grey[700],),
              const SizedBox(height: 15,),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text("Full Name:", style: TextStyle(fontSize: 17),),
                    const SizedBox(width: 10,),
                    Text(widget.userName, style: const TextStyle(fontSize: 17),),
                  ],
                ),
              ),
              const Divider(height: 20,),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text("Email:", style: TextStyle(fontSize: 17),),
                    const SizedBox(width: 10,),
                    Text(widget.email, style: const TextStyle(fontSize: 17),),
                  ],
                ),
              ),
              const SizedBox(height: 200,),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Padding(
                  padding: EdgeInsets.only(left: 40.0, right: 40.0, top: 10.0, bottom: 10.0),
                  child: Text('Know About The Developer'),
                ),
                onPressed: () async {
                  const url = 'https://github.com/Ganeshshinde-2003';
                  await Clipboard.setData(const ClipboardData(text: url));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'You just copied the GitHub profile of the developer. Paste it and know more about ME❤️😊',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.black,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      duration: const Duration(seconds: 3),
                      action: SnackBarAction(
                        label: 'Undo',
                        textColor: Theme.of(context).primaryColor,
                        onPressed: () {
                          Clipboard.setData(const ClipboardData(text: ''));
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
