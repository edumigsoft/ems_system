import 'dart:math';

/// Generate Password
///
/// Function to generate a password, sent to the
///  new user's registered email, new password or password recovery.
///
/// Number of lowercase letters [lowercaseLength], default equal to 2
/// Number of uppercase letters [uppercaseLength], default equal to 2
/// Number of numeric characters [numberLength], default equal to 2
/// Number of special characters [specialCharacterLength], default equal to 2
String generateRandomPassword({
  int lowercaseLength = 2,
  int uppercaseLength = 2,
  int numberLength = 2,
  int specialCharacterLength = 2,
}) {
  /*
  notEmpty()
  minLength(8)
  mustHaveLowercase()
  mustHaveUppercase()
  mustHaveNumber()
  mustHaveSpecialCharacter();
   */

  // const charLC = 'abcdefghijklmnopqrstuvwxyz';
  const charLC = 'pzxbnrycmkuatvweqsolfdighj';
  // const charUC = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const charUC = 'JDEQCGBMOYHVRPIUAZFTKXWLSN';
  // const charNU = '1234567890';
  const charNU = '5421796083';
  const charSP = '!@#\$%^&*(),.?":{}|<>';
  int charType = 0;
  int charTypeOld = 0;
  final length =
      lowercaseLength + uppercaseLength + numberLength + specialCharacterLength;
  final Random random = Random.secure();
  final List<String> passwordL = [];
  String charResult = '';

  for (var i = 0; i < length; i++) {
    charType = random.nextInt(4);
    if (charTypeOld != charType) {
      charTypeOld = charType;
    } else {
      i--;
      continue;
    }

    switch (charType) {
      case 0:
        if (lowercaseLength > 0) {
          charResult = charLC[random.nextInt(charLC.length)];
          if (!passwordL.contains(charResult)) {
            passwordL.add(charResult);
            lowercaseLength--;
          } else {
            i--;
          }
        } else {
          i--;
        }
        break;
      case 1:
        if (uppercaseLength > 0) {
          charResult = charUC[random.nextInt(charUC.length)];
          if (!passwordL.contains(charResult)) {
            passwordL.add(charResult);
            uppercaseLength--;
          } else {
            i--;
          }
        } else {
          i--;
        }
        break;
      case 2:
        if (numberLength > 0) {
          charResult = charNU[random.nextInt(charNU.length)];
          if (!passwordL.contains(charResult)) {
            passwordL.add(charResult);
            numberLength--;
          } else {
            i--;
          }
        } else {
          i--;
        }
        break;
      case 3:
        if (specialCharacterLength > 0) {
          charResult = charSP[random.nextInt(charSP.length)];
          if (!passwordL.contains(charResult)) {
            passwordL.add(charResult);
            specialCharacterLength--;
          } else {
            i--;
          }
        } else {
          i--;
        }
        break;
    }
  }

  return passwordL.join();
}
