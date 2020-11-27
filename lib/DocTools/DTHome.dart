import 'package:flutter/material.dart';

class DTHome extends StatelessWidget {
  DTHome({Key key, this.title}) : super(key: key);

  final String title;

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: new DTBody(),
    );
  }
}

class DTBody extends StatelessWidget {
  DTBody() : super();

  Widget build(BuildContext context) {
    return new Center(
      child: Text('Doc Tools'),
    );
  }
}
