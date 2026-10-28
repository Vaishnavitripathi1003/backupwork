class SignUpEntity {
  final String firstName;
  final String lastName;
  final String email;
  final String mobile;
  final String password;
  final String otp;
  final String userType;

  const SignUpEntity({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobile,
    required this.password,
    required this.otp,
    this.userType = 'daksh',
  });
}