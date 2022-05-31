import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyCustomroute {

  goToSinglePost(id){
    return MaterialPageRoute(
      // builder: (context) => new SinglePostArticles(),
      settings: RouteSettings(
      arguments: id,
      ), builder: (BuildContext context) {
        return id;
    },
      );
  }

  void goToIndex(BuildContext ctx) {
    Navigator.pushNamed(ctx, '/INDEX');
  }

  openProduct(productslug){
    return MaterialPageRoute(
      // builder: (context) => new ProductPage(),
      settings: RouteSettings(
      arguments: productslug,
      ), builder: (BuildContext context) {
        return productslug;
    },
      );
  }

  openHealthConditionInfoPage(BuildContext ctx,String servicetype){
    Navigator.pushNamed(ctx, '/MEDICALCHECKUP',arguments: servicetype);
  }
}