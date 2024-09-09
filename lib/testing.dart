import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyHomePage extends StatelessWidget {
  Future<String> getPosts() async {
    final uri = Uri.parse('https://jsonplaceholder.typicode.com/posts');
    var resp = await http.get(uri);
    return resp.body;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: getPosts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(
              'There was an error 🥲',
            );
          } else if (snapshot.hasData) {
            var count = json.decode(snapshot.data!).length;
            return Text(
              'You have $count posts.',
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}