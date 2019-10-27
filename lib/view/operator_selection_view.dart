import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:venturiautospurghi/repository/operators_repository.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/user.dart';
import 'package:venturiautospurghi/view/widget/switch.dart';

class OperatorSelection extends StatefulWidget {
  final Event event;
  final bool tristate;


  OperatorSelection(@required this.event, this.tristate, {Key key,})  :
        assert(event != null),
        super(key: key);

  @override
  _OperatorSelectionState createState()=>_OperatorSelectionState();
}

class _OperatorSelectionState extends State<OperatorSelection>{
  List<Account> operators = [];
  Map<Account,bool> sel = Map();
  bool superChecked = false;

  @override
  void initState() {
    super.initState();
    getOperatorsDB();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Intervento'),
            leading: IconButton(icon:Icon(Icons.arrow_back, color: white),
              onPressed:() => Navigator.pop(context, false),
            )
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.check),
          backgroundColor: dark,
          onPressed:(){if(!widget.tristate || superChecked)Navigator.pop(context, getOperatorsSelected());else
            return Fluttertoast.showToast(
                msg: "Seleziona l' operatore principale, tappando due volte",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIos: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0
            );},
    ),
        body: Material(
        elevation: 12.0,
        borderRadius: new BorderRadius.only(
            topLeft: new Radius.circular(16.0),
            topRight: new Radius.circular(16.0)),
        child: Column(
          children: <Widget>[
            SizedBox(height: 8.0),
            Expanded(
              child: ListView(
                padding: new EdgeInsets.symmetric(vertical: 8.0),
                children: operators.map((operator) => new ChildItem(operator, sel[operator], widget.tristate, onTap)).toList(),
              ),
            )
          ],
        )
      )
    );
  }

  bool onTap(Account op){
    print(sel[op]);
    setState(() {
      if(sel[op]==false) sel[op]=true;
      else if(sel[op]==true && !superChecked && widget.tristate){
        superChecked = true;
        sel[op]=null;
      }else{
        if(sel[op]==null) superChecked = false;
        sel[op]=false;
      }
    });
  }

  Event getOperatorsSelected(){
    //Input Object Account
    //Output Object Map
    List<String> selectedOperatorsId = [];
    List<dynamic> selectedSubOperators = [];
    Account selectedOperator = null;
    sel.keys.forEach((k){
      if(sel[k] == true){
        selectedOperatorsId.add(k.id);
        selectedSubOperators.add(k.toDocument());
      }else if(widget.tristate && sel[k] == null){
        selectedOperatorsId.add(k.id);
        selectedOperator = k;
      }
    });
    if(widget.tristate) {
      widget.event.idOperator = selectedOperator.id;
      widget.event.operator = selectedOperator.toDocument();
    }
    widget.event.idOperators = selectedOperatorsId;
    widget.event.suboperators = selectedSubOperators;
    return widget.event;
  }

  void getOperatorsDB() async {
    //Input Object Account
    //Output Object Map
    OperatorsRepository repo = OperatorsRepository();
    operators = await repo.getOperatorsFiltered();//by DataInizio DataFine
    operators.forEach((a){
      if(a!=null) {
        if (widget.event.idOperator == a.id)
          sel[a] = null;
        else if (widget.event.idOperators.contains(a.id))
          sel[a] = true;
        else
          sel[a] = false;
      }
    });
    setState(() {});
  }
}

class ChildItem extends StatelessWidget {
  final Account operator;
  final bool checked;
  final bool tristate;
  final dynamic onTap;

  ChildItem(this.operator, this.checked, this.tristate, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10.0),
            padding: EdgeInsets.all(2.0),
            child: Icon(Icons.work, color: yellow,),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              color: dark,
            ),
          ),
          Text(operator.surname.toUpperCase() + " ", style: title),
          Text(operator.name, style: subtitle),
          Expanded(child: Container(),),
          tristate?CheckboxTriState(onChanged: (v)=>onTap(operator),
            value: checked, tristate: true, activeColor: dark, checkColor: white, superColor: yellow,):
          Checkbox(onChanged: (v)=>onTap(operator),
            value: checked, activeColor: dark, checkColor: white),
        ],
      ),
    );
  }
}