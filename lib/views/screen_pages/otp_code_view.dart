import 'package:flutter/material.dart';
// import 'package:sms_autofill/sms_autofill.dart';
import 'package:venturiautospurghi/views/widgets/platform_otpinputfield.dart';

class OtpCode extends StatefulWidget {
  OtpCode(this.verifier);

  final Function verifier;

  @override
  _OtpCodeState createState() => _OtpCodeState();
}

class _OtpCodeState extends State<OtpCode> {
  TextEditingController _pinEditingController = TextEditingController();

  @override
  void initState() {
    _pinEditingController.addListener(() {
      if(_pinEditingController.text.length==6)
        widget.verifier(_pinEditingController.text);
    });
    super.initState();
  }
  
  @override
  void dispose() {
    // SmsAutoFill().unregisterListener();
    _pinEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return new Scaffold(
        appBar: new AppBar(
          leading: new BackButton(),
          title: new Text('OTP Code'),
          elevation: 0,
          backgroundColor: Colors.black,
        ),
        body: new SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // PlatformOtpInputField.show(
              //   controller: _pinEditingController
              // ),
            ],
          ),
        )
    );
  }
}