import 'package:flutter/material.dart';

void main() {
  runApp(myapp());

}
class myapp extends StatelessWidget{
  const myapp({Key? key}): super(key :key);

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
    home:Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: const Text(
          'I am Atif Malik',
          style:TextStyle(fontSize:30, fontFamily: 'Pacifo'),),
      ),
    body: SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start ,
        children:  [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:const [
              Text('Atif'),
              Icon(Icons.ac_unit),
              Text('Atif'),
            ],
          ),
       const SizedBox(
            height: 45,
            
          ),
          Container(
            width: 100,
            height: 100,
            color: Colors.purple,
            child: const Center(child: Text('Container 1')),
          ),
          const SizedBox(
            height: 25,
            
          ),
          Container(
            width: 100,
            height: 100,
            color: Colors.blue,
            child: const Center(child: Text('Container 2')),
          ),
          const SizedBox(
            height: 25,
            
          ),
          Container(
            width: 100,
            height: 100,
            color: Colors.black,
            child: const Center(child: Text('Container 3')),
          ),
        ],
      ),
    ), 
    )
    );
  }
}

