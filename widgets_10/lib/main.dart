import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('10 Widgets'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
                child: CircleAvatar(
              radius: 85,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(
                  'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
            )),
            //      Row(
            //      children: [
            //      Expanded(
            //      flex: 2,
            //      child: Container(
            //      color: Colors.green,
            //     height: 250,
            //    child: Center(
            //     child: Text('Container'),
            //   ),
            //       ),
            //   ),
            //     Expanded(
            //     child: Container(
            //      color: Colors.red,
            //    height: 250,
            //     child: Center(
            //      child: Text('Container'),
            //  ),
            //            ),
            ///        ),
            //       ],
            //    ),
            //   Center(
            //   child: Container(
            //   width: 100,
            //  height: 100,
            //    padding: EdgeInsets.all(20),
            //  transform: Matrix4.rotationZ(.2),
            // decoration: BoxDecoration(
            //   color: Colors.orange,
            // borderRadius: const BorderRadius.only(
            // topLeft: Radius.circular(30),
            //   ),
            // border: Border.all(
            // color: Colors.red,
            // width: 10,
            //  ),
            // image: DecorationImage(
            // fit: BoxFit.cover,
            //     image: NetworkImage(
            //       'https://images.pexels.com/photos/27576233/pexels-photo-27576233/free-photo-of-a-person-walking-on-a-grassy-hill-near-the-ocean.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
            // ),
            //boxShadow: [
            // BoxShadow(
            // color: Colors.green,
            ///  blurRadius: 100,
            //   ),
            //]),
            //         child: Center(child: Text('Contanier')),
            //     ),
            // )
          ],
        ),
      ),
    );
  }
}
