import 'package:flutter/material.dart';

class home_screen extends StatefulWidget{
  static const String id='home_screen';
  const home_screen({Key? key}): super(key:key);

  @override
  State<home_screen> createState()=> home_screenState();
  }
class home_screenState extends State<home_screen>{
  @override
  Widget build(BuildContext context){
    return DefaultTabController(
      length: 3,
      child:  Scaffold(
      appBar: AppBar(
        title: Text('WhatsApp'),
        bottom: TabBar(
          tabs:[
            Text('Chat'),
            Text('Status'),
            Text('Calls'),
          ],
           ),
      ),
      body: TabBarView(
        children: [
          Text('1'),
          Text('1'),
          Text('1'),

        ],
         ),
    ),
  );
    }
}