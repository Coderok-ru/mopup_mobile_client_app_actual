/// Утилиты для работы с HTML‑текстом.
class HtmlUtils {
  const HtmlUtils._();

  /// Удаляет HTML‑теги и лишние пробелы из строки.
  static String removeHtmlTags(String source) {
    if (source.isEmpty) {
      return '';
    }
    final RegExp tagsRegExp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    String result = source.replaceAll(tagsRegExp, ' ');
    result = result.replaceAll('&nbsp;', ' ');
    result = result.replaceAll('&quot;', '"');
    result = result.replaceAll('&apos;', '\'');
    result = result.replaceAll('&lt;', '<');
    result = result.replaceAll('&gt;', '>');
    result = result.replaceAll('&amp;', '&');
    result = result.replaceAll(RegExp(r'\s+'), ' ');
    return result.trim();
  }
}


