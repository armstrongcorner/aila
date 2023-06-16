String toSnakeCase(String value) {
  return value.replaceAllMapped(
      RegExp(r'[A-Z]'), (Match match) => '_' + match[0]!.toLowerCase());
}

bool isEmpty(String? s) => s == null || s.isEmpty;

bool isNotEmpty(String? s) => s != null && s.isNotEmpty;

bool isEmptyList(List<Object>? list) => list == null || list.isEmpty;

bool isNotEmptyList(List<Object>? list) => list != null && list.isNotEmpty;

String getErrorMsg(String msg) {
  return msg.split(': ').last;
}
