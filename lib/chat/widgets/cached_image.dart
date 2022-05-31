import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedImage extends StatelessWidget {
  final String url;

  CachedImage({
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
          child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child:
        GestureDetector(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (_) {
            return DetailScreen(url: url,);
            }));
          },
          child: 
        CachedNetworkImage(
          imageUrl: url,
          placeholder: (context, url) =>
              Center(child: CircularProgressIndicator()),
        ),
      ),),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final String url;

  const DetailScreen({Key? key, required this.url}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("image"),),
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: 'imageHero',
            child: Image.network(url),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}