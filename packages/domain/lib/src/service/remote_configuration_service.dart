/// The interface for retrieving remote configuration values.
abstract class RemoteConfigurationService {
  const RemoteConfigurationService._();

  /// Retrieves the API key stored in the remote configuration.
  String get weatherApiKey;

  /// Initializes all require resources for the service.
  Future<void> initialize() async {}
}
