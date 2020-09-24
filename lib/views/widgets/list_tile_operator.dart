import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/views/widgets/switch_widget.dart';

class ListTileOperator extends StatelessWidget {
  final Account operator;
  final int checkbox;
  final int isChecked;
  final dynamic onTap;

  ListTileOperator(this.operator, {this.checkbox = 0, this.isChecked = 0, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: checkbox==0? ()=>onTap?.call(operator):null,
      child: Container(
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 10.0),
              padding: EdgeInsets.all(3.0),
              child: Icon(Icons.work, color: yellow,),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                color: black,
              ),
            ),
            Text(operator.surname.toUpperCase() + " ", style: title),
            Text(operator.name, style: subtitle),
            Expanded(child: Container(),),
            checkbox>=2?CheckboxTriState(onChanged: (v)=>onTap?.call(operator),
              value: isChecked>0?true:false, tristate: true, activeColor: black, checkColor: isChecked>=2?yellow:white, superColor: yellow,):
            checkbox>=1?Checkbox(onChanged: (v)=>onTap?.call(operator),
              value: isChecked>0?true:false, activeColor: black, checkColor: white,):
            Container(),
          ],
        ),
      )
    );
  }
}