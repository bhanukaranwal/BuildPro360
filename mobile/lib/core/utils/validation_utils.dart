class ValidationUtils {
  static String? validateRequired(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  static String? validatePassword(String? value, {int minLength = 8}) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters long';
    }
    
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    
    return null;
  }
  
  static String? validatePasswordMatch(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.trim().isEmpty) {
      return 'Confirm password is required';
    }
    
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    
    return null;
  }
  
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone may be optional
    }
    
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'\D'), ''))) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }
  
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // URL may be optional
    }
    
    final urlRegex = RegExp(r'^(http|https)://[a-zA-Z0-9-\.]+\.[a-zA-Z]{2,}(/\S*)?$');
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }
  
  static String? validateNumber(String? value, {double? min, double? max}) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (min != null && number < min) {
      return 'Value must be greater than or equal to $min';
    }
    
    if (max != null && number > max) {
      return 'Value must be less than or equal to $max';
    }
    
    return null;
  }
  
  static String? validateDate(String? value, {DateTime? minDate, DateTime? maxDate}) {
    if (value == null || value.trim().isEmpty) {
      return 'Date is required';
    }
    
    try {
      final date = DateTime.parse(value);
      
      if (minDate != null && date.isBefore(minDate)) {
        return 'Date must be on or after ${minDate.toString().split(' ')[0]}';
      }
      
      if (maxDate != null && date.isAfter(maxDate)) {
        return 'Date must be on or before ${maxDate.toString().split(' ')[0]}';
      }
      
      return null;
    } catch (e) {
      return 'Please enter a valid date in YYYY-MM-DD format';
    }
  }
  
  static String? validateLength(String? value, {int? minLength, int? maxLength}) {
    if (value == null) {
      return 'This field is required';
    }
    
    if (minLength != null && value.length < minLength) {
      return 'Must be at least $minLength characters long';
    }
    
    if (maxLength != null && value.length > maxLength) {
      return 'Must be at most $maxLength characters long';
    }
    
    return null;
  }
}