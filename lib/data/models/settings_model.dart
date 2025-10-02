class Settings {
  final String id;
  final bool isDarkMode;
  final bool notificationsEnabled;
  final String userName;
  final String userEmail;

  Settings({
    required this.id,
    required this.isDarkMode,
    required this.notificationsEnabled,
    required this.userName,
    required this.userEmail,
  });

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      id: json['id'] as String,
      isDarkMode: json['isDarkMode'] as bool,
      notificationsEnabled: json['notificationsEnabled'] as bool,
      userName: json['userName'] as String,
      userEmail: json['userEmail'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isDarkMode': isDarkMode,
      'notificationsEnabled': notificationsEnabled,
      'userName': userName,
      'userEmail': userEmail,
    };
  }

  Settings copyWith({
    String? id,
    bool? isDarkMode,
    bool? notificationsEnabled,
    String? userName,
    String? userEmail,
  }) {
    return Settings(
      id: id ?? this.id,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
    );
  }
}
