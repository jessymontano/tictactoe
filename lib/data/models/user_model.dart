class UserModel {
  final String uid;
  final String username;
  final String email;
  final String pfpUrl;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.pfpUrl = '',
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      pfpUrl: data['pfpUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'uid': uid, 'username': username, 'email': email, 'pfpUrl': pfpUrl};
  }
}
