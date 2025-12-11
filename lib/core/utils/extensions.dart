extension StringCasingExtension on String {
  String toCapitalized() => length > 0 ?'${this[0].toUpperCase()}${substring(1).toLowerCase()}':'';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized()).join(' ');

  String toCapitalizeText() {
    if (isEmpty) return this; // Return empty string as is
    if (trim().isEmpty) return this; // Return string with only spaces as is

    // Find the first alphabetic character
    int firstLetterIndex = 0;
    for (var i = 0; i < length; i++) {
      if (this[i].toUpperCase() != this[i].toLowerCase()) {
        // Found a letter (since upper and lower case differ)
        firstLetterIndex = i;
        break;
      }
    }

    // If no letter found, return original string
    if (firstLetterIndex >= length) return this;

    // Capitalize the first letter and concatenate with the rest
    return substring(0, firstLetterIndex) +
        this[firstLetterIndex].toUpperCase() +
        substring(firstLetterIndex + 1);
  }
}

extension SwappableList<E> on List<E> {
  void swap(int first, int second) {
    final temp = this[first];
    this[first] = this[second];
    this[second] = temp;
  }
}