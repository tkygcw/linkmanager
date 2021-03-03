import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linkmanager/object/merchant.dart';
import 'package:linkmanager/translation/AppLocalizations.dart';
import 'package:linkmanager/utils/domain.dart';
import 'package:linkmanager/utils/sharePreference.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Merchant merchant;
  final key = new GlobalKey<ScaffoldState>();

  String prefix;
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController domain = TextEditingController();
  TextEditingController phone = TextEditingController();

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
          title: Text(AppLocalizations.of(context).translate('profile'),
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
      name.text = merchant.name;
      email.text = merchant.email;
      domain.text = merchant.domain;
      phone.text = merchant.phone;
      prefix = merchant.phonePrefix;
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
      child: Card(
        margin: EdgeInsets.all(15),
        elevation: 5,
        child: Container(
          height: 450,
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
      ),
    );
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
