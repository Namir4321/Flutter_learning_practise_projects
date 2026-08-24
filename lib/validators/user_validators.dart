String? validateName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return "Name is required";
  }
  return null;
}

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email is required';
  }
  if (!value.contains('@') && !value.contains(".com")) {
    return 'Enter a valid email';
  }
  return null;
}
