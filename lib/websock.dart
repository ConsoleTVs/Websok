/// Copyright (c) 2019 - Èrik Campobadal Forés
library websok;

/// For the use of @required.
import 'package:meta/meta.dart';
/// Import the underlying package to use websockets.
// import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

/// The [Websock] class is used to create a new websocket connection.
/// It maintains all the state, socket connection and streams and
/// it abstracts it to a high level usage.
abstract class Websok<C extends WebSocketChannel>
{
  /// Stores the host of the websocket server.
  final String host;

  /// Stores the port of the websocket server.
  final int port;

  /// Stores if the connection is performed under TLS.
  final bool tls;

  /// Additional query string parameters attached to the URL.
  final Map<String, String> query;

  /// Determines the protocols used for the connection.
  final Iterable<String> protocols;

  /// Connects to the websocket given the following options.
  C connectWith(String url, Iterable<String> protocols);

  /// Determines if the connection is established.
  bool isActive = false;

  /// Stores the channel used in to send / receive messages.
  C channel;

  /// Creates a new websok instance and connects to the websocket immidiatly.
  /// If no port is provided, 80 wil be used in case tls = false, otherwise,
  /// 443 will be used.
  Websok({
    @required this.host,
    this.port = -1,
    this.query = const <String, String>{},
    this.protocols = const <String>[],
    this.tls = false
  });

  /// Connects to the websocket server.
  void connect() {
    final protocol = this.tls ? 'wss' : 'ws';
    final port = this.port != -1 ? this.port : (this.tls ? 443 : 80);
    var url = '$protocol://${this.host}:$port?';
    this.query.forEach((key, value) => url += '$key=$value&');
    this.channel = this.connectWith(url, this.protocols);
    this.isActive = true;
  }

  /// Listens for different events and executes their callback.
  void listen({ void onData(dynamic message), void onError(), void onDone(), bool cancelOnError }) =>
    this.channel.stream.listen(
      onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError
    );

  /// Sends a message to the websocket.
  void send(String message) {
    if (this.isActive) this.channel.sink.add(message);
  }

  /// Closes the connection with the server.
  /// Returns a future which is completed when the stream sink has shut down.
  /// If cleaning up can fail, the error may be reported in the returned future,
  /// otherwise it completes with null.
  Future<dynamic> close([int code = status.goingAway, String reason]) {
    this.isActive = false;
    return this.channel.sink.close(code, reason);
  }
}
