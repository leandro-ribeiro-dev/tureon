import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../domain/message_date_grouper.dart';

/// Lazy, keyed message history viewport. The screen owns chat behavior while
/// this widget owns list layout and scroll notifications.
class ChatMessageList extends StatelessWidget {
  const ChatMessageList({
    required this.controller,
    required this.items,
    required this.itemKey,
    required this.itemBuilder,
    required this.empty,
    required this.isLoadingEarlier,
    required this.onReachStart,
    required this.onUserScroll,
    required this.onMetricsChanged,
    super.key,
  });

  final ScrollController controller;
  final List<MessageListItem> items;
  final Key Function(int index) itemKey;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final Widget empty;
  final bool isLoadingEarlier;
  final VoidCallback onReachStart;
  final bool Function(UserScrollNotification notification) onUserScroll;
  final VoidCallback onMetricsChanged;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty && !isLoadingEarlier) return empty;

    final indexByKey = <Key, int>{};
    for (var index = 0; index < items.length; index++) {
      indexByKey[itemKey(index)] = index + (isLoadingEarlier ? 1 : 0);
    }

    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (_) {
        onMetricsChanged();
        return false;
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification ||
              notification is OverscrollNotification) {
            if (notification.metrics.axis == Axis.vertical &&
                notification.metrics.pixels <=
                    notification.metrics.minScrollExtent + 32) {
              onReachStart();
            }
          }
          if (notification is UserScrollNotification) {
            return onUserScroll(notification);
          }
          return false;
        },
        child: ListView.builder(
          controller: controller,
          padding: const EdgeInsets.symmetric(vertical: 12),
          scrollCacheExtent: const ScrollCacheExtent.pixels(600),
          itemCount: items.length + (isLoadingEarlier ? 1 : 0),
          findChildIndexCallback: (key) => indexByKey[key],
          itemBuilder: (context, index) {
            if (isLoadingEarlier && index == 0) {
              return const Center(
                key: ValueKey<String>('chat-history-loader'),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            final itemIndex = index - (isLoadingEarlier ? 1 : 0);
            return KeyedSubtree(
              key: itemKey(itemIndex),
              child: itemBuilder(context, itemIndex),
            );
          },
        ),
      ),
    );
  }
}
