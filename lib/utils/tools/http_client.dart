import 'package:http/http.dart' as http;

@Deprecated('Use `Dio` instead')
class TimeClient extends http.BaseClient {
  final http.Client _inner;
  TimeClient() : _inner = http.Client();
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _timeLimit(() => _inner.send(request), onTimeout: () {
      throw http.ClientException('TIMEOUT', request.url);
    });
  }

  @override
  void close() {
    _inner.close();
  }
}

// Future _withClient(Future<T> Function(http.Client) fn) async {
//   var client = http.Client();
//   await timeLimit(() => fn(client), onTimeout: () => client.close());
// }

Future<T> _timeLimit<T>(Future<T> Function() fn, {int? seconds, required Future<T> Function() onTimeout}) async {
  try {
    return await fn().timeout(Duration(seconds: seconds ?? 5));
  } catch (e) {
    return await onTimeout();
  }
}
