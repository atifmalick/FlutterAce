import 'package:carousel_slider/carousel_slider.dart';
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
          title: Text('Slider'),
        ),
        body: CarouselSlider(
          options: CarouselOptions(
            viewportFraction: 0.8,
            height: 250,
            autoPlay: true,
          ),
          items: [
          "images/1.jpg",
          "images/2.jpg",
          "images/3.jpg",
        ].map((e){
          return Builder(builder: (BuildContext context){
            return Container(
              width: MediaQuery.of(context).size.width,
              child: Image.asset(e,fit: BoxFit.cover,),
            );

          },);

        }).toList(),
        ),
      ),
    );
  }
}
