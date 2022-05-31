
import 'package:flutter/material.dart';

class TabOne extends StatefulWidget {
  TabOne();

  // final VoidCallback loginCallback;
  
  @override
  State<StatefulWidget> createState() => new _TabOneState();
}

class _TabOneState extends State<TabOne> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Welcome ",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        "test",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          fontSize: 20,
                        ),
                      )
                    ],
                  ),
            FlatButton(
              splashColor: Colors.white,
              highlightColor: Theme.of(context).hintColor,
              child: Text(
                "test",
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onPressed: () {
                // auth.signOut().then((onValue) {
                //   Navigator.of(context).pushReplacementNamed('/login');
                // });
              },
            )
          ],
          mainAxisAlignment: MainAxisAlignment.center,
      ),
      ),
      );
  }

  
  
}
