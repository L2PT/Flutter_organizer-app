import 'package:flutter/material.dart';
//import 'package:flutter_web/material.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';
import 'package:venturiautospurghi/utils/theme.dart';


class ProfilePage extends StatefulWidget {
  @override
  State createState() => new _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Size deviceSize;

  void _navigateToCalendarView() {
    Navigator.of(context).pushNamedAndRemoveUntil(Constants.dailyCalendarRoute,
            (Route<dynamic> route) => false);
  }

  Widget profileHeader() => Container(
    height: deviceSize.height / 4,
    width: double.infinity,
    color: dark,
    child: CustomPaint(
      painter: PathPainter(),
      child:Padding(
        padding: const EdgeInsets.all(10.0),
        child: FittedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.0),
                    border: Border.all(width: 2.0, color: Colors.white)),
                child: CircleAvatar(
                  radius: 40.0,
                  backgroundImage: NetworkImage(
                      "https://i.mmo.cm/is/image/mmoimg/bigview/john-doe-foam-latex-mask--mw-117345-1.jpg"),
                ),
              ),
              Text("Francesco degli Esposti",style: title),
              Text("Bologna 01-01-1997",style: subtitle)
            ],
          ),
        ),
      ),
    ),
  );

//Ho provato ListTile.divideTiles ma veniva male quindi ho usato i bordi per deparare
  Widget options() => Container(
      height: deviceSize.height / 4*3,
      padding: const EdgeInsets.only(top: 10.0),
      child: ListView(
        children: <Widget>[
              Container(
                  decoration: BoxDecoration(
                      color: dark,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5)),
                  ),
                  child: new ListTile(leading: const Icon(Icons.remove_red_eye, color: white),
                    title: Text('Incarichi non letti', style: subtitle_rev),
                    onTap: (){},
                  )
              ),Container(
                  decoration: BoxDecoration(
                      color: dark,
                      border: Border(
                        top: BorderSide(width: 1.0, color: grey_dark),
                        bottom: BorderSide(width: 1.0, color: grey_dark),
                      ),
                  ),
                  child: new ListTile(leading: const Icon(Icons.delete, color: white),
                    title: Text('Incarichi eliminati', style: subtitle_rev),
                    onTap: (){},
                  )
              ),Container(
                  decoration: BoxDecoration(
                    color: dark,
                    border: Border(
                      bottom: BorderSide(width: 1.0, color: grey_dark),
                    ),
                  ),
                  child: new ListTile(leading: const Icon(Icons.work, color: white),
                    title: Text('Operatori', style: subtitle_rev),
                    onTap: (){},
                  )
              ),Container(
                  decoration: BoxDecoration(
                      color: dark,
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5),bottomRight: Radius.circular(5))
                  ),
                  child: new ListTile(leading: const Icon(Icons.settings, color: white),
                    title: Text('Impostazioni', style: subtitle_rev),
                    onTap: (){},
                  )
              )
            ],
      )
  );

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    return new SingleChildScrollView(
      child: Column(
        children: <Widget>[
          profileHeader(),
          Container(
            color: whitebackground,
            padding: const EdgeInsets.all(10.0),
            child:Column(
              children:<Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Area Personale",style: title, textAlign: TextAlign.left)
                ),
                options()
              ]
            ),
          ),

        ],
      ),
    );
  }
}




class PathPainter extends CustomPainter {
  int span = 50; //HANDLE
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = whitebackground
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0,size.height-span);
    path.quadraticBezierTo(size.width / 2, 0, size.width, size.height-span);
    canvas.drawPath(path, paint);
    canvas.drawRect(Rect.fromLTRB(0, size.height-span, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}