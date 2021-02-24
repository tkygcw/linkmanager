import 'package:flutter/cupertino.dart';

class Channel {
  int channelId;
  String channel, url, icon, label, hint, labelMessage, messageHint;
  TextInputType inputType;

  Channel(
      {this.channel,
      this.channelId,
      this.url,
      this.icon,
      this.label,
      this.hint,
      this.labelMessage,
      this.messageHint,
      this.inputType});

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
        channelId: json['channel_id'] as int,
        inputType: getInputType(json['input_type']),
        channel: json['channel'] as String,
        url: json['url'] as String,
        icon: json['icon'] as String,
        label: json['label'] as String,
        hint: json['hint'] as String,
        labelMessage: json['label_message'] as String,
        messageHint: json['message_hint'] as String);
  }

  static TextInputType getInputType(inputType) {
    switch (inputType) {
      case 0:
        return TextInputType.text;
      case 1:
        return TextInputType.multiline;
      case 2:
        return TextInputType.numberWithOptions();
      case 3:
        return TextInputType.phone;
      case 5:
        return TextInputType.emailAddress;
      case 6:
        return TextInputType.url;
      case 8:
        return TextInputType.name;
    }
  }
}
