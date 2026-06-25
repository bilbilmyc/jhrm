// IfTemplate: minimal in-house Mustache-lite renderer.
// Supports: {{var}} substitution + {{#if cond}}...{{/if}} blocks.
// Per decisions.md #10: chosen over mustache package (no Dart 3.x release).

String renderIfTemplate(String template, Map<String, dynamic> ctx) {
  // Two passes: collect {{#if}}...{{/if}} block positions, then process
  // conditions first so the substitution pass doesn't see them.
  final buf = StringBuffer();
  var i = 0;
  while (i < template.length) {
    if (i + 4 < template.length && template.substring(i, i + 5) == '{{#if') {
      final close = template.indexOf('}}', i);
      if (close < 0) {
        buf.write(template.substring(i));
        break;
      }
      final condName =
          template.substring(i + 5, close).trim();
      final blockStart = close + 2;
      final endTag = '{{/if}}';
      final blockEnd = template.indexOf(endTag, blockStart);
      if (blockEnd < 0) {
        buf.write(template.substring(i));
        break;
      }
      final inner = template.substring(blockStart, blockEnd);
      final truthy = _isTruthy(ctx[condName]);
      buf.write(truthy ? inner : '');
      i = blockEnd + endTag.length;
    } else if (i + 1 < template.length && template.substring(i, i + 2) == '{{') {
      final close = template.indexOf('}}', i);
      if (close < 0) {
        buf.write(template.substring(i));
        break;
      }
      final name = template.substring(i + 2, close).trim();
      final v = ctx[name];
      buf.write(v == null ? '' : v.toString());
      i = close + 2;
    } else {
      buf.write(template[i]);
      i++;
    }
  }
  return buf.toString();
}

bool _isTruthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) return v.isNotEmpty;
  return true;
}
