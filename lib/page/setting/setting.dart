import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linkmanager/object/merchant.dart';
import 'package:linkmanager/page/navigationDrawer/navigationDrawer.dart';
import 'package:linkmanager/shareWidget/not_found.dart';
import 'package:linkmanager/shareWidget/progress_bar.dart';
import 'package:linkmanager/translation/AppLocalizations.dart';
import 'package:linkmanager/utils/domain.dart';
import 'package:linkmanager/utils/sharePreference.dart';

class SettingPage extends StatefulWidget {
  static const String routeName = '/setting';

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final key = new GlobalKey<ScaffoldState>();
  int urlID;
  Merchant merchant;

  String prefix;
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController domain = TextEditingController();
  TextEditingController phone = TextEditingController();

  TextEditingController currentPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();

  bool hideNewPassword = true;
  bool hideConfirmPassword = true;
  bool hideCurrentPassword = true;

  StreamController controller = StreamController();

  /*
     * network checking purpose
     * */
  StreamSubscription<ConnectivityResult> connectivity;
  bool networkConnection = true;

  @override
  void initState() {
    super.initState();
    //network detector
    connectivity = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        networkConnection = (result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi);
      });
    });
    fetchMerchant();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: key,
        appBar: AppBar(
          centerTitle: false,
          elevation: 2,
          title: Text(AppLocalizations.of(context).translate('setting'),
              textAlign: TextAlign.left,
              style: GoogleFonts.aBeeZee(
                textStyle: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              )),
          actions: <Widget>[],
        ),
        drawer: NavigationDrawer(),
        body: mainContent());
  }

  Widget mainContent() {
    return Theme(
      data: new ThemeData(
        primaryColor: Colors.purple,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [userProfile(), changePassword(), branchLayout()],
        ),
      ),
    );
  }

  Widget userProfile() {
    return Card(
      margin: EdgeInsets.all(15),
      elevation: 5,
      child: Container(
        height: 380,
        margin: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).translate('profile'),
              style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 15,
            ),
            TextField(
                keyboardType: TextInputType.text,
                controller: name,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  labelText:
                      '${AppLocalizations.of(context).translate('username')}',
                  labelStyle: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  hintText:
                      '${AppLocalizations.of(context).translate('username')}',
                  border: new OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.teal)),
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
                  labelText:
                      '${AppLocalizations.of(context).translate('email')}',
                  labelStyle: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  hintText:
                      '${AppLocalizations.of(context).translate('email')}',
                  border: new OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.teal)),
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
                  labelText:
                      '${AppLocalizations.of(context).translate('domain')}',
                  labelStyle: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  hintText:
                      '${AppLocalizations.of(context).translate('domain')}',
                  border: new OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.teal)),
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
                      borderRadius: BorderRadius.all(Radius.circular(
                              5.0) //                 <--- border radius here
                          ),
                    ),
                    child: CountryCodePicker(
                        onChanged: print,
                        // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                        initialSelection: prefix,
                        favorite: ['+60'],
                        comparator: (a, b) => b.name.compareTo(a.name),
                        //Get the country information relevant to the initial selection
                        onInit: (code) => prefix = code.code),
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
                        labelText:
                            '${AppLocalizations.of(context).translate('phone')}',
                        labelStyle:
                            TextStyle(fontSize: 16, color: Colors.blueGrey),
                        hintText:
                            '${AppLocalizations.of(context).translate('phone_hint')}',
                        border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.teal)),
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
              child: RaisedButton.icon(
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
                color: Colors.deepPurpleAccent,
                label: Text(
                  '${AppLocalizations.of(context).translate('update_profile')}',
                  style: TextStyle(color: Colors.white),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget changePassword() {
    return Card(
        margin: EdgeInsets.all(15),
        elevation: 5,
        child: Container(
            height: 345,
            margin: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).translate('change_password'),
                  style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 2,
                ),
                Text(
                  AppLocalizations.of(context)
                      .translate('change_password_description'),
                  style: TextStyle(color: Colors.black26, fontSize: 14),
                ),
                SizedBox(
                  height: 15,
                ),
                TextField(
                    keyboardType: TextInputType.text,
                    obscureText: hideCurrentPassword,
                    controller: currentPassword,
                    textAlign: TextAlign.start,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock_open),
                      labelText:
                          '${AppLocalizations.of(context).translate('current_password')}',
                      labelStyle:
                          TextStyle(fontSize: 14, color: Colors.blueGrey),
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.teal)),
                      suffixIcon: IconButton(
                        icon: Icon(hideCurrentPassword
                            ? Icons.remove_red_eye
                            : Icons.close),
                        onPressed: () {
                          setState(() {
                            hideCurrentPassword = !hideCurrentPassword;
                          });
                        },
                      ),
                    )),
                SizedBox(
                  height: 10,
                ),
                TextField(
                    keyboardType: TextInputType.text,
                    obscureText: hideNewPassword,
                    controller: newPassword,
                    textAlign: TextAlign.start,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock_open),
                      labelText:
                          '${AppLocalizations.of(context).translate('new_password')}',
                      labelStyle:
                          TextStyle(fontSize: 14, color: Colors.blueGrey),
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.teal)),
                      suffixIcon: IconButton(
                        icon: Icon(hideNewPassword
                            ? Icons.remove_red_eye
                            : Icons.close),
                        onPressed: () {
                          setState(() {
                            hideNewPassword = !hideNewPassword;
                          });
                        },
                      ),
                    )),
                SizedBox(
                  height: 10,
                ),
                TextField(
                    keyboardType: TextInputType.text,
                    obscureText: hideConfirmPassword,
                    controller: confirmPassword,
                    textAlign: TextAlign.start,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock_open),
                      labelText:
                          '${AppLocalizations.of(context).translate('confirm_password')}',
                      labelStyle:
                          TextStyle(fontSize: 14, color: Colors.blueGrey),
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.teal)),
                      suffixIcon: IconButton(
                        icon: Icon(hideConfirmPassword
                            ? Icons.remove_red_eye
                            : Icons.close),
                        onPressed: () {
                          setState(() {
                            hideConfirmPassword = !hideConfirmPassword;
                          });
                        },
                      ),
                    )),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50.0,
                  child: RaisedButton.icon(
                    onPressed: () {
                      if (newPassword.text == confirmPassword.text)
                        updatePassword();
                      else
                        showSnackBar('password_not_match', 'close');
                    },
                    icon: Icon(
                      Icons.security,
                      color: Colors.white,
                    ),
                    color: Colors.deepPurpleAccent,
                    label: Text(
                      '${AppLocalizations.of(context).translate('update_password')}',
                      style: TextStyle(color: Colors.white),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                  ),
                ),
              ],
            )));
  }

  Widget branchLayout() {
    return Card(
        margin: EdgeInsets.all(15),
        elevation: 5,
        child: Container(
            height: 460,
            margin: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).translate('change_password'),
                  style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 2,
                ),
                Text(
                  AppLocalizations.of(context)
                      .translate('change_password_description'),
                  style: TextStyle(color: Colors.black26, fontSize: 14),
                ),
                SizedBox(
                  height: 10,
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
                Container(
                    alignment: Alignment.center,
                    child: Image.asset('drawable/logo.png', height: 100)),
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
            )));
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
      name.text = merchant.name;
      email.text = merchant.email;
      domain.text = merchant.domain;
      phone.text = merchant.phone;
      prefix = merchant.phonePrefix;
      title.text = merchant.title;
      description.text = merchant.description;
    } else {
      showSnackBar('something_went_wrong', 'close');
    }

    setState(() {});
  }

  Future updateProfile() async {
    Map data = await Domain.callApi(Domain.merchant, {
      'update': '1',
      'name': name.text,
      'phone_prefix': prefix,
      'phone': phone.text,
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId
              .toString()
    });
    if (data['status'] == '1') {
      showSnackBar('update_success', 'close');
    } else {
      showSnackBar('something_went_wrong', 'close');
    }
  }

  Future updatePassword() async {
    Map data = await Domain.callApi(Domain.register, {
      'update': '1',
      'current_password': currentPassword.text,
      'new_password': newPassword.text,
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId
              .toString()
    });
    if (data['status'] == '1') {
      showSnackBar('update_success', 'close');
      currentPassword.clear();
      newPassword.clear();
      confirmPassword.clear();
      setState(() {});
    } else if (data['status'] == '3') {
      showSnackBar('current_pass_not_match', 'close');
    } else {
      showSnackBar('something_went_wrong', 'close');
    }
  }

  Future updateBranchDescription() async {
    Map data = await Domain.callApi(Domain.merchant, {
      'update_branch': '1',
      'title': title.text,
      'description': description.text,
      'logo': '1',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId
              .toString()
    });
    if (data['status'] == '1') {
      showSnackBar('update_success', 'close');
      currentPassword.clear();
      newPassword.clear();
      confirmPassword.clear();
      setState(() {});
    } else if (data['status'] == '3') {
      showSnackBar('current_pass_not_match', 'close');
    } else {
      showSnackBar('something_went_wrong', 'close');
    }
  }

  Widget notFound() {
    if (!networkConnection)
      return NotFound(
          title:
              '${AppLocalizations.of(context).translate('no_network_found')}',
          description:
              '${AppLocalizations.of(context).translate('no_network_found_description')}',
          showButton: true,
          refresh: () {
            setState(() {});
          },
          button: '${AppLocalizations.of(context).translate('retry')}',
          drawable: 'drawable/no_signal.png');
    else
      return CustomProgressBar();
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
}
