class PhoneToEmailConverter {
  static String generateFakeEmail(String phone) {
    return '$phone@gmail.com';
  }

  static String returnPhoneFromEmail(String email) {
    return email.split('@')[0];
  }

  static String reutrnPhoneFromEmailWithoutCountryCode(String email) {
    return email.split('@')[0].substring(2);
  }
}
