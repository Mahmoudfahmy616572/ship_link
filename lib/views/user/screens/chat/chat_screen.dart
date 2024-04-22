import 'package:flutter/material.dart';
import 'package:ship_link/views/shared/app_style.dart';

import 'components/reciever_message.dart';
import 'components/sender_message.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});
  static String routName = '/ChatScreen';

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.grey[900],
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Mahmoud Fahmy",
                style: appStyle(17, FontWeight.w600, Colors.white),
              ),
              Text("Online",
                  style: appStyle(15, FontWeight.normal, Colors.grey))
            ],
          ),
          leading: const Padding(
            padding: EdgeInsets.all(7.0),
            child: CircleAvatar(
              backgroundImage: AssetImage(
                "assets/images/robot.png",
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.report_gmailerrorred,
                color: Colors.white,
              ),
            )
          ],
        ),
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: ListView(
            children: [
              //Date Box
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(5),
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(5),
                              bottomRight: Radius.circular(12))),
                      child: Text(
                        "Today",
                        style: appStyle(16, FontWeight.normal, Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              // receiver message
              const RecieverMessage(),
              // sender message
              const SenderMessage(),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(30),
                              topLeft: Radius.circular(30),
                              bottomLeft: Radius.circular(0),
                              bottomRight: Radius.circular(30))),
                      child: Text(
                        "Hello i'm here mother fucker",
                        style: appStyle(16, FontWeight.normal, Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
