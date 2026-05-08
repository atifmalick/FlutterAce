// ignore_for_file: camel_case_types, unused_import

import 'package:flutter/material.dart';

class toDo {
  String? id;
  String? todoText;
  bool isDone;

toDo({
  required this.id,
  required this.todoText,
  this.isDone=false,
});

static List<toDo> todoList(){
  return [
    toDo(id: '01', todoText: 'Morning Exercise', isDone: true),
    toDo(id: '02', todoText: 'Buying Groceries', isDone: true),
    toDo(id: '03', todoText: 'Check emails', ),
    toDo(id: '04', todoText: 'Team Meeting', ),
    toDo(id: '05', todoText: 'Work on mobile', ),
    toDo(id: '06', todoText: 'Dinner with someone', ),

  ];
}

}

