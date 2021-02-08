class Channel {
  int channelId;
  String channel, url, icon, label, hint, labelMessage, messageHint;

  Channel({
    this.channel,
    this.channelId,
    this.url,
    this.icon,
    this.label,
    this.hint,
    this.labelMessage,
    this.messageHint,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
        channelId: json['channel_id'] as int,
        channel: json['channel'] as String,
        url: json['url'] as String,
        icon: json['icon'] as String,
        label: json['label'] as String,
        hint: json['hint'] as String,
        labelMessage: json['label_message'] as String,
        messageHint: json['message_hint'] as String);
  }
}
