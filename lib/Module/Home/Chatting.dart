
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_course/Helper/ConstHelper/ConstHelper.dart';

import '../../Services/DataBaseService.dart';
import 'GroupInfo.dart';
import 'Messeges.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  const ChatPage(
      {Key? key,
        required this.groupId,
        required this.groupName,
        required this.userName})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  String admin = "";

  @override
  void initState() {
    getChatandAdmin();
    super.initState();
  }

  getChatandAdmin() {
    DataBaseService().getChats(widget.groupId).then((val) {
      setState(() {
        chats = val;
      });
    });
    DataBaseService().getGroupAdmin(widget.groupId).then((val) {
      setState(() {
        admin = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(widget.groupName),
        backgroundColor: ConstantColors.bl,
        actions: [
          IconButton(
              onPressed: () {
                navigateToNextScreen(
                    context,
                    GroupInfo(
                      groupId: widget.groupId,
                      groupName: widget.groupName,
                      adminName: admin,
                    ));
              },
              icon: const Icon(Icons.info))
        ],
      ),
      body: Stack(
        children: <Widget>[
          //chat messages here
         chatMessages(),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              width: MediaQuery.of(context).size.width,
              color:ConstantColors.bl,
              child: Row(children: [
                Expanded(
                    child: TextFormField(
                      controller: messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Send a message...",
                        hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                        border: InputBorder.none,
                      ),
                    )),
                const SizedBox(
                  width: 12,
                ),
                GestureDetector(
                  onTap: () {
                    sendMessage();
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child:  Center(
                        child: Icon(
                          Icons.send,
                          color:  ConstantColors.bl,
                        )),
                  ),
                )
              ]),
            ),
          )
        ],
      ),
    );
  }

  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            return MessageTile(
                message: snapshot.data.docs[index]['message'],
                sender: snapshot.data.docs[index]['sender'],
                sentByMe: widget.userName ==
                    snapshot.data.docs[index]['sender']);
          },
        )
            : Container();
      },
    );
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
      };

      DataBaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }
}