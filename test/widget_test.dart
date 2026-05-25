import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_app/main.dart';

// 1x1 transparent GIF image bytes
final List<int> transparentImage = [
  0x47, 0x49, 0x46, 0x38, 0x39, 0x61, 0x01, 0x00, 0x01, 0x00, 0x80, 0x00,
  0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0x21, 0xf9, 0x04, 0x01, 0x00,
  0x00, 0x00, 0x00, 0x2c, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00,
  0x00, 0x02, 0x02, 0x4c, 0x01, 0x00, 0x3b
];

class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient();
  }
}

class MockHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) => Future.value(MockHttpClientRequest());

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) => Future.value(MockHttpClientRequest());

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}

class MockHttpClientRequest implements HttpClientRequest {
  @override
  final HttpHeaders headers = MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() => Future.value(MockHttpClientResponse());

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}

class MockHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  @override
  int get statusCode => 200;
  
  @override
  int get contentLength => transparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  final HttpHeaders headers = MockHttpHeaders();

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream<List<int>>.fromIterable([transparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}

class MockHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  testWidgets('Executive Command dashboard smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    // Verify that the welcome text and total tasks metric are displayed.
    expect(find.text('Selamat Pagi, Kepala'), findsOneWidget);
    expect(find.text('TOTAL TASKS'), findsOneWidget);
    expect(find.text('124'), findsOneWidget);

    // Verify that notifications button exists
    expect(find.byIcon(Icons.notifications_none_outlined), findsOneWidget);
  });
}
