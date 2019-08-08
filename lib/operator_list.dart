import 'package:flutter/material.dart';
import 'global_contants.dart';

class SearchList extends StatefulWidget {
  SearchList({ Key key }) : super(key: key);
  @override
  _SearchListState createState() => new _SearchListState();

}

class _SearchListState extends State<SearchList>
{
  final key = new GlobalKey<ScaffoldState>();
  final TextEditingController _searchQuery = new TextEditingController();
  List<String> _list;
  bool _IsSearching;
  bool _filters;
  String _searchText = "";

  _SearchListState() {
    _searchQuery.addListener(() {
      if (_searchQuery.text.isEmpty) {
        setState(() {
          _IsSearching = false;
          _searchText = "";
        });
      }
      else {
        setState(() {
          _IsSearching = true;
          _searchText = _searchQuery.text;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _IsSearching = false;
    init();

  }

  void init() {
    _list = List();
    _list.add("Google");
    _list.add("IOS");
    _list.add("Android");
    _list.add("Dart");
    _list.add("Flutter");
    _list.add("Python");
    _list.add("React");
    _list.add("Xamarin");
    _list.add("Kotlin");
    _list.add("Java");
    _list.add("RxAndroid");
  }
  /*
  /////////////////////////////////////////////////////////////////
  CHESSIFA QUI?
  1.Firebase fa UNA richiesta e lavoriamo su un array dato filtrando a posteriori
  2.Firebase fa TANTE richieste quindi i dati arrivano già filtrati e non ci resta che mostrare l'array

  ////////////////////////////////////////////////////////////////
  */

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Home"),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.account_circle, color: Colors.white,),
            onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(Constants.profileRoute,
                        (Route<dynamic> route) => false);
            }
          )
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: searchBar(context)
            ),resultList(1)
          ],
        ),
      ),
    );
  }


  Widget resultList(int mode) {
    if(mode==1){
      return Expanded(
        child: ListView(
          padding: new EdgeInsets.symmetric(vertical: 8.0),
          children: _IsSearching ? _buildSearchList() : _buildList(),
        ),
      );
    }else if(mode == 2){
      return Expanded(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _list.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('${_list[index]}'),
            );
          },
        ),
      );
    }
  }

////METODI PER METODO 1
  List<ChildItem> _buildList() {
    return _list.map((contact) => new ChildItem(contact)).toList();
  }

  List<ChildItem> _buildSearchList() {
    if (_searchText.isEmpty) {
      return _list.map((contact) => new ChildItem(contact))
          .toList();
    }
    else {
      List<String> _searchList = List();
      for (int i = 0; i < _list.length; i++) {
        String  name = _list.elementAt(i);
        if (name.toLowerCase().contains(_searchText.toLowerCase())) {
          _searchList.add(name);
        }
      }
      return _searchList.map((contact) => new ChildItem(contact))
          .toList();
    }
  }
////END

  Widget searchBar(BuildContext context) {
    return TextField(
      controller: _searchQuery,
      decoration: InputDecoration(
          prefixIcon: new Icon(Icons.search, color: Colors.white),
          suffixIcon: IconButton(
              icon: Icon(Icons.tune),
              onPressed: (){setState(() {
                _filters = true;
              });}
          ),
          hintText: "Search...",
          hintStyle: new TextStyle(color: Colors.white),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0)))),
    );
  }

}

class ChildItem extends StatelessWidget {
  final String name;
  ChildItem(this.name);
  @override
  Widget build(BuildContext context) {
    return new ListTile(title: new Text(this.name));
  }

}