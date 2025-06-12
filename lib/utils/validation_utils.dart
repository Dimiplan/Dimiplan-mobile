class ValidationUtils {
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isDimigoEmail(String email) {
    return email.endsWith('@dimigo.hs.kr');
  }

  static bool isNotEmpty(String? text) {
    return text != null && text.trim().isNotEmpty;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (!isNotEmpty(value)) {
      return '$fieldName을(를) 입력해주세요.';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (!isNotEmpty(value)) {
      return '이메일을 입력해주세요.';
    }
    if (!isValidEmail(value!)) {
      return '올바른 이메일 형식이 아닙니다.';
    }
    return null;
  }

  static String? validateLength(
    String? value,
    int minLength,
    int maxLength,
    String fieldName,
  ) {
    if (!isNotEmpty(value)) {
      return '$fieldName을(를) 입력해주세요.';
    }
    if (value!.length < minLength) {
      return '$fieldName은(는) 최소 $minLength자 이상이어야 합니다.';
    }
    if (value.length > maxLength) {
      return '$fieldName은(는) 최대 $maxLength자까지 입력 가능합니다.';
    }
    return null;
  }
}
