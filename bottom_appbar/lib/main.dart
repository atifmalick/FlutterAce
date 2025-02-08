import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Bottom-AppBar'),

      ),
      body: Center(
        child: Text('Welcome',style: TextStyle(
          fontStyle: FontStyle.italic,
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ),),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blueGrey,
        child: Row(
          children: [
            IconButton(onPressed: (){}, icon: Icon(Icons.home,color: Colors.white,),),
            Spacer(),
            IconButton(onPressed: (){}, icon: Icon(Icons.search,color: Colors.white,),),
            IconButton(onPressed: (){}, icon: Icon(Icons.more_vert,color: Colors.white,),),


          ],
        ),
        
      ),
      floatingActionButton: FloatingActionButton(child: Icon(Icons.add), backgroundColor: Colors.white,onPressed: () {},),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      drawer: Drawer(),
      ),
    );
  }
}
