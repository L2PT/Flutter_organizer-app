import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/plugins/dispatcher/mobile.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/views/widgets/switch_widget.dart';

class ListTileOperator extends StatelessWidget {
  final Account operator;
  final int checkbox;
  final int isChecked;
  final dynamic onTap;
  final dynamic onRemove;
  bool darkStyle;


  ListTileOperator(this.operator, {this.darkStyle = false, this.checkbox = 0, this.isChecked = 0, this.onTap, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap != null ? ()=>onTap?.call(operator):null,
      child: Container(
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: PlatformUtils.isMobile?20:5),
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 10.0),
              padding: EdgeInsets.all(3.0),
              child: Icon(operator.supervisor? FontAwesomeIcons.userTie : FontAwesomeIcons.hardHat, color: darkStyle?black:yellow,),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                color: darkStyle?yellow:black,
              ),
            ),
            Text(operator.surname.toUpperCase() + " ", style: PlatformUtils.isMobile? title.copyWith(color: darkStyle? grey_light:black):
              title.copyWith(color: darkStyle? grey_light:black, fontSize: 16)),
            Text(operator.name, style: PlatformUtils.isMobile?subtitle:subtitle.copyWith(fontSize: 14)),
            Expanded(child: Container(),),
            checkbox>=2?CheckboxTriState(onChanged: (v)=>onTap?.call(operator),
              value: isChecked>0?true:false, activeColor: black, checkColor: isChecked>=2?yellow:white, superColor: yellow,):
            checkbox>=1?Checkbox(onChanged: (v)=>onTap?.call(operator),
              value: isChecked>0?true:false, activeColor: black, checkColor: white,):
            onRemove != null?IconButton(
                icon: Icon(Icons.delete, color: darkStyle?grey_dark:black, size: 25),
                onPressed: () => onRemove(operator)
            ):
            Container()
          ],
        ),
      )
    );
  }
}