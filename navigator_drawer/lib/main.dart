import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      darkTheme: ThemeData(brightness: Brightness.dark),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Welcome',),
        ),
        body: Center(
          child: Text('Welcome',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
            
              DrawerHeader(
                margin: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                child: UserAccountsDrawerHeader(
                accountName: Text('Programmer',
                style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),),
                accountEmail: Text('atifraheem458@gmail.com',style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: AssetImage('images/1.jpg'),
                ),
                ),
                ),
                ListTile(
                  leading: Icon(
                    CupertinoIcons.home
                  ),
                  title: Text('Home',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),),
                ),

                 ListTile(
                  leading: Icon(
                    CupertinoIcons.mail_solid
                  ),
                  title: Text('Mail',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),),
                ),

                 ListTile(
                  leading: Icon(
                    CupertinoIcons.bolt_horizontal_circle_fill,
                  ),
                  title: Text('Container',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),),
                ),
                 ListTile(
                  leading: Icon(
                    CupertinoIcons.chart_pie_fill
                  ),
                  title: Text('State',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),),
                ),
            ],
          ),
        ),
      ),
      );
  }
}

