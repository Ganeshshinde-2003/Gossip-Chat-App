import 'package:chatbot/pages/group_info.dart';
import 'package:chatbot/services/database_service.dart';
import 'package:chatbot/widgets/message_tile.dart';
import 'package:chatbot/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  const ChatPage({Key? key, required this.userName, required this.groupId, required this.groupName}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  Stream<QuerySnapshot>? chats;
  TextEditingController messaagesController = TextEditingController();
  String admin = "";

  @override
  void initState() {
    super.initState();
    getChatandAdmin();
  }

  getChatandAdmin() async {
    var chatResult = await DataBaseService().getChats(widget.groupId);
    if (chatResult != null) {
      setState(() {
        chats = chatResult;
      });
    }

    var adminResult = await DataBaseService().getGroupAdmin(widget.groupId);
    if (adminResult != null) {
      setState(() {
        admin = adminResult;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(widget.groupName),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(onPressed: (){
            nextScreen(context, GroupInfo(groupId: widget.groupId, groupName: widget.groupName, adminName: admin,));
          }, icon: const Icon(Icons.info_outline))
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 9,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.9,
              child: chatMessages(),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                width: MediaQuery.of(context).size.width,
                color: Colors.grey[700],
                child: Row(
                  children: [
                    Expanded(child: TextFormField(
                      controller: messaagesController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Let's chat!!!",
                        hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                        border: InputBorder.none,
                      ),
                    )),
                    const SizedBox(width: 12,),
                    GestureDetector(
                      onTap: (){
                        sendMessage();
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const Center(child: Icon(Icons.send_outlined, color: Colors.white,)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  chatMessages() {
    return StreamBuilder(
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            return MessageTile(
              message: snapshot.data.docs[index]['message'],
              sender: snapshot.data.docs[index]['sender'],
              sentByMe: widget.userName == snapshot.data.docs[index]['sender'],
            );
          },
        )
            : Container();
      },
      stream: chats,
    );
  }

  sendMessage(){
    if(messaagesController.text.isNotEmpty){
      Map<String, dynamic> chatMessageMap = {
        "message": messaagesController.text,
        "sender":widget.userName,
        "time":DateTime.now().millisecondsSinceEpoch,
      };
      DataBaseService().sendMessage(
        widget.groupId,
        chatMessageMap
      );
      setState(() {
        messaagesController.clear();
      });
    }
  }
}