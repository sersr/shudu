extension DateTimeFormat on DateTime {
  String get toStringFormat {
    return '${month}/${day}/${year} ${hour.timePadLeft}:${minute.timePadLeft}:${second.timePadLeft} ${hour < 9 ? 'AM' : 'PM'}';
  }
}

extension PadLeft on int {
  String get timePadLeft {
    return '${toString().padLeft(2, '0')}';
  }
}

extension IsEmpty on Map<String, dynamic> {
  bool get contentIsEmpty {
    if (isEmpty || !containsKey('content')) {
      return true;
    } else {
      return false;
    }
  }

  bool get contentIsNotEmpty {
    return !contentIsEmpty;
  }
}
