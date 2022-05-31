import 'package:TrueCare2u_flutter/chat/widgets/cached_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';



class ViewImage extends StatelessWidget {
  final String url;
  final String appointmentId;

  const ViewImage({Key? key, required this.url, required this.appointmentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var title = 'Results $appointmentId';

    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Center(child: 
        CachedNetworkImage(
          imageUrl: url,
          placeholder: (context, url) =>
              Center(child: CircularProgressIndicator()),
        ),),
      ),
    );
  }
}