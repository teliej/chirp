String formatNumber(int number) {
  if (number >= 1000000000) {
    return '${(number / 1000000000).toStringAsFixed((number % 1000000000 == 0) ? 0 : 1)}b';
  } else if (number >= 1000000) {
    return '${(number / 1000000).toStringAsFixed((number % 1000000 == 0) ? 0 : 1)}m';
  } else if (number >= 1000) {
    return '${(number / 1000).toStringAsFixed((number % 1000 == 0) ? 0 : 1)}k';
  } else {
    return number.toString();
  }
}