import 'dart:async';
import 'dart:convert';
import 'package:after_layout/after_layout.dart';
import 'package:bluetooth/components/loadingDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'connectWifiSuccess_page.dart';

class ConnectWifiPage extends StatefulWidget {
  final BluetoothDevice bluetoothDevice;

  // ConnectWifiPage();
  ConnectWifiPage({this.bluetoothDevice});

  @override
  _ConnectWifiPageState createState() => _ConnectWifiPageState();
}

class _ConnectWifiPageState extends State<ConnectWifiPage>
    with SingleTickerProviderStateMixin, AfterLayoutMixin<ConnectWifiPage> {
  bool connectSate = false;

  Animation wifiAnimation;
  AnimationController wifiAnimationController;

  TextEditingController _wifiNameController = TextEditingController();
  TextEditingController _wifiPasswordController = TextEditingController();
  bool wifiStatus = false;
  bool deviceState = false;
  num bleSendSequence = 0;
  var characteristic;

  Timer timer;
  Duration duration = new Duration(seconds: 10);
  Timer timerOut;

  //  初始化页面
  @override
  void initState() {
    super.initState();
    wifiAnimationController =
        new AnimationController(vsync: this, duration: Duration(seconds: 1));
    wifiAnimation = new CurvedAnimation(
        parent: wifiAnimationController, curve: Curves.elasticOut);
  }

  @override
  void afterFirstLayout(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new LoadingDialog(
            text: "蓝牙连接中",
          );
        });

    _initConnect();
  }

  @override
  void dispose() {
    super.dispose();
    print('connectWifi dispose');
    wifiAnimationController?.dispose();
    widget.bluetoothDevice?.disconnect();
    timer?.cancel();
    timerOut?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "blue",
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
                      child: Text("2/3 连接智能耳机",
                          style:
                              TextStyle(color: Colors.green, fontSize: 12.0)),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        "选择需要连接的网络",
                        style: TextStyle(color: Colors.black, fontSize: 18.0),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: Text("耳机将会连接到您输入的WIFI",
                          style:
                              TextStyle(color: Colors.black, fontSize: 14.0)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5.0),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(6.0)),
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(10.0),
                            margin: EdgeInsets.only(bottom: 5.0),
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                color: Color(0xffedeef0)),
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.wifi, color: Colors.grey),
                                Expanded(
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: TextField(
                                          controller: _wifiNameController,
                                          style: TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.grey),
                                          decoration: InputDecoration(
                                              isDense: true,
                                              hintText: "wifi名称",
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 10),
                                              hintStyle: TextStyle(
                                                  fontSize: 12.0,
                                                  color: Colors.grey),
                                              border: InputBorder.none),
                                        ))),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 5.0),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                    color: Colors.green,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "切换网络",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12.0),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          // wifiName wifipassword show content
                          Container(
                            padding: EdgeInsets.all(10.0),
                            margin: EdgeInsets.symmetric(vertical: 5.0),
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                color: Color(0xffedeef0)),
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.lock_outline, color: Colors.grey),
                                Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: TextField(
                                          controller: _wifiPasswordController,
                                          style: TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.grey),
                                          decoration: InputDecoration(
                                              isDense: true,
                                              hintText: "请输入密码",
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 10),
                                              hintStyle: TextStyle(
                                                  fontSize: 12.0,
                                                  color: Colors.grey),
                                              border: InputBorder.none),
                                        ))),
                                Icon(Icons.remove_red_eye, color: Colors.grey)
                              ],
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: RaisedButton(
                                  onPressed: _connect,
                                  color: Colors.green,
                                  textColor: Colors.white,
                                  splashColor: Colors.white10,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(20.0)),
                                  child: Text('开始连接'),
                                ),
                              )
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  this.setState(() {
                                    wifiStatus = !wifiStatus;
                                  });
                                },
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 5.0),
                                  child: wifiStatus
                                      ? Icon(
                                          Icons.radio_button_checked,
                                          color: Colors.grey,
                                        )
                                      : Icon(
                                          Icons.radio_button_unchecked,
                                          color: Colors.grey,
                                        ),
                                ),
                              ),
                              Text(
                                "我的wifi已设为隐藏网络(未开启无线广播)",
                                style: TextStyle(
                                    fontSize: 10.0, color: Colors.grey),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    Expanded(child: Container()),
                    InkWell(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.lightbulb_outline, color: Colors.grey),
                          Text("哪些网络不支持", style: TextStyle(color: Colors.grey))
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Positioned(
                top: wifiAnimation.value * 80 - 50,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          wifiAnimationController.animateTo(0);
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
                              "请打开WIFI",
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

  _initConnect() async {
    BluetoothDevice bluetoothDevice = widget.bluetoothDevice;
    var readCharacteristic;
    var subscription;

    subscription = bluetoothDevice.state.listen((data) {
      if (data == BluetoothDeviceState.connected) {
        Future.delayed(Duration(seconds: 1), () {
          Navigator.of(context).pop();
        });
        subscription.cancel();
      }
    });

    await bluetoothDevice.connect();
    List<BluetoothService> services = await bluetoothDevice.discoverServices();

    for (BluetoothService service in services) {
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        if (c.properties.write) {
          characteristic = c;
        }

        if (c.properties.read) {
          readCharacteristic = c;
        }
      }
    }

    if (!readCharacteristic.isNotifying) {
      await readCharacteristic.setNotifyValue(true);
    }

    List<int> resVal = new List();

    readCharacteristic.value.listen((value) {

      if (value.length < 4) return;
      if (value[1] == 20) {
        value.sublist(4, value.length).forEach((v) {
          resVal.add(v);
        });

        return;
      }

      if (value[1] == 4) {
        value.sublist(4).forEach((v) {
          resVal.add(v);
        });

        bool resStatus =
            listContainList(resVal, utf8.encode(_wifiNameController.text));
        if (resStatus) {
          print('连接成功');
          widget.bluetoothDevice?.disconnect();
          timer?.cancel();
          timerOut?.cancel();
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacement(new MaterialPageRoute(
              builder: (context) => ConnectWifiSuccess()));
        }

        resVal.clear();
      }
    });
  }

  _connect() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new LoadingDialog(
            text: "配网中...",
          );
        });
    await sendName();
    await sendPassword();

    timer?.cancel();
    timer = new Timer.periodic(Duration(seconds: 1), (timer) {
      checkConnect();
    });
    
    timerOut = new Timer(duration, () {
      timer?.cancel();
      Navigator.of(context).pop();
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('提示'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('网络连接超时')
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('关闭'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    });

    print("_connect");
  }

  Future sendCMD(BluetoothCharacteristic characteristic, cmd, subCMD,
      frameControl, payload, bleSendSequence) async {
    var lsb = ((subCMD & 0x3f) << 2) | (cmd & 0x03);
    var u8array = new List<int>();
    u8array.add(lsb);
    u8array.add(frameControl);
    u8array.add(bleSendSequence);
    u8array.add(payload.length);

    for (int i = 0; i < payload.length; i++) {
      u8array.add(payload[i]);
    }

    await characteristic.write(u8array);
  }

  Future sendName() async {
    String name = _wifiNameController.text;

    List<int> nameArr = utf8.encode(name);
    await sendCMD(characteristic, 0x01, 0x02, 0, nameArr, bleSendSequence);
    bleSendSequence++;
  }

  Future sendPassword() async {
    String password = _wifiPasswordController.text;

    List<int> passwordArr = utf8.encode(password);
    // 发送密码
    await sendCMD(characteristic, 0x01, 0x03, 0, passwordArr, bleSendSequence);
    bleSendSequence++;
    // 发送连接指令
    await sendCMD(characteristic, 0x00, 0x03, 0, '', bleSendSequence);
    bleSendSequence++;
  }

//  检查连接状态
  checkConnect() {
    sendCMD(characteristic, 0x00, 0x05, 0, '', bleSendSequence);
    bleSendSequence++;
  }

  void showBottomSheet() {
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
                            child: Text("列表中没有启辰智能耳机?",
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
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                "5. 只能耳机的蓝牙名称默认为 “启辰智能耳机-001”, 后续可在用户中心进行设备名称修改",
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

  listContainList(List list, List containList) {
    if (list.length == 0 || containList.length == 0) {
      return false;
    }
    int length = containList.length;
    final firstCode = containList[0];
    List compareList = [];
    bool listContain = false;

    while (!listContain && list.length > length) {
      var index = list.indexOf(firstCode);
      if (index != -1) {
        compareList = list.sublist(index, index + length);
        bool compareResult = true;
        for (var i = 0; i < compareList.length; i++) {
          if (compareList[i] != containList[i]) {
            compareResult = false;
            break;
          }
        }

        if (compareResult) {
          listContain = true;
        } else {
          list = list.sublist(index, index + length);
        }
      } else {
        break;
      }

      
    }

    return listContain;
  }
}
