import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linkmanager/object/merchant.dart';
import 'package:linkmanager/shareWidget/progress_bar.dart';
import 'package:linkmanager/translation/AppLocalizations.dart';
import 'package:linkmanager/utils/domain.dart';
import 'package:linkmanager/utils/sharePreference.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Merchant merchant;
  int allowBranch = 0;

  final key = new GlobalKey<ScaffoldState>();
  StreamController controller = StreamController();

  File _image;
  var imagePath;
  ImageProvider provider;

  final picker = ImagePicker();
  var compressedFileSource;

  String prefix;
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController domain = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();

  Color pickerColor = Colors.black;
  Color currentColor = Colors.black;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPreData();
    fetchMerchant();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: key,
        appBar: AppBar(
          centerTitle: false,
          elevation: 2,
          title: Text(AppLocalizations.of(context).translate('profile'),
              textAlign: TextAlign.left,
              style: GoogleFonts.aBeeZee(
                textStyle: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 20),
              )),
          actions: <Widget>[],
        ),
        body: StreamBuilder(
            stream: controller.stream,
            builder: (context, object) {
              if (object.data == 'display') {
                return mainContent();
              }
              return CustomProgressBar();
            }));
  }

  Future fetchMerchant() async {
    Map data = await Domain.callApi(
        Domain.merchant, {'profile': '1', 'merchant_id': Merchant.fromJson(await SharePreferences().read("merchant")).merchantId.toString()});
    if (data['status'] == '1') {
      merchant = Merchant.fromJson(data['merchant'][0]);
      name.text = merchant.name;
      email.text = merchant.email;
      domain.text = merchant.domain;
      phone.text = merchant.phone;
      prefix = merchant.phonePrefix;

      description.text = merchant.description;
      title.text = merchant.title;
      pickerColor = _colorFromHex(merchant.backgroundColor);

      if (merchant.logo.isNotEmpty) compressedFileSource = base64Decode(base64Data(merchant.logo));
    } else {
      showSnackBar('something_went_wrong', 'close');
    }
    controller.add('display');
  }

  Widget mainContent() {
    return SingleChildScrollView(
      child: Theme(
        data: new ThemeData(
          primaryColor: Colors.purple,
        ),
        child: Column(
          children: [profileSetting(), branchSetting()],
        ),
      ),
    );
  }

  Widget profileSetting() {
    return Card(
      margin: EdgeInsets.all(15),
      elevation: 5,
      child: Container(
        margin: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).translate('profile'),
              style: TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20,
            ),
            imageWidget(),
            SizedBox(
              height: 20,
            ),
            TextField(
                keyboardType: TextInputType.text,
                controller: name,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  labelText: '${AppLocalizations.of(context).translate('username')}',
                  labelStyle: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  hintText: '${AppLocalizations.of(context).translate('username')}',
                  border: new OutlineInputBorder(borderSide: new BorderSide(color: Colors.teal)),
                )),
            SizedBox(
              height: 10,
            ),
            TextField(
                controller: email,
                textAlign: TextAlign.start,
                enabled: false,
                style: TextStyle(color: Colors.black54),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  labelText: '${AppLocalizations.of(context).translate('email')}',
                  labelStyle: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  hintText: '${AppLocalizations.of(context).translate('email')}',
                  border: new OutlineInputBorder(borderSide: new BorderSide(color: Colors.teal)),
                )),
            SizedBox(
              height: 10,
            ),
            TextField(
                controller: domain,
                textAlign: TextAlign.start,
                enabled: false,
                style: TextStyle(color: Colors.black54),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.link),
                  labelText: '${AppLocalizations.of(context).translate('domain')}',
                  labelStyle: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  hintText: '${AppLocalizations.of(context).translate('domain')}',
                  border: new OutlineInputBorder(borderSide: new BorderSide(color: Colors.teal)),
                )),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
                          ),
                    ),
                    child: CountryCodePicker(
                        onChanged: (country) => prefix = country.dialCode,
                        // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                        initialSelection: prefix,
                        favorite: ['+60'],
                        comparator: (a, b) => b.name.compareTo(a.name),
                        //Get the country information relevant to the initial selection
                        onInit: (code) => prefix = code.dialCode),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 2,
                  child: TextField(
                      controller: phone,
                      keyboardType: TextInputType.phone,
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        labelText: '${AppLocalizations.of(context).translate('phone')}',
                        labelStyle: TextStyle(fontSize: 16, color: Colors.blueGrey),
                        hintText: '${AppLocalizations.of(context).translate('phone_hint')}',
                        border: new OutlineInputBorder(borderSide: new BorderSide(color: Colors.teal)),
                      )),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              height: 50.0,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (name.text.isNotEmpty && phone.text.isNotEmpty)
                    updateProfile();
                  else
                    showSnackBar('missing_input', 'close');
                },
                icon: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                ),
                label: Text(
                  '${AppLocalizations.of(context).translate('update_profile')}',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget branchSetting() {
    return Visibility(
      visible: allowBranch == 1,
      child: Card(
          margin: EdgeInsets.all(15),
          elevation: 5,
          child: Container(
              margin: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context).translate('branch_setting'),
                              style: TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              AppLocalizations.of(context).translate('branch_info_description'),
                              style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                            onPressed: preview,
                            child: Text(
                              AppLocalizations.of(context).translate('preview'),
                              style: TextStyle(fontSize: 12, color: Colors.deepPurpleAccent),
                            )),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextField(
                      controller: title,
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.title),
                        labelText: '${AppLocalizations.of(context).translate('title')}',
                        labelStyle: TextStyle(fontSize: 16, color: Colors.blueGrey),
                        hintText: '${AppLocalizations.of(context).translate('title')}',
                        border: new OutlineInputBorder(borderSide: new BorderSide(color: Colors.teal)),
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
                        labelText: '${AppLocalizations.of(context).translate('description')}',
                        labelStyle: TextStyle(fontSize: 16, color: Colors.blueGrey),
                        hintText: '${AppLocalizations.of(context).translate('description')}',
                        border: new OutlineInputBorder(borderSide: new BorderSide(color: Colors.teal)),
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    AppLocalizations.of(context).translate('background_color'),
                    style: TextStyle(color: Colors.blueGrey, fontSize: 12),
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
                    height: 30,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50.0,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (title.text.isNotEmpty)
                          updateBranchDescription();
                        else
                          showSnackBar('missing_input', 'close');
                      },
                      icon: Icon(
                        Icons.description,
                        color: Colors.white,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      ),
                      label: Text(
                        '${AppLocalizations.of(context).translate('update')}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ))),
    );
  }

  Widget imageWidget() {
    return Stack(clipBehavior: Clip.none, fit: StackFit.passthrough, children: [
      Container(
        alignment: Alignment.center,
        child: InkWell(
          onTap: () => _showSelectionDialog(context),
          child: compressedFileSource != null
              ? Image.memory(
                  compressedFileSource,
                  height: 150,
                )
              : Image.asset(
                  'drawable/nologo.png',
                  height: 150,
                ),
        ),
      ),
      Visibility(
        visible: compressedFileSource != null,
        child: Container(
            padding: EdgeInsets.all(5),
            height: 150,
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.red,
              ),
              onPressed: clearImage,
            )),
      ),
    ]);
  }

  clearImage() {
    compressedFileSource = null;
    controller.add('display');
  }

  // ValueChanged<Color> callback
  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  preview() async {
    int merchantID = Merchant.fromJson(await SharePreferences().read("merchant")).merchantId;
    var url = '${Domain.domain}/branch.php?id=$merchantID&preview=true';

    launchUrl(Uri.parse(url));
  }

  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  Future updateProfile() async {
    print(prefix);
    Map data = await Domain.callApi(Domain.merchant, {
      'update': '1',
      'name': name.text,
      'phone_prefix': prefix,
      'phone': phone.text,
      'logo': compressedFileSource != null ? base64Encode(compressedFileSource).toString() : '',
      'merchant_id': Merchant.fromJson(await SharePreferences().read("merchant")).merchantId.toString()
    });
    if (data['status'] == '1') {
      showSnackBar('update_success', 'close');
    } else {
      showSnackBar('something_went_wrong', 'close');
    }
  }

  Future updateBranchDescription() async {
    Map data = await Domain.callApi(Domain.merchant, {
      'update_branch': '1',
      'title': title.text,
      'description': description.text,
      'background_color': '#${pickerColor.value.toRadixString(16)}',
      'merchant_id': Merchant.fromJson(await SharePreferences().read("merchant")).merchantId.toString()
    });

    if (data['status'] == '1') {
      showSnackBar('update_success', 'close');
    } else if (data['status'] == '3') {
      showSnackBar('current_pass_not_match', 'close');
    } else {
      showSnackBar('something_went_wrong', 'close');
    }
  }

  /*-----------------------------------------photo compress-------------------------------------------*/
  Future<void> _showSelectionDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("${AppLocalizations.of(context).translate('take_photo_from_where')}"),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      label: Text('${AppLocalizations.of(context).translate('gallery')}', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
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
                    child: ElevatedButton.icon(
                      label: Text(
                        '${AppLocalizations.of(context).translate('camera')}',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
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

  /*
  * compress purpose
  * */
  Future getImage(isCamera) async {
    imagePath = await picker.getImage(source: isCamera ? ImageSource.camera : ImageSource.gallery);
    // compressFileMethod();
    _cropImage();
  }

  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imagePath.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepPurple,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      _image = croppedFile;
      compressFileMethod();
    }
  }

  void compressFileMethod() async {
    await Future.delayed(Duration(milliseconds: 300));

    Uint8List bytes = _image.readAsBytesSync();
    final ByteData data = ByteData.view(bytes.buffer);

    final dir = await path_provider.getTemporaryDirectory();

    File file = createFile("${dir.absolute.path}/test.png");
    file.writeAsBytesSync(data.buffer.asUint8List());
    compressedFileSource = await compressFile(file);
    controller.add('display');
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

  getPreData() async {
    this.allowBranch = Merchant.fromJson(await SharePreferences().read("merchant")).allowBranch;
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
