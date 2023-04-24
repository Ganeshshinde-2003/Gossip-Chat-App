import 'package:chatbot/helper/helper_function.dart';
import 'package:chatbot/pages/chat_page.dart';
import 'package:chatbot/services/database_service.dart';
import 'package:chatbot/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  bool isLoading = false;
  QuerySnapshot? searchSnapShot;
  bool hasUserSearched = false;
  String userName = "";
  User? user;
  bool isJoined = false;

  @override
  void initState() {
    super.initState();
    getCurrentUserIdandName();
  }

  String getName(String r){
    return r.substring(r.indexOf("_")+1);
  }
  String getId(String res){
    return res.substring(0,res.indexOf("_"));
  }

  getCurrentUserIdandName() async {
    await HelperFunction.getUserNameFromSF().then((value) {
      setState(() {
        userName = value!;
      });
    });
    user = FirebaseAuth.instance.currentUser;
  }

  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Search", style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search Groups....",
                      hintStyle: TextStyle(color: Colors.white, fontSize: 16,),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    initiateSearchMethod();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(Icons.search_rounded,color: Colors.white,),
                  ),
                )
              ],
            ),
          ),
          isLoading ? Center(
            child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),
          ) :
              groupList(),
        ],
      ),
    );
  }

  initiateSearchMethod() async {
    if(searchController.text.isNotEmpty){
      setState(() {
        isLoading =  true;
      });
      await DataBaseService().serachByName(searchController.text).then((snapshot){
         setState(() {
           searchSnapShot = snapshot;
           isLoading = false;
           hasUserSearched = true;
         });
      });
    }
  }
  groupList(){
    return hasUserSearched ? ListView.builder(
      shrinkWrap: true,
      itemCount: searchSnapShot!.docs.length,
      itemBuilder: (context,index){
        return groupTile(
          userName,
          searchSnapShot!.docs[index]["groupId"],
          searchSnapShot!.docs[index]['groupName'],
          searchSnapShot!.docs[index]["admin"],
        );
      },
    )
        : Container();
  }

  joinedOrNot(String userName, String groupId, String groupName, String admin) async {
    bool userJoined = await DataBaseService(uid: user!.uid).isUserJoined(groupName, groupId, userName);
    setState(() {
      isJoined = userJoined;
    });
  }
  Widget groupTile(String userName, String groupId, String groupName, String admin){

    // to checkuser is in group or not
    joinedOrNot(userName,groupId,groupName,admin);
    return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
    leading: CircleAvatar(radius: 30,
    backgroundColor: Theme.of(context).primaryColor,
    child: Text(groupName.substring(0,1).toUpperCase(), style: const TextStyle(color: Colors.white),),
    ),
    title: Text(groupName, style: const TextStyle(fontWeight: FontWeight.w600),),
    subtitle: Text("Admin: ${getName(admin)}"),
      trailing: InkWell(
        onTap: ()async{

          await DataBaseService(uid: user!.uid).toggleGroupJoin(groupId, userName, groupName);
          if(isJoined){
            setState(() {
              isJoined = !isJoined;
              showSnakbar(context, Colors.green, "Successfully joined the group");
            });
            Future.delayed(const Duration(milliseconds: 2000),(){
              nextScreen(context, ChatPage(userName: userName, groupId: groupId, groupName: groupName));
          });
          }
          else{
             setState(() {
               isJoined = !isJoined;
               showSnakbar(context, Colors.red, "Left the group $groupName");
             });
          }
        },
        child: isJoined ? Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black,
            border: Border.all(color: Colors.white, width: 1)
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
          child: const Text("Joined", style: TextStyle(color: Colors.white),),
        ):Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).primaryColor,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
          child: const Text("Join Now", style: TextStyle(color: Colors.white),),
        ),
      ),
    );
  }
}