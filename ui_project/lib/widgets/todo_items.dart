import 'package:flutter/material.dart';
import 'package:ui_project/constants/Colors.dart';
import 'package:ui_project/models/todo.dart';

class TodoItems extends StatelessWidget {
  final toDo ToDo;
  final onToDoChange;
  final onDeleteItem;
  
  const TodoItems({Key? key,required this.ToDo,required this.onToDoChange, required this.onDeleteItem}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: ListTile(
        onTap: (){
          onToDoChange(ToDo);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), 
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
        tileColor: Colors.white,
        leading: Icon(
          ToDo.isDone? Icons.check_box:Icons.check_box_outline_blank,color: tdblue,),
        title: Text(
          ToDo.todoText!,
          style: TextStyle(fontSize: 16,color:tdblack,decoration:ToDo.isDone? TextDecoration.lineThrough:null),),
        trailing: Container(
          padding: EdgeInsets.all(0),
          margin: EdgeInsets.symmetric(vertical: 12),
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            color: tdred,
            borderRadius: BorderRadius.circular(5),
          ),
          child: IconButton(
            onPressed: (){
              onDeleteItem(ToDo.id);
            },
            color: Colors.white,
            iconSize: 18,
             icon: Icon(Icons.delete)),
        ),
      ),
    );
  }
}