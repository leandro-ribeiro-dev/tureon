part of '../message_bubble.dart';

/// Telegram-shaped body: rounded corners and a small curved delivery-side tail.
class _BubbleShape extends ShapeBorder {
  const _BubbleShape({
    required this.borderRadius,
    required this.isMine,
    required this.tail,
  });
  final BorderRadius borderRadius;
  final bool isMine;
  final bool tail;
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;
  @override
  ShapeBorder scale(double t) =>
      _BubbleShape(borderRadius: borderRadius * t, isMine: isMine, tail: tail);
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    if (!tail) return Path()..addRRect(borderRadius.toRRect(rect));
    final body = Rect.fromLTRB(
      rect.left + (isMine ? 0 : 5),
      rect.top,
      rect.right - (isMine ? 5 : 0),
      rect.bottom,
    );
    final path = Path()..addRRect(borderRadius.toRRect(body));
    final edge = isMine ? body.right : body.left;
    final sign = isMine ? 1.0 : -1.0;
    path.moveTo(edge - sign * 4, rect.bottom - 10);
    path.quadraticBezierTo(
      edge + sign,
      rect.bottom - 3,
      edge + sign * 5,
      rect.bottom,
    );
    path.quadraticBezierTo(
      edge - sign * 3,
      rect.bottom + 1,
      edge - sign * 7,
      rect.bottom - 1,
    );
    path.close();
    return path;
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);
  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}
}
