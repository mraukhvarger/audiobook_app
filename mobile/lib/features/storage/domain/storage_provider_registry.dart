import 'storage_provider.dart';

class StorageProviderRegistry {
  StorageProviderRegistry(Iterable<StorageProvider> providers)
      : _providers = {
          for (final provider in providers) provider.providerId: provider
        };

  final Map<String, StorageProvider> _providers;

  StorageProvider? byId(String id) => _providers[id];

  List<StorageProvider> get all => _providers.values.toList();

  void register(StorageProvider provider) {
    _providers[provider.providerId] = provider;
  }
}
