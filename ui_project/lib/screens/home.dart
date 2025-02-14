// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:ui_project/constants/Colors.dart';
import 'package:ui_project/models/todo.dart';
import 'package:ui_project/widgets/todo_items.dart';

class Home extends StatefulWidget {
   Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
final todosList=toDo.todoList();
List<toDo> _found=[];
final _todoController=TextEditingController();

@override
void initState(){
  _found=todosList;
  super.initState();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdbgColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
            child: Column(
              children: [
               SearchBox(),
               Expanded(
                 child: ListView(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 50,bottom: 20),
                      child: Text('All ToDos',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
                 
                    ),
                    for(toDo toDoo in _found.reversed)
                    TodoItems(ToDo: toDoo,
                    onToDoChange: _handleToDOChange,
                    onDeleteItem: _deleteToDoItem,
                    ),
                  ],
                 ),
               )
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                Expanded(child: Container(
                  margin: EdgeInsets.only(bottom: 20,right: 20,left: 20),
                  padding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0, 0,),
                      blurRadius: 10.0,
                      spreadRadius: 0.0,
                    )],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Add new todo items',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                ),
               Container(
                child: ElevatedButton(
                  onPressed: (){
                _addToDoItem(_todoController.text);
                  },
                 child: Text('+',style: TextStyle(fontSize: 40),),
                 style: ElevatedButton.styleFrom(
                  backgroundColor: tdblue,
                  minimumSize: Size(60, 60),
                  elevation: 10,
                 ),
                 ),
               ),
              ],

            ),
          ),
        ],
      ),

    );
  }
  void _handleToDOChange(toDo ToDo){
    setState(() {
      ToDo.isDone=!ToDo.isDone;
    });

  }
  void _deleteToDoItem(String id){
setState(() {
      todosList.removeWhere((item)=>item.id==id);
});
  }

  void _addToDoItem(String todo){
setState(() {
      todosList.add(toDo(id:DateTime.now().millisecondsSinceEpoch.toString(),todoText:todo));
});
_todoController.clear();
  }

  void _runFilter(String enteredKeyword){
    List<toDo> results=[];
    if(enteredKeyword.isEmpty){
      results=todosList;
    }
    else{
      results=todosList.where((item)=>item.todoText!.toLowerCase().contains(enteredKeyword.toLowerCase())).toList();
    }
    setState(() {
      _found=results;
    });
  }

  Widget SearchBox(){
    return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                onChanged: (value)=>_runFilter(value),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(0),
                  prefixIcon: Icon(Icons.search,color:tdblack,size: 20,),
                  prefixIconConstraints: BoxConstraints(
                    maxHeight: 23,
                    minWidth: 20
                  ),
                  hintText: 'Search',
                border: InputBorder.none,
                ),
                

              ),

            );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: tdbgColor,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.menu,color: tdblack,),
          Container(
            width: 40,
            height: 40,
            child: CircleAvatar(
              child: Image.asset('assets/images/1.jpg'),
            ),

          ),
        ],
      ),
    );
  }
}