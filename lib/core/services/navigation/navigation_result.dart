/// Neutral outcome returned by [ExternalNavigationService.navigate].
///
/// The Driver UI must never receive raw platform exceptions; it only inspects
/// [status] (and optionally [providerName]) to decide what feedback to show.
class NavigationResult {
  final NavigationStatus status;
  final String? providerName;
  final String? message;

  const NavigationResult._(this.status, this.providerName, this.message);

  const NavigationResult.launched(String provider)
      : this._(NavigationStatus.launched, provider, null);

  const NavigationResult.invalidRequest()
      : this._(
          NavigationStatus.invalidRequest,
          null,
          'Current location or destination is unavailable.',
        );

  const NavigationResult.noProvider([String? attempted])
      : this._(
          NavigationStatus.noProvider,
          attempted,
          'No navigation app is available on this device.',
        );

  const NavigationResult.failed(String? attempted, String? reason)
      : this._(NavigationStatus.failed, attempted, reason);

  bool get success => status == NavigationStatus.launched;

  @override
  String toString() => 'NavigationResult($status, provider: $providerName)';
}

enum NavigationStatus {
  launched,
  invalidRequest,
  noProvider,
  failed,
}
