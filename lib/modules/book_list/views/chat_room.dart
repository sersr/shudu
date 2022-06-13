import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../../utils/im/server.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({Key? key}) : super(key: key);

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final controllerLeft = TextEditingController();
  final controllerRight = TextEditingController();

  late final FocusNode focusNode;
  late final FocusNode focusNode2;

  late ServerBase base;
  User? user01, user02;
  Future? _future;
  final _user01List = <Message>[];

  StreamSubscription? subscription;
  final notifier = ValueNotifier(false);
  late ScrollController controller;
  @override
  void initState() {
    super.initState();
    controller = ScrollController();
    base = ServerBase();
    _future = base.bindServer().then((_) async {
      await User(name: 'user01', pwd: 'password_1101')
          .init()
          .then((user) => user01 = user);
      await User(name: 'user02', pwd: 'password_0010')
          .init()
          .then((user) => user02 = user);
      subscription = await user01?.listen((msg) {
        if (msg is Message) {
          _user01List.add(msg);
          // 测试
          notifier.value = !notifier.value;
        }
      });
    });
    focusNode = FocusNode(debugLabel: 'send meg', onKey: onKey);
    focusNode2 = FocusNode(debugLabel: 'send meg2', onKey: onKey);
  }

  @override
  void dispose() {
    super.dispose();
    _future?.then((value) {
      subscription?.cancel();
      user01?.close();
      user02?.close();
      base.close();
    });
  }

  KeyEventResult onKey(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        final controller = node == focusNode ? controllerLeft : controllerRight;
        sendMeg(controller);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('聊天室'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              color: Colors.grey.shade300,
              child: NotificationListener(
                onNotification: (Notification notification) {
                  if (notification is OverscrollIndicatorNotification) {
                    notification.disallowIndicator();
                  }
                  return false;
                },
                child: AnimatedBuilder(
                    animation: notifier,
                    builder: (context, child) {
                      if (_user01List.isEmpty)
                        return Center(child: Text('没有消息'));
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          if (controller.hasClients) {
                            final end = controller.position.maxScrollExtent;
                            if (end != 0.0) {
                              // final _ise = controller.offset == end;
                              controller.animateTo(end,
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.ease);
                              // if (!_ise) {
                              //   f.then((_) {
                              //     SchedulerBinding.instance!.addPostFrameCallback((_) {
                              //       if (mounted) {
                              //         final end = controller.position.maxScrollExtent;
                              //         controller.animateTo(end,
                              //             duration: Duration(milliseconds: 300), curve: Curves.ease);
                              //       }
                              //     });
                              //   });
                              // }
                            }
                          }
                        }
                      });
                      return ListView.builder(
                        controller: controller,
                        itemCount: _user01List.length,
                        itemBuilder: (context, index) {
                          final msg = _user01List[index];
                          return msg.user == user01?.name
                              ? Container(
                                  padding: const EdgeInsets.only(
                                      top: 2.0, bottom: 2.0, right: 40.0),
                                  child: Row(
                                    children: [
                                      Center(
                                        child: Text.rich(
                                          TextSpan(children: [
                                            TextSpan(
                                                text: '${msg.user}\n',
                                                style: TextStyle(fontSize: 12)),
                                            TextSpan(
                                                text:
                                                    '${msg.date.hour}:${msg.date.minute}:${msg.date.second.toString().padLeft(2, '0')}',
                                                style: TextStyle(fontSize: 10))
                                          ]),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      SizedBox(width: 6.0),
                                      Expanded(
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6.0, horizontal: 8.0),
                                            decoration: BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            child: Container(
                                              color: Colors.black,
                                              child: Text(
                                                '${msg.data} hi无法忘记我',
                                                // textAlign: TextAlign.start,
                                                strutStyle: StrutStyle(
                                                  fontSize: 15,
                                                  height: 1.73,
                                                  // leadingDistribution: TextLeadingDistribution.even,
                                                  forceStrutHeight: true,
                                                ),
                                                style: TextStyle(
                                                    color:
                                                        Colors.grey.shade300),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.only(
                                      top: 2.0, bottom: 2.0, left: 40.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: Container(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6.0, horizontal: 8.0),
                                          decoration: BoxDecoration(
                                            color: Colors.pink.shade600,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Text(
                                            '${msg.data}',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                color: Colors.grey.shade300),
                                          ),
                                        ),
                                      )),
                                      SizedBox(width: 6.0),
                                      Text.rich(
                                        TextSpan(children: [
                                          TextSpan(
                                              text: '${msg.user}\n',
                                              style: TextStyle(fontSize: 12)),
                                          TextSpan(
                                              text:
                                                  '${msg.date.hour}:${msg.date.minute}:${msg.date.second.toString().padLeft(2, '0')}',
                                              style: TextStyle(fontSize: 10)),
                                        ]),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                );
                        },
                      );
                    }),
              ),
            ),
          ),
          Container(
            // height: 50,
            color: Colors.grey.shade200,
            padding:
                const EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    sendMeg(controllerLeft);
                  },
                  child: Center(
                      child: Text(
                    '发送',
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                  )),
                ),
                Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6.0, horizontal: 4.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                              border: InputBorder.none, isCollapsed: true),
                          controller: controllerLeft,
                          focusNode: focusNode,
                          cursorColor: Colors.blueAccent.shade200,
                          style: TextStyle(
                              fontSize: 15, color: Colors.grey.shade800),
                        ),
                      ),
                    )),
                Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6.0, horizontal: 4.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        child: Center(
                          child: TextField(
                            decoration: InputDecoration(
                                border: InputBorder.none, isCollapsed: true),
                            controller: controllerRight,
                            focusNode: focusNode2,
                            cursorColor: Colors.pink.shade200,
                            style: TextStyle(
                                fontSize: 15, color: Colors.grey.shade800),
                          ),
                        ),
                      ),
                    )),
                InkWell(
                  onTap: () {
                    sendMeg(controllerRight);
                  },
                  child: Center(
                      child: Text(
                    '发送',
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                  )),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void sendMeg(TextEditingController controller) {
    final text = controller.text;
    if (text.replaceAll(RegExp(' |\u3000'), '').isEmpty) return;
    controller.clear();
    if (controllerLeft == controller) {
      user01?.add(text);
      focusNode2.requestFocus();
    } else {
      user02?.add(text);
      focusNode.requestFocus();
    }
  }
}
