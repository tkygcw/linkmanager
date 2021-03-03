import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linkmanager/object/merchant.dart';
import 'package:linkmanager/translation/AppLocalizations.dart';
import 'package:linkmanager/utils/domain.dart';
import 'package:linkmanager/utils/sharePreference.dart';

import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class BranchSettingPage extends StatefulWidget {
  @override
  _BranchSettingPageState createState() => _BranchSettingPageState();
}

class _BranchSettingPageState extends State<BranchSettingPage> {
  Merchant merchant;
  final key = new GlobalKey<ScaffoldState>();

  File _image;
  ImageProvider provider;

  String imageCode = '-1';
  String imageName;
  String extension = '';
  final picker = ImagePicker();
  var compressedFileSource;

  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchMerchant();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: key,
        appBar: AppBar(
          centerTitle: false,
          elevation: 2,
          title: Text(AppLocalizations.of(context).translate('branch_info'),
              textAlign: TextAlign.left,
              style: GoogleFonts.aBeeZee(
                textStyle: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              )),
          actions: <Widget>[],
        ),
        body: mainContent());
  }

  Future fetchMerchant() async {
    Map data = await Domain.callApi(Domain.merchant, {
      'profile': '1',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId
              .toString()
    });
    if (data['status'] == '1') {
      merchant = Merchant.fromJson(data['merchant'][0]);
      description.text = merchant.description;
      title.text = merchant.title;
    } else {
      showSnackBar('something_went_wrong', 'close');
    }

    setState(() {});
  }

  Widget mainContent() {
    return Theme(
      data: new ThemeData(
        primaryColor: Colors.purple,
      ),
      child: SingleChildScrollView(
        child: Card(
            margin: EdgeInsets.all(15),
            elevation: 5,
            child: Container(
                height: 500,
                margin: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)
                          .translate('branch_info_description'),
                      style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextField(
                        controller: title,
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.title),
                          labelText:
                              '${AppLocalizations.of(context).translate('title')}',
                          labelStyle:
                              TextStyle(fontSize: 16, color: Colors.blueGrey),
                          hintText:
                              '${AppLocalizations.of(context).translate('title')}',
                          border: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.teal)),
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                        controller: description,
                        textAlign: TextAlign.start,
                        maxLines: 4,
                        minLines: 2,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.description),
                          labelText:
                              '${AppLocalizations.of(context).translate('description')}',
                          labelStyle:
                              TextStyle(fontSize: 16, color: Colors.blueGrey),
                          hintText:
                              '${AppLocalizations.of(context).translate('description')}',
                          border: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.teal)),
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      AppLocalizations.of(context).translate('select_logo'),
                      style: TextStyle(color: Colors.blueGrey, fontSize: 14),
                    ),
                    imageWidget(),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 50.0,
                      child: RaisedButton.icon(
                        onPressed: () {
                          if (title.text.isNotEmpty)
                            updateBranchDescription();
                          else
                            showSnackBar('missing_input', 'close');
                        },
                        icon: Icon(
                          Icons.message,
                          color: Colors.white,
                        ),
                        color: Colors.deepPurpleAccent,
                        label: Text(
                          '${AppLocalizations.of(context).translate('update')}',
                          style: TextStyle(color: Colors.white),
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                      ),
                    ),
                  ],
                ))),
      ),
    );
  }

  Widget imageWidget() {
    return InkWell(
        onTap: () => _showSelectionDialog(context),
        child: Container(
          alignment: Alignment.center,
          child: Image.memory(
            compressedFileSource != null ? compressedFileSource : null,
            height: 150,
          ),
        ));
  }

  Future updateBranchDescription() async {
    Map data = await Domain.callApi(Domain.merchant, {
      'update_branch': '1',
      'title': title.text,
      'description': description.text,
      'logo': compressedFileSource.toString(),
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId
              .toString()
    });
    if (data['status'] == '1') {
      showSnackBar('update_success', 'close');
      setState(() {});
    } else if (data['status'] == '3') {
      showSnackBar('current_pass_not_match', 'close');
    } else {
      showSnackBar('something_went_wrong', 'close');
    }
  }

  showSnackBar(preMessage, button) {
    key.currentState.showSnackBar(new SnackBar(
        content: new Text(AppLocalizations.of(context).translate(preMessage)),
        action: SnackBarAction(
          label: AppLocalizations.of(context).translate(button),
          onPressed: () {
            setState(() {});
            // Some code to undo the change.
          },
        )));
  }

  /*-----------------------------------------photo compress-------------------------------------------*/
  Future<void> _showSelectionDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(
                  "${AppLocalizations.of(context).translate('take_photo_from_where')}"),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 40,
                    child: RaisedButton.icon(
                      label: Text(
                          '${AppLocalizations.of(context).translate('gallery')}',
                          style: TextStyle(color: Colors.white)),
                      color: Colors.orangeAccent,
                      icon: Icon(
                        Icons.perm_media,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        getImage(false);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: RaisedButton.icon(
                      label: Text(
                        '${AppLocalizations.of(context).translate('camera')}',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.blueAccent,
                      icon: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        getImage(true);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ));
        });
  }

  /*
  * compress purpose
  * */
  Future getImage(isCamera) async {
    final pickedFile = await picker.getImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery);
    _image = File(pickedFile.path);

    compressFileMethod();
  }

  void compressFileMethod() async {
    await Future.delayed(Duration(milliseconds: 300));

    Uint8List bytes = _image.readAsBytesSync();
    final ByteData data = ByteData.view(bytes.buffer);

    final dir = await path_provider.getTemporaryDirectory();

    File file = createFile("${dir.absolute.path}/test.png");
    file.writeAsBytesSync(data.buffer.asUint8List());
    compressedFileSource = await compressFile(file);
    setState(() {});
  }

  File createFile(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    return file;
  }

  Future<Uint8List> compressFile(File file) async {
    final result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: countQuality(file.lengthSync()),
    );
    return result;
  }

  countQuality(int quality) {
    if (quality <= 100)
      return 60;
    else if (quality > 100 && quality < 500)
      return 25;
    else
      return 20;
  }
}
