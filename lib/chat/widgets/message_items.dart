import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'cached_image.dart';
import 'chatbubbleme.dart';

class MessageItem extends StatefulWidget {
  final String message;
  final String imageUrl;
  final DateTime timestamp;
  final bool isYou;
  final bool isRead;
  final bool isSent;
  final double fontSize;

  MessageItem({
    required this.message,
    required this.timestamp,
    required this.isYou,
    this.isRead = false,
    this.isSent = false,
    required this.fontSize,
    required this.imageUrl,
  });

@override
  _MessageItemState createState() => _MessageItemState();
}

class _MessageItemState extends State<MessageItem>{

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return _buildMessage();
  }

  final chatboxIsYou = BoxDecoration(
                  color: const Color(0xFF512c7c),
                  borderRadius: BorderRadius.only(topLeft:Radius.circular(10.0),topRight:Radius.circular(10.0),bottomLeft:Radius.circular(10.0))
                  // borderRadius: BorderRadius.all(Radius.circular(5.0))
                  );

  final chatboxIsNotYou = BoxDecoration(
                  boxShadow: [
                    new BoxShadow(
                        color: Colors.grey,
                        offset: new Offset(1.0, 1.0),
                        blurRadius: 1.0)
                  ],
                  color: Colors.white,
                  // borderRadius: BorderRadius.all(Radius.circular(5.0))
                  );
                  
  Widget _buildMessage() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment:
          widget.isYou ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: CustomPaint(
          painter: widget.isYou ? ChatBubble(color:const Color(0xFF512c7c),alignment: Alignment.topRight):ChatBubble(color:Colors.white,alignment: Alignment.topLeft),
          child:Container(
            margin: widget.isYou ? EdgeInsets.only(right:10):EdgeInsets.only(left:10),
              decoration: widget.isYou ? chatboxIsYou: chatboxIsNotYou,
              constraints: BoxConstraints(
                minWidth: 100.0,
                maxWidth: 280.0,
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    constraints: BoxConstraints(
                      minWidth: 100.0,
                    ),
                    child: widget.imageUrl != null ? CachedImage(url: widget.imageUrl,) : Text(
                      widget.message,
                      style: TextStyle(
                        color: widget.isYou ? Colors.white:Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(height: 5,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 100.0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              new DateFormat('HH:mm').format(widget.timestamp),
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12.0,
                              ),
                            ),
                            SizedBox(
                              width: 4.0,
                            ),
                            widget.isYou
                                ? _getIcon()
                                : Container()
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ))),
        ),
      ],
    );
  }
  
  Widget _getIcon() {
    if(!widget.isSent) {
      return Icon(
        Icons.check,
        size: 18.0,
        color: Colors.green,
      );
    }
    return Icon(
      Icons.done_all,
      size: 18.0,
      color:
      widget.isRead ?  Colors.green : Colors.grey,
    );
  }
}

