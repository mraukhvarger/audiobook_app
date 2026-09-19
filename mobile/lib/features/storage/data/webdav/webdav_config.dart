class WebDavConfig {
  const WebDavConfig({
    required this.baseUrl,
    required this.username,
    required this.password,
  });

  static final Uri yandexDisk = Uri.parse('https://webdav.yandex.ru');

  final Uri baseUrl;
  final String username;
  final String password;
}
