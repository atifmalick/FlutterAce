import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('List Cards'),
        ),
        body: Column(
          children: [
            Card(
              child: ListTile(
                leading: Image.asset('images/1.jpg'),
                title: Text('How to create cards in flutter',
                style: TextStyle(
                  fontSize: 19,

                ),
                ),
                subtitle: Padding(padding: EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  'In this video I will tell how to create card',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black.withOpacity(0.2),
                  ),
                ),),
              ),
            ),
            SizedBox(
              height: 12,

            ),
            Card(
              child: ListTile(
                leading: Image.asset('images/2.jpg'),
                title: Text('How to create cards in flutter',
                style: TextStyle(
                  fontSize: 19,

                ),
                ),
                subtitle: Padding(padding: EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  'In this video I will tell how to create card',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black.withOpacity(0.2),
                  ),
                ),),
              ),
            ),
            SizedBox(
              height: 12,

            ),
            Card(
              child: ListTile(
                leading: Image.asset('images/3.jpg'),
                title: Text('How to create cards in flutter',
                style: TextStyle(
                  fontSize: 19,

                ),
                ),
                subtitle: Padding(padding: EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  'In this video I will tell how to create card',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black.withOpacity(0.2),
                  ),
                ),),
              ),
            ),
            SizedBox(
              height: 12,

            ),
            Card(
              child: ListTile(
                leading: Image.asset('images/4.jpg'),
                title: Text('How to create cards in flutter',
                style: TextStyle(
                  fontSize: 19,

                ),
                ),
                subtitle: Padding(padding: EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  'In this video I will tell how to create card',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black.withOpacity(0.2),
                  ),
                ),),
              ),
            ),
            SizedBox(
              height: 12,

            ),
          ],
        ),
      ),
     );
  }
}
