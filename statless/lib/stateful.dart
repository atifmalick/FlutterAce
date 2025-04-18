import 'package:flutter/material.dart';

class Stateful extends StatefulWidget {
  const Stateful({super.key});

  @override
  State<Stateful> createState() => _StatefulState();
}

class _StatefulState extends State<Stateful> {
  int x=0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Provider '),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(DateTime.now().toString()),
           Container(
          child: Center(child: Text(x.toString(), style: TextStyle(fontSize: 50),)),
         )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          x++;
          print(x);
          setState(() {
            
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}