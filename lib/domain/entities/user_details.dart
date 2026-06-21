class UserDetails {
  const UserDetails({
    required this.id,
    required this.userName,
    this.email,
    this.userNameThai,
    this.userNameEng,
    this.employeeId,
    this.userGroupType,
    this.defaultLanguage,
    this.companyId,
    this.inactive = false,
  });

  final String id;
  final String userName;
  final String? email;
  final String? userNameThai;
  final String? userNameEng;
  final String? employeeId;
  final String? userGroupType;
  final String? defaultLanguage;
  final String? companyId;
  final bool inactive;
}
