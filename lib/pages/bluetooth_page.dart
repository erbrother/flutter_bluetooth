import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'connectWifi_page.dart';
// import 'package:flutter_qc/page/connectWifi_page.dart';

const String GUID = '0000FFFF-0000-1000-8000-00805F9B34FB';

class BluetoothPage extends StatefulWidget {
  @override
  _BlueToothPageState createState() => _BlueToothPageState();
}

class _BlueToothPageState extends State<BluetoothPage>
    with TickerProviderStateMixin {
//  蓝牙提示动画
  Animation<double> _bluetoothAnimation;
  AnimationController _bluetoothAnimationController;

//  刷新动画
  Animation<double> _bluetoothRefreshAnimation;
  AnimationController _bluetoothRefreshAnimationController;

  bool refresh = false;

//  key
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<AnimatedListState> _bluetoothListKey = GlobalKey();

//  蓝牙相关api
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothCharacteristic characteristic;
  BluetoothCharacteristic readCharacteristic;
  StreamSubscription _subscription;
  int bleSendSequence = 0;

//  蓝牙设备列表
  List<ScanResult> bluetoothList = new List();

//  连接的蓝牙设备
  BluetoothDevice bluetoothDevice;

  //  初始化页面
  @override
  void initState() {
    super.initState();
    _bluetoothAnimationController = new AnimationController(
        duration: new Duration(seconds: 1), vsync: this);
    _bluetoothAnimation = new CurvedAnimation(
        parent: _bluetoothAnimationController, curve: Curves.elasticOut);

    _bluetoothRefreshAnimationController = new AnimationController(
        duration: new Duration(seconds: 1), vsync: this);
    _bluetoothRefreshAnimation = new CurvedAnimation(
        parent: _bluetoothRefreshAnimationController, curve: Curves.linear);

    _bluetoothAnimation.addListener(() => this.setState(() {}));
    _bluetoothRefreshAnimation.addListener(() => this.setState(() {}));

//    _initBluetooth();
    _initFlutterBluetooth();
  }

  @override
  void dispose() {
    bleSendSequence = 0;
    _bluetoothAnimationController?.dispose();
    _bluetoothRefreshAnimationController?.dispose();
    flutterBlue.stopScan();
    bluetoothDevice?.disconnect();
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "blue",
      child: Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: 15.0),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color(0xffedeef0), Color(0xffe6e7e9)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter)),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                      child: Text("1/3 连接智能耳机",
                          style:
                              TextStyle(color: Colors.green, fontSize: 12.0)),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        "连接准备添加的设备",
                        style: TextStyle(color: Colors.black, fontSize: 18.0),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: Text("请打开手机蓝牙",
                          style:
                              TextStyle(color: Colors.black, fontSize: 14.0)),
                    ),
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15.0),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Transform.rotate(
                              angle: _bluetoothRefreshAnimation.value * 2 * pi -
                                  pi / 2,
                              child: refresh
                                  ? Icon(Icons.refresh, color: Colors.grey)
                                  : Container(),
                            ),
                          ),
                          Expanded(
                              child: refresh
                                  ? Text("正在搜索设备中...",
                                      style: TextStyle(color: Colors.grey))
                                  : Text("已发现的智能设备",
                                      style: TextStyle(color: Colors.grey))),
                          Ink(
                            child: InkWell(
                              onTap: _refreshBluetooth,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(14.0))),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 5.0),
                                child: Text("刷新列表",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5.0),
                    ),
                    new Expanded(
                        child: bluetoothList.length == 0 && refresh == false
                            ? noContent()
                            : bluetoothListView()),
                  ],
                ),
              ),
              Positioned(
                top: _bluetoothAnimation.value * 80 - 50,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          _bluetoothAnimationController.animateTo(0);
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 12.0),
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              "请打开蓝牙",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget noContent() {
    return Container(
      margin: EdgeInsets.only(top: 25.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image(
              width: 150,
              height: 150,
              fit: BoxFit.cover,
              image: AssetImage('lib/images/bluetooth.png'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("没有发现蓝牙设备",
                style: TextStyle(
                    color: Colors.grey, fontSize: 16.0, letterSpacing: 3.0)),
          ),
          Text(
            "请刷新列表",
            style: TextStyle(color: Colors.grey),
          ),
          Expanded(child: Container()),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.help_outline, color: Colors.grey, size: 14.0),
              Padding(
                padding: EdgeInsets.all(2.0),
              ),
              InkWell(
                onTap: showBottomSheet,
                child: Text("列表中没有智能蓝牙设备",
                    style: TextStyle(color: Colors.grey, fontSize: 12.0)),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget bluetoothListView() {
    return AnimatedList(
        key: _bluetoothListKey,
        padding: const EdgeInsets.all(8),
        initialItemCount: bluetoothList.length,
        physics: BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index, animation) {
          return FadeTransition(
            opacity: animation,
            child: InkWell(
              onTap: () => connectDevice(index),
              child: Container(
                  margin: EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.withOpacity(0.5)),
                      borderRadius: BorderRadius.all(Radius.circular(6.0))),
                  height: 50,
                  child: Center(
                      child: bluetoothList[index].device.name == null ||
                              bluetoothList[index].device.name == ""
                          ? Text("未知设备")
                          : Text('${bluetoothList[index].device.name}'))),
            ),
          );
        });
  }

  _initFlutterBluetooth() async {
    flutterBlue.state.listen((BluetoothState state) {
      if (state == BluetoothState.off) {
        _bluetoothAnimationController.animateTo(1);
      }

      if (state == BluetoothState.on) {
        _bluetoothAnimationController.animateTo(0);
      }
    });
    _getBluetoothList();
  }

//  获取蓝牙设备列表
  _getBluetoothList() async {
    if (!await flutterBlue.isOn)
      return _bluetoothAnimationController.animateTo(1);

    // Listen to scan results
    setState(() {
      refresh = true;
    });
    _bluetoothRefreshAnimationController.repeat();

    _subscription = flutterBlue.scan(
        timeout: Duration(seconds: 4),
        withServices: [
          Guid(GUID)
        ]).listen((scanResult) {
      // do something with scan result
      num index = bluetoothList.indexOf(scanResult);
      if (index == -1) addBluetoothListItem(scanResult);
    });
    _subscription.onDone(handleDone);
  }

//  刷新蓝牙按钮
  Future _refreshBluetooth() async {
    if (refresh == true) return;
    if (!await flutterBlue.isOn) {
      _bluetoothAnimationController.animateTo(1);
      return;
    }
    _clearAllItems();
    _getBluetoothList();
  }

//  处理流关闭事件
  handleDone() {
    _bluetoothRefreshAnimationController.stop();
    setState(() {
      refresh = false;
    });
  }

//  连接蓝牙设备
  connectDevice(int index) async {
    bluetoothDevice = bluetoothList[index].device;

    Navigator.of(context).push(new MaterialPageRoute(
        builder: (BuildContext context) =>
            new ConnectWifiPage(bluetoothDevice: bluetoothDevice)));
  }

  showBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            color: Colors.black.withOpacity(0.55),
            height: 300,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(bottom: 5.0),
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("列表中没有蓝牙设备?",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color: Colors.black)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("1. 手机离设备近一些",
                                style: TextStyle(
                                    fontSize: 12.0, color: Colors.black)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("2. 请确保您的设备处于开机状态",
                                style: TextStyle(
                                    fontSize: 12.0, color: Colors.black)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("3. 请确保您的手机已经开启蓝牙",
                                style: TextStyle(
                                    fontSize: 12.0, color: Colors.black)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("4. 点击刷 “刷新列表” 按钮可以重新搜索设备",
                                style: TextStyle(
                                    fontSize: 12.0, color: Colors.black)),
                          ),
                        ]),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      child: Center(
                        child: Text("我知道了",
                            style:
                                TextStyle(color: Colors.green, fontSize: 16.0)),
                      ),
                    ),
                  )
                ]),
          );
        });
  }

//  添加item
  addBluetoothListItem(ScanResult r) {
    int index = bluetoothList.length;

    bluetoothList.add(r);
    _bluetoothListKey.currentState
        .insertItem(index, duration: Duration(milliseconds: 500));
  }

//清空列表
  _clearAllItems() {
    for (var i = 0; i <= bluetoothList.length - 1; i++) {
      _bluetoothListKey.currentState.removeItem(0,
          (BuildContext context, Animation<double> animation) {
        return Container();
      });
    }
    bluetoothList.clear();
  }
}
