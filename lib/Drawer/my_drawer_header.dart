import 'package:flutter/material.dart';

class MyHeaderDrawer extends StatefulWidget{
 
 
 final String username;
 final String designation;
 final String user;


 const MyHeaderDrawer({
  required this.username,
  required this.designation,
  required this.user
 });
  @override
  State<StatefulWidget> createState() =>_MyHeaderDrawerState();

}

class _MyHeaderDrawerState extends State<MyHeaderDrawer>{
  @override
  Widget build(BuildContext context) {
   
   return Container(
    color: Colors.blue[800],
    width: double.infinity,
    height:200,
    padding: EdgeInsets.only(top: 20.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 10),
          height: 70,
          decoration: BoxDecoration(
            color: Colors.blue[300],
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage('assets/White_profile.png'),
              )
          ),
        ),
        Text(
          "${widget.username}",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold
          ),
        ),

                Text(
          "(${widget.user})",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold
          ),
        ),
                Text(
          "${widget.designation}",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold
          ),
        )

      ],
    ),


   );
  }
}