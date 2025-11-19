import 'dart:async';

/// A generic streaming paginator that handles automatic pagination for API calls.
///
/// This class wraps a fetcher function that returns paginated results and
/// automatically handles fetching subsequent pages, yielding items as they
/// arrive in a stream.
///
/// The fetcher function receives options (which may include a pageToken) and
/// should return a tuple of:
/// - An iterable of items from this page
/// - The nextPageToken (or null if no more pages)
///
/// Example usage:
/// ```dart
/// final stream = Streaming<File, GetFilesOptions>(
///   fetcher: (options) async {
///     final response = await api.getFiles(options);
///     return (response.items, response.nextPageToken);
///   },
///   initialOptions: GetFilesOptions(),
/// );
///
/// await for (final file in stream) {
///   print(file.name);
/// }
/// ```
class Streaming<T, TOptions> extends Stream<T> {
  /// The fetcher function that retrieves a page of results.
  ///
  /// Takes options (which may include a pageToken) and returns a tuple of:
  /// - An iterable of items from this page
  /// - The nextPageToken (or null if no more pages)
  final Future<(Iterable<T> items, String? nextPageToken)> Function(
      TOptions options) fetcher;

  /// Initial options to use for the first API call.
  final TOptions initialOptions;

  /// Maximum number of API calls to make. If null, fetches all pages.
  final int? maxApiCalls;

  /// Function to create a new options object with an updated pageToken.
  ///
  /// If not provided, the default implementation assumes the options class
  /// has a `pageToken` field that can be set via a copyWith method or similar.
  final TOptions Function(TOptions options, String pageToken)? updatePageToken;

  Streaming({
    required this.fetcher,
    required this.initialOptions,
    this.maxApiCalls,
    this.updatePageToken,
  });

  @override
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final subscription = _StreamingSubscription<T, TOptions>(
      fetcher: fetcher,
      initialOptions: initialOptions,
      maxApiCalls: maxApiCalls,
      updatePageToken: updatePageToken,
      onData: onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError ?? false,
    );
    return subscription.subscription;
  }
}

class _StreamingSubscription<T, TOptions> {
  final Future<(Iterable<T> items, String? nextPageToken)> Function(
      TOptions options) fetcher;
  final TOptions initialOptions;
  final int? maxApiCalls;
  final TOptions Function(TOptions options, String pageToken)? updatePageToken;
  final void Function(T event)? onData;
  final Function? onError;
  final void Function()? onDone;
  final bool cancelOnError;

  bool _isCancelled = false;
  StreamController<T>? _controller;
  StreamSubscription<T>? _subscription;

  _StreamingSubscription({
    required this.fetcher,
    required this.initialOptions,
    this.maxApiCalls,
    this.updatePageToken,
    this.onData,
    this.onError,
    this.onDone,
    required this.cancelOnError,
  }) {
    _startStreaming();
  }

  void _startStreaming() {
    _controller = StreamController<T>(
      onListen: () => _fetchPages(),
      onCancel: () {
        _isCancelled = true;
      },
    );

    _subscription = _controller!.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  TOptions _updatePageToken(TOptions options, String pageToken) {
    if (updatePageToken != null) {
      return updatePageToken!(options, pageToken);
    }

    // Try to use reflection or assume it's a Map-like structure
    // For now, we'll require updatePageToken to be provided for type safety
    // In practice, users should provide a copyWith-like function
    throw UnsupportedError(
      'updatePageToken must be provided to update options with new pageToken',
    );
  }

  Future<void> _fetchPages() async {
    var options = initialOptions;
    var apiCallCount = 0;

    try {
      while (!_isCancelled) {
        // Check maxApiCalls limit
        if (maxApiCalls != null && apiCallCount >= maxApiCalls!) {
          break;
        }

        // Fetch the next page
        final (items, nextPageToken) = await fetcher(options);

        // Emit all items from this page
        for (final item in items) {
          if (_isCancelled) break;
          _controller!.add(item);
        }

        apiCallCount++;

        // Check if there are more pages
        if (nextPageToken == null || nextPageToken.isEmpty) {
          break;
        }

        // Prepare options for next page
        options = _updatePageToken(options, nextPageToken);
      }
    } catch (e) {
      if (!_isCancelled) {
        _controller!.addError(e, StackTrace.current);
      }
    } finally {
      if (!_isCancelled) {
        await _controller!.close();
      }
    }
  }

  StreamSubscription<T> get subscription => _subscription!;
}
