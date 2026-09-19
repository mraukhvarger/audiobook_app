class StorageConnection {
  const StorageConnection({
    required this.providerId,
    required this.baseUrl,
    required this.username,
    required this.password,
  });

  static const String webDavProviderId = 'webdav';

  final String providerId;
  final Uri baseUrl;
  final String username;
  final String password;

  StorageConnection copyWith({
    String? providerId,
    Uri? baseUrl,
    String? username,
    String? password,
  }) {
    return StorageConnection(
      providerId: providerId ?? this.providerId,
      baseUrl: baseUrl ?? this.baseUrl,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }
}
