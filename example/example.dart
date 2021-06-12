/// For HTML:
/// import 'package:websok/html.dart';
///
/// For IO (Flutter, Dart, etc.)
import 'package:websok/io.dart';

/// The received string.
String? received;
/// Callback to execute when the function is over.
void onData(dynamic message) => received = message;

void main() async {
  /// For HTML: IOWebsok -> HTMLWebsok
  final sok = IOWebsok(host: 'echo.websocket.org', tls: true)
    ..connect()
    ..listen(onData: onData);
  // Send a message.
  sok.send('Hello, world!');
  // Prints the message.
  await Future.delayed(Duration(seconds: 1), () => print(received));
  // Close the connection after 1 sec.
  sok.close();
}
