import 'package:chatbot/pages/home_page.dart';
import 'package:chatbot/services/auth_service.dart';
import 'package:chatbot/services/database_service.dart';
import 'package:chatbot/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupInfo extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String adminName;
  const GroupInfo({Key? key, required this.groupName, required this.groupId, required this.adminName}) : super(key: key);


  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  AuthService authService = AuthService();
  Stream? members;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMembers();
  }

  getMembers() async {
    DataBaseService(uid: FirebaseAuth.instance.currentUser!.uid).getGroupMembers(widget.groupId).then((val){
      setState(() {
        members = val;
      });
    });
  }
  
  String getName(String r){
    return r.substring(r.indexOf("_")+1);
  }
  String getId(String res){
    return res.substring(0,res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Group Info"),
        actions: [
          IconButton(onPressed: (){
            showDialog(barrierDismissible: false, context: context, builder: (context){
              return AlertDialog(
                title: const Text("Exit"),
                content: const Text("Are you sure you wanna exit from group ☹️"),
                actions: [
                  IconButton(onPressed: (){
                    Navigator.pop(context);
                  },
                    icon: const Icon(Icons.cancel, color: Colors.red,),
                  ),
                  IconButton(onPressed: () async {
                    DataBaseService(uid: FirebaseAuth.instance.currentUser!.uid).toggleGroupJoin(widget.groupId, getName(widget.adminName) , widget.groupName,).whenComplete((){
                      nextScreenReplace(context, const HomePage());
                    });
                  },
                    icon: const Icon(Icons.exit_to_app, color: Colors.green,),
                  ),
                ],
              );
            });
          }, icon: const Icon(Icons.exit_to_app_outlined))
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Theme.of(context).primaryColor.withOpacity(0.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(widget.groupName.substring(0,1).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w500,color: Colors.white,),
                  )
                  ),
                  const SizedBox(width: 20,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Group: ${widget.groupName}",style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),),
                      const SizedBox(height: 5,),
                      Text("Admin: ${getName(widget.adminName)}",style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),),
                    ],
                  )
                ],
              ),
            ),
            memberList(),
          ],
        ),
      ),
    );
  }
  memberList(){
    return StreamBuilder(
      stream: members,
      builder: (context, AsyncSnapshot snapshot){
        if(snapshot.hasData){
          if(snapshot.data['members'] != null){
            if(snapshot.data['members'].length != 0){
              return ListView.builder(itemCount: snapshot.data['members'].length,
              shrinkWrap: true,
                itemBuilder: (context, index){
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 5),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(getName(snapshot.data['members'][index]).substring(0,1).toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),),
                      ),
                      title: Text(getName(snapshot.data['members'][index])),
                      subtitle: Text(getId(snapshot.data['members'][index])),
                    ),
                  );
                },
              );
            }
            else{
              return const Center(child: Text("NO MEMBERS"),);
            }
          }
          else{
            return const Center(child: Text("NO MEMBERS"),);
          }
        }
        else{
          return Center(
            child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),
          );
        }
      },
    );
  }
}