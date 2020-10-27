import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/utils/theme.dart';

class Profile extends StatelessWidget {
  Size deviceSize;

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    Account account = context.bloc<AuthenticationBloc>().account;
    Widget userProfile = Container(
      child: Column(
        children: <Widget>[
          new ClipPath(
            clipper: MyClipper(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: 10.0, bottom: 100.0),
            ),
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40.0),
                border: Border.all(
                    width: 6.0, color: Colors.white)),
            child: CircleAvatar(
              radius: 40.0,
              backgroundImage: NetworkImage("https://i.mmo.cm/is/image/mmoimg/bigview/john-doe-foam-latex-mask--mw-117345-1.jpg"),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child:
            Text(account.name + " "+ account.surname,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: black, )),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child:
            Text(account.email,
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 22, color: grey_dark),),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child:
            Text(account.codFiscale,
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 22, color: grey_dark)),
          ),
          Padding(
              padding: EdgeInsets.all(10.0),
              child:
              Text(account.phone,
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 22, color: grey_dark))
          ),
        ],
      ),
    );


    return new Scaffold(
        appBar: new AppBar(
          leading: new BackButton(),
          title: new Text('Profile'),
          elevation: 0,
          backgroundColor: Colors.black,
        ),
        body: new SingleChildScrollView(
          child: Column(
            children: <Widget>[
              userProfile,
            ],
          ),
        )
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path p = new Path();
    p.lineTo(size.width, 0.0);
    p.lineTo(size.width, size.height * 0.45);
    p.arcToPoint(
      Offset(0.0, size.height * 0.45),
      radius: const Radius.elliptical(50.0, 10.0),
      rotation: 0.0,
    );
    p.lineTo(0.0, 0.0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}