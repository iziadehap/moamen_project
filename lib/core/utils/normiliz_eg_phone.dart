String normalizeEgyptianPhone(String input) {
  // remove anything except digits
  String phone = input.replaceAll(RegExp(r'\D'), '');

  // Case 1: 01xxxxxxxxx
  if (phone.startsWith('01') && phone.length == 11) {
    return '+20${phone.substring(1)}';
  }

  // Case 2: 201xxxxxxxxx
  if (phone.startsWith('201') && phone.length == 12) {
    print('✅ Phone normalized: $phone');
    return '+$phone';
  }

  // Case 3: already correct but without +
  if (phone.startsWith('20') && phone.length == 12) {
    print('✅ Phone normalized: $phone');
    return '+$phone';
  }

  // Case 4: wrong format
  throw Exception('Invalid Egyptian mobile number');
}
