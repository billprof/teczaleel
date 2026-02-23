extension StringExtension on String {
  String get toTitleCase {
    if (trim().isEmpty) {
      return '';
    }
    return replaceAll(
      RegExp(' +'),
      ' ',
    ).split(' ').map((str) => str.toCapitalized).join(' ');
  }

  String get toCapitalized {
    if (isEmpty) {
      return '';
    }
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
