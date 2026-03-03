import 'package:bcrypt/bcrypt.dart';
// should hashed like supabase

bool compareHash(String input, String hashed) {
  return BCrypt.checkpw(input, hashed);
}
