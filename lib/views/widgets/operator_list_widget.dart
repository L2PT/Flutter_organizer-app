import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/utils/theme.dart';

class OperatorsList extends StatelessWidget {

  List<Account> operators;
  final void Function(Account operator) closeFunction;
  final bool Function(Account operator) canRemove;
  bool darkMode;
  bool isWebMode;

  OperatorsList({
    required this.operators,
    required this.closeFunction,
    required this.canRemove,
    this.darkMode = false,
    this.isWebMode = false,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> buildOperatorsList() =>
        (this.operators).map((operator) {
          return Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: isWebMode?5:20),
            child: Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(right: 10.0),
                  padding: EdgeInsets.all(3.0),
                  child: Icon(operator.supervisor
                      ? FontAwesomeIcons.userTie
                      : FontAwesomeIcons.hardHat, color: darkMode?black:yellow),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    color: darkMode?yellow:black,
                  ),
                ),
                isWebMode? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(operator.surname.toUpperCase() + " ", style: title.copyWith(color: this.darkMode? grey_light:black,
                        fontSize: 16)),
                    Text(operator.name, style: subtitle.copyWith(fontSize: 14)),
                  ],
                ):Row(
                  children: [
                    Text(operator.surname.toUpperCase() + " ", style: title.copyWith(color: this.darkMode? grey_light:black)),
                    Text(operator.name, style: subtitle),
                  ],
                ),
                Expanded(
                  child: Container(),
                ),
                this.canRemove(operator)?
                IconButton(
                    icon: Icon(Icons.delete, color: this.darkMode?grey_dark:black, size: 25),
                    onPressed: () => this.closeFunction(operator)
                ): Container()
              ],
            ),
          );
        }).toList();

    return Container(child: Column(children: buildOperatorsList()));
  }
}