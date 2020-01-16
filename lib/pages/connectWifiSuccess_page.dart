import 'package:flutter/material.dart';

class ConnectWifiSuccess extends StatefulWidget {
  @override
  _ConnectWifiSuccessState createState() => _ConnectWifiSuccessState();
}

class _ConnectWifiSuccessState extends State<ConnectWifiSuccess> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                margin: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFdddddd)),
                    borderRadius: BorderRadius.all(Radius.circular(15.0))),
                child: Text(
                  "3/3 设置成功",
                  style: TextStyle(fontSize: 12.0, color: Colors.green),
                ),
              ),
              Container(
                margin: EdgeInsets.all(20.0),
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(Radius.circular(50.0))),
                child: Icon(
                  Icons.done,
                  size: 52.0,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "操作成功",
                  style: TextStyle(fontSize: 24.0),
                ),
              ),
              Text("设置无线网络成功"),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: RaisedButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                  color: Color(0xFFeeeeee),
                  textColor: Colors.grey,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 80.0),
                    child: Text('返回'),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
