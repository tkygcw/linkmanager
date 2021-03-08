import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:linkmanager/object/merchant.dart';
import 'package:linkmanager/object/url.dart';
import 'package:linkmanager/shareWidget/progress_bar.dart';
import 'package:linkmanager/shareWidget/toast.dart';
import 'package:linkmanager/translation/AppLocalizations.dart';
import 'package:linkmanager/utils/domain.dart';
import 'package:linkmanager/utils/sharePreference.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';

class QrDialog extends StatefulWidget {
  final Url url;

  QrDialog({this.url});

  @override
  _QrDialogState createState() => _QrDialogState();
}

class _QrDialogState extends State<QrDialog> {
  GlobalKey _globalKey = new GlobalKey();

  StreamController refreshStream;
  String domain;
  var logo;
  Color pickerColor = Colors.black;
  Color currentColor = Colors.black;
  int valueHolder = 20;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDomain();
    getLogo();
    refreshStream = StreamController();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: new ThemeData(
        primaryColor: Colors.deepPurple,
      ),
      child: AlertDialog(
          title:
              new Text('${AppLocalizations.of(context).translate('qr_code')}'),
          actions: <Widget>[
            RaisedButton(
              child: Text('${AppLocalizations.of(context).translate('close')}'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            RaisedButton(
              color: Colors.deepPurpleAccent,
              child: Text(
                '${AppLocalizations.of(context).translate('share')}',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                var shareImageSource = await _captureQrCode();
                print(shareImageSource);
                if (shareImageSource != null)
                  await WcFlutterShare.share(
                      sharePopupTitle: 'share',
                      fileName: 'share.png',
                      mimeType: 'image/png',
                      bytesOfFile: shareImageSource);
                else
                  showToast('invalid_qr_code');
              },
            ),
          ],
          content: StreamBuilder(
              stream: refreshStream.stream,
              builder: (context, object) {
                if (object.hasData && object.data.toString().length >= 1) {
                  return mainContent();
                }
                return Container(
                    height: 500, width: 1000, child: CustomProgressBar());
              })),
    );
  }

  Widget mainContent() {
    return Container(
        alignment: Alignment.center,
        height: 500,
        width: 1000,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller:
                    new TextEditingController(text: domain + widget.url.name),
                maxLines: 1,
                textAlign: TextAlign.start,
                maxLengthEnforced: true,
                enabled: false,
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).translate('your_url'),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelStyle: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  border: new OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: new BorderSide(color: Colors.red)),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                alignment: Alignment.center,
                child: RepaintBoundary(
                  key: _globalKey,
                  child: QrImage(
                    data: domain + widget.url.name,
                    version: QrVersions.auto,
                    backgroundColor: Colors.white,
                    foregroundColor: pickerColor,
                    size: 220,
                    gapless: true,
                    embeddedImage: logo != null ? MemoryImage(logo) : null,
                    embeddedImageStyle: QrEmbeddedImageStyle(
                      size: Size(35, 35),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ColorPicker(
                pickerColor: pickerColor,
                onColorChanged: changeColor,
                showLabel: false,
                pickerAreaHeightPercent: 0.3,
              ),
              Slider(
                  value: valueHolder.toDouble(),
                  min: 1,
                  max: 100,
                  divisions: 100,
                  activeColor: Colors.green,
                  inactiveColor: Colors.grey,
                  label: '${valueHolder.round()}',
                  onChanged: (double newValue) {
                    setState(() {
                      valueHolder = newValue.round();
                    });
                  },
                  semanticFormatterCallback: (double newValue) {
                    return '${newValue.round()}';
                  }),
            ],
          ),
        ));
  }

  // ValueChanged<Color> callback
  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  Future<Uint8List> _captureQrCode() async {
    try {
      print('inside');
      RenderRepaintBoundary boundary =
          _globalKey.currentContext.findRenderObject();

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      var pngBytes = byteData.buffer.asUint8List();

//      var bs64 = base64Encode(pngBytes);

      setState(() {});
      return pngBytes;
    } catch (e) {
      return null;
    }
  }

  getLogo() async {
    Map data = await Domain.callApi(Domain.merchant, {
      'logo': '1',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId
              .toString(),
    });

    if (data['status'] == '1') {
      if (data['logo'][0]['logo'] != '')
        logo = base64Decode(base64Data(data['logo'][0]['logo']));
    }
    refreshStream.add('display');
  }

  base64Data(String data) {
    switch (data.length % 4) {
      case 1:
        break;
      case 2:
        data = data + "==";
        break;
      case 3:
        data = data + "=";
        break;
    }
    return data;
  }

  getDomain() async {
    this.domain =
        Merchant.fromJson(await SharePreferences().read("merchant")).domain +
            '/';
  }

  showToast(message) {
    CustomToast(
      '${AppLocalizations.of(context).translate(message)}',
      context,
    ).show();
  }
}
