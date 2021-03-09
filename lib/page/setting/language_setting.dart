import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:linkmanager/translation/AppLocalizations.dart';
import 'package:linkmanager/translation/appLanguage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageDialog extends StatefulWidget {
  LanguageDialog();

  @override
  _LanguageDialogState createState() => _LanguageDialogState();
}

class _LanguageDialogState extends State<LanguageDialog> {
  var selectedLanguage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setSelectedLanguage();
  }

  setSelectedLanguage() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.getString('language_code') == null) {
        selectedLanguage = 'English';
        return Null;
      }
      selectedLanguage = getLanguage(prefs.getString('language_code'));
      return Null;
    });
  }

  @override
  Widget build(BuildContext context) {
    var appLanguage = Provider.of<AppLanguage>(context);
    return AlertDialog(
      title: Text(
        AppLocalizations.of(context).translate('language'),
        style: GoogleFonts.cantoraOne(
          textStyle: TextStyle(
              color: Colors.deepPurpleAccent,
              fontWeight: FontWeight.bold,
              fontSize: 25),
        ),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            RadioButtonGroup(
                labels: <String>[
                  "English",
                  "中文",
                  "Malay",
                ],
                picked: selectedLanguage,
                onSelected: (String selectedLanguage) {
                  setState(() {
                    this.selectedLanguage = selectedLanguage;
                  });
                }),
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('${AppLocalizations.of(context).translate('cancel')}'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text(
            '${AppLocalizations.of(context).translate('update')}',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            appLanguage
                .changeLanguage(Locale(getLanguageCode(selectedLanguage)));
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  String getLanguage(selectedLanguage) {
    switch (selectedLanguage) {
      case 'zh':
        return '中文';
      case 'ms':
        return 'Malay';
      default:
        return 'English';
    }
  }

  String getLanguageCode(selectedLanguage) {
    switch (selectedLanguage) {
      case '中文':
        return 'zh';
      case 'Malay':
        return 'ms';
      default:
        return 'en';
    }
  }
}
