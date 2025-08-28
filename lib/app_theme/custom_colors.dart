import 'package:flutter/material.dart';

@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  final Color chatBackground;
  final Color bubbleIncoming;
  final Color bubbleOutgoing;
  final Color incomingTimeStamp;
  final Color outgoingTimeStamp;
  final Color header;

  const CustomColors({
    required this.chatBackground,
    required this.bubbleIncoming,
    required this.bubbleOutgoing,
    required this.incomingTimeStamp,
    required this.outgoingTimeStamp,
    required this.header,
  });

  @override
  CustomColors copyWith({
    Color? chatBackground,
    Color? bubbleIncoming,
    Color? bubbleOutgoing,
    Color? incomingTimeStamp,
    Color? outgoingTimeStamp,
    Color? header,
  }) {
    return CustomColors(
      chatBackground: chatBackground ?? this.chatBackground,
      bubbleIncoming: bubbleIncoming ?? this.bubbleIncoming,
      bubbleOutgoing: bubbleOutgoing ?? this.bubbleOutgoing,
      incomingTimeStamp: incomingTimeStamp ?? this.incomingTimeStamp,
      outgoingTimeStamp: outgoingTimeStamp ?? this.outgoingTimeStamp,
      header: header ?? this.header,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      chatBackground: Color.lerp(chatBackground, other.chatBackground, t)!,
      bubbleIncoming: Color.lerp(bubbleIncoming, other.bubbleIncoming, t)!,
      bubbleOutgoing: Color.lerp(bubbleOutgoing, other.bubbleOutgoing, t)!,
      incomingTimeStamp: Color.lerp(incomingTimeStamp, other.incomingTimeStamp, t)!,
      outgoingTimeStamp: Color.lerp(outgoingTimeStamp, other.outgoingTimeStamp, t)!,
      header: Color.lerp(header, other.header, t)!,
    );
  }
}
