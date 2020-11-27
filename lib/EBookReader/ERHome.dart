import 'package:flutter/material.dart';

class ERHome extends StatelessWidget {
  ERHome({Key key, this.title}) : super(key: key);

  final String title;

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: new ERBody(),
    );
  }
}

class ERBody extends StatelessWidget {
  ERBody() : super();

  Widget build(BuildContext context) {
    return new Center(
      child: Text('EBook Reader'),
    );
  }
}
