import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linkmanager/object/merchant.dart';
import 'package:linkmanager/object/url.dart';
import 'package:linkmanager/page/navigationDrawer/navigationDrawer.dart';
import 'package:linkmanager/shareWidget/not_found.dart';
import 'package:linkmanager/shareWidget/progress_bar.dart';
import 'package:linkmanager/translation/AppLocalizations.dart';
import 'package:linkmanager/utils/domain.dart';
import 'package:linkmanager/utils/sharePreference.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';

class QRCodePage extends StatefulWidget {
  static const String routeName = '/qrcode';
  final Url url;

  QRCodePage({this.url});

  @override
  _QRCodePageState createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  final key = new GlobalKey<ScaffoldState>();
  GlobalKey _qRCodeKey = new GlobalKey();
  String urlName;
  String domain;
  List<Url> urlList = [];

  StreamController refreshStream;
  var logo;
  Color pickerColor = Colors.black;
  Color currentColor = Colors.black;
  int valueHolder = 25;

  /*
     * network checking purpose
     * */
  var connectivity;
  bool networkConnection = true;

  @override
  void initState() {
    super.initState();
    if (widget.url != null) this.urlName = widget.url.name;
    refreshStream = StreamController();
    networkDetector();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: key,
        appBar: AppBar(
          centerTitle: false,
          elevation: 2,
          title: Text(AppLocalizations.of(context).translate('qr_code'),
              textAlign: TextAlign.left,
              style: GoogleFonts.aBeeZee(
                textStyle: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 20),
              )),
          actions: <Widget>[],
        ),
        drawer: widget.url == null ? CustomNavigationDrawer() : null,
        body: StreamBuilder(
            stream: refreshStream.stream,
            builder: (context, object) {
              print(object.data);
              if (object.hasData && object.data.toString().length >= 1) {
                if (object.data == 'display')
                  return mainContent();
                else
                  return notFound();
              }
              return Container(height: 500, width: 1000, child: CustomProgressBar());
            }));
  }

  Widget mainContent() {
    return networkConnection && urlName != null
        ? SingleChildScrollView(
            child: Column(children: [urlSelection(), qrCodeLayout()]),
          )
        : notFound();
  }

  Widget qrCodeLayout() {
    return Card(
      margin: EdgeInsets.all(15),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).translate('logo_size'),
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
            Text(
              AppLocalizations.of(context).translate('logo_size_description'),
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
            ),
            Slider(
                value: valueHolder.toDouble(),
                min: 10,
                max: 50,
                divisions: 100,
                activeColor: Colors.deepPurple,
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
            SizedBox(
              height: 5,
            ),
            Container(
              alignment: Alignment.center,
              child: RepaintBoundary(
                key: _qRCodeKey,
                child: QrImage(
                  data: '$domain/$urlName',
                  version: QrVersions.auto,
                  backgroundColor: Colors.white,
                  foregroundColor: pickerColor,
                  size: 220,
                  gapless: true,
                  embeddedImage: logo != null ? MemoryImage(logo) : null,
                  embeddedImageStyle: QrEmbeddedImageStyle(
                    size: Size(valueHolder.toDouble(), valueHolder.toDouble()),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              AppLocalizations.of(context).translate('qr_code_color'),
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 5,
            ),
            ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: changeColor,
              labelTypes: [null],
              pickerAreaHeightPercent: 0.4,
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              height: 50.0,
              child: ElevatedButton.icon(
                onPressed: () {
                  shareQrCode();
                },
                icon: Icon(
                  Icons.share,
                  color: Colors.white,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                ),
                label: Text(
                  '${AppLocalizations.of(context).translate('share_qr_code')}',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget urlSelection() {
    return Card(
        margin: EdgeInsets.all(5),
        elevation: 5,
        child: Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context).translate('select_url'),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Container(
                height: 50,
                child: DropdownButton(
                    value: urlName,
                    isExpanded: true,
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                    items: [
                      for (int i = 0; i < urlList.length; i++)
                        DropdownMenuItem(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  urlList[i].label,
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                      '$domain/${urlList[i].name}',
                                      style: TextStyle(fontSize: 14, color: Colors.blue),
                                    ))
                              ],
                            ),
                          ),
                          value: urlList[i].name,
                        )
                    ],
                    onChanged: (urlName) async {
                      this.urlName = urlName;
                      print(urlName);
                      refreshStream.add('display');
                    }),
              ),
            ],
          ),
        ));
  }

  shareQrCode() async {
    var shareImageSource = await _captureQrCode();
    print(shareImageSource);
    if (shareImageSource != null)
      await WcFlutterShare.share(sharePopupTitle: 'share', fileName: 'share.png', mimeType: 'image/png', bytesOfFile: shareImageSource);
    else
      showSnackBar('invalid_qr_code', 'close');
  }

  // ValueChanged<Color> callback
  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  Future<Uint8List> _captureQrCode() async {
    try {
      print('inside');
      RenderRepaintBoundary boundary = _qRCodeKey.currentContext.findRenderObject();

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      var pngBytes = byteData.buffer.asUint8List();

//      var bs64 = base64Encode(pngBytes);

      setState(() {});
      return pngBytes;
    } catch (e) {
      return null;
    }
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

  Future fetchData() async {
    urlList.clear();
    /*
    * fetch domain
    * */
    this.domain = Merchant.fromJson(await SharePreferences().read("merchant")).domain;
    /*
    * fetch logo
    * */
    Map logoData = await Domain.callApi(Domain.merchant, {
      'logo': '1',
      'merchant_id': Merchant.fromJson(await SharePreferences().read("merchant")).merchantId.toString(),
    });

    if (logoData['status'] == '1') {
      if (logoData['logo'][0]['logo'] != '') logo = base64Decode(base64Data(logoData['logo'][0]['logo']));
    }

    /*
    * fetch url
    * */
    Map data = await Domain.callApi(
        Domain.url, {'read': '1', 'merchant_id': Merchant.fromJson(await SharePreferences().read("merchant")).merchantId.toString()});
    print(data);
    if (data['status'] == '1') {
      List responseJson = data['url'];
      urlList.addAll(responseJson.map((e) => Url.fromJson(e)));
    } else if (data['status'] == '2') {
      refreshStream.add('not_found');
      return;
    } else
      showSnackBar('something_went_wrong', 'close');

    //set default as first url
    if (urlName == null && urlList.length > 0) {
      urlName = urlList[0].name;
    }
    refreshStream.add('display');
  }

  Widget notFound() {
    return NotFound(
        title: networkConnection
            ? '${AppLocalizations.of(context).translate('no_url')}'
            : '${AppLocalizations.of(context).translate('no_network_found')}',
        description: networkConnection
            ? '${AppLocalizations.of(context).translate('no_qr_code_description')}'
            : '${AppLocalizations.of(context).translate('no_network_found_description')}',
        showButton: true,
        refresh: () async {
          await fetchData();
          setState(() {});
        },
        button: '${AppLocalizations.of(context).translate('retry')}',
        drawable: networkConnection ? 'drawable/no_qr_code.png' : 'drawable/no_signal.png');
  }

  networkDetector() {
    connectivity = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        networkConnection = (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi);
        fetchData();
      });
    });
  }

  showSnackBar(preMessage, button) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
        content: new Text(AppLocalizations.of(context).translate(preMessage)),
        action: SnackBarAction(
          label: AppLocalizations.of(context).translate(button),
          onPressed: () {
            setState(() {});
            // Some code to undo the change.
          },
        )));
  }
}
