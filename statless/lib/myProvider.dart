import 'package:flutter/material.dart';
import 'dart:async';
class Myprovider extends StatefulWidget {
  const Myprovider({super.key});

  @override
  State<Myprovider> createState() => _MyproviderState();
}

class _MyproviderState extends State<Myprovider> {
  int x=0;
  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (timer){
    x++;
    print(x);
    
    setState(() {
      
    });
    
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Why Provider'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(DateTime.now().hour.toString()+":"+DateTime.now().minute.toString()+":"+DateTime.now().second.toString(),
            style: TextStyle(fontSize: 50),
            ),
            
          ),
          Center(
            child: Text(x.toString(), style: TextStyle(fontSize: 50),),
          )
          
        ],
      ),
    
    );
  }
}