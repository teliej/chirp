import 'package:flutter/material.dart';
import '../app_theme/custom_colors.dart';


class MessageBubble extends StatelessWidget {
  final String message;
  final String timestamp;
  final bool isMe;
  final bool isSeen;
  final bool isDelivered;
  final String? avatarUrl;

  const MessageBubble({
    super.key,
    required this.message,
    required this.timestamp,
    required this.isMe,
    this.isSeen = false,
    this.isDelivered = true,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final theme = Theme.of(context);

    final bubbleColor = isMe ? customColors.bubbleOutgoing : customColors.bubbleIncoming;
    final textColor = theme.textTheme.bodyLarge?.color;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe && avatarUrl != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(avatarUrl!),
              ),
            ),
          Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // Bubble
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7, // ✅ limit bubble width
                ),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isMe
                        ? const Radius.circular(16)
                        : const Radius.circular(0),
                    bottomRight: isMe
                        ? const Radius.circular(0)
                        : const Radius.circular(16),
                  ),
                ),
                child: Text(
                  message,
                  style: TextStyle(color: textColor, fontSize: 16),
                  softWrap: true, // ✅ wrap text when long
                ),
              ),
              const SizedBox(height: 2),
              // Timestamp + ticks outside
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timestamp,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: isMe ? customColors.outgoingTimeStamp : customColors.incomingTimeStamp,
                    ),
                  ),
                  if (isMe) const SizedBox(width: 4),
                  if (isMe)
                    Icon(
                      isSeen
                          ? Icons.done_all
                          : isDelivered
                              ? Icons.done_all
                              : Icons.check,
                      size: 16,
                      color: isSeen
                          ? theme.colorScheme.secondary
                          : theme.textTheme.bodyMedium?.color,
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
