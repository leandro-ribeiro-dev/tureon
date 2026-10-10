part of '../message_bubble.dart';

class _RichMessageText extends StatefulWidget {
  const _RichMessageText({
    required this.text,
    required this.color,
    required this.fontSize,
    this.trailing,
  });

  final String text;
  final Color color;
  final double fontSize;
  final Widget? trailing;

  @override
  State<_RichMessageText> createState() => _RichMessageTextState();
}

class _RichMessageTextState extends State<_RichMessageText> {
  static final _segments = RegExp(
    r'```[\s\S]*?```|`[^`\n]+`|https?://[^\s<>{}\[\]]+|www\.[^\s<>{}\[\]]+',
  );
  static const _trailingUrlPunctuation = '.,!?;:)';
  final _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  List<TextSpan> _buildSpans() {
    final spans = <TextSpan>[];
    var cursor = 0;
    for (final match in _segments.allMatches(widget.text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: widget.text.substring(cursor, match.start)));
      }
      final token = match.group(0)!;
      if (token.startsWith('`')) {
        final isFenced = token.startsWith('```');
        final code = isFenced
            ? token
                  .substring(3, token.length - 3)
                  .replaceFirst(RegExp(r'^\w+\n'), '')
            : token.substring(1, token.length - 1);
        spans.add(
          TextSpan(
            text: code,
            style: TextStyle(
              fontFamily: 'monospace',
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.12),
            ),
          ),
        );
      } else {
        var url = token;
        while (url.isNotEmpty &&
            _trailingUrlPunctuation.contains(url[url.length - 1])) {
          url = url.substring(0, url.length - 1);
        }
        if (url.isEmpty) {
          spans.add(TextSpan(text: token));
        } else {
          final uri = Uri.tryParse(
            url.startsWith('www.') ? 'https://$url' : url,
          );
          if (uri == null ||
              (uri.scheme != 'http' && uri.scheme != 'https') ||
              uri.host.isEmpty) {
            spans.add(TextSpan(text: token));
          } else {
            final recognizer = TapGestureRecognizer()
              ..onTap = () => unawaited(_openLink(uri));
            _recognizers.add(recognizer);
            final primaryColor = Theme.of(context).colorScheme.primary;
            spans.add(
              TextSpan(
                text: url,
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: primaryColor,
                ),
                recognizer: recognizer,
              ),
            );
            if (url.length < token.length) {
              spans.add(TextSpan(text: token.substring(url.length)));
            }
          }
        }
      }
      cursor = match.end;
    }
    if (cursor < widget.text.length) {
      spans.add(TextSpan(text: widget.text.substring(cursor)));
    }
    return spans;
  }

  Future<void> _openLink(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(context.safeLocalizations.openLinkFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: widget.fontSize,
          height: 1.3,
          color: widget.color,
        ),
        children: [
          ..._buildSpans(),
          if (widget.trailing != null)
            WidgetSpan(
              alignment: PlaceholderAlignment.bottom,
              child: widget.trailing!,
            ),
        ],
      ),
    );
  }
}
