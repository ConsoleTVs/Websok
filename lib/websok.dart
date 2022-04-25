/// Copyright (c) 2019 - Èrik Campobadal Forés
library websok;

/// Import the underlying package to use websockets.
// import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

/// The [Websock] class is used to create a new websocket connection.
/// It maintains all the state, socket connection and streams and
/// it abstracts it to a high level usage.
abstract class Websok<C extends WebSocketChannel> {
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

  /// Stores the URL path.
  final String path;

  /// Connects to the websocket given the following options.
  C connectWith(String url, Iterable<String> protocols);

  /// Determines if the connection is established.
  bool isActive = false;

  /// Stores the channel used in to send / receive messages.
  late C channel;

  /// Creates a new websok instance and connects to the websocket immidiatly.
  /// If no port is provided, 80 wil be used in case tls = false, otherwise,
  /// 443 will be used.
  Websok({
    required this.host,
    this.port = -1,
    this.path = '',
    this.query = const <String, String>{},
    this.protocols = const <String>[],
    this.tls = false,
  });

  /// Returns the URL used to connect tpo the websocket.
  String url() {
    final protocol = this.tls ? 'wss' : 'ws';
    final port = this.port != -1 ? this.port : (this.tls ? 443 : 80);
    final path = this.path.startsWith('/') ? this.path.substring(1) : this.path;
    var url = '$protocol://${this.host}:$port/$path?';
    this.query.forEach((key, value) => url += '$key=$value&');
    return url;
  }

  /// Connects to the websocket server.
  void connect() {
    this.channel = this.connectWith(this.url(), this.protocols);
    this.isActive = true;
  }

  /// Listens for different events and executes their callback.
  void listen({
    void onData(dynamic message)?,
    void onError(error)?,
    void onDone()?,
    bool? cancelOnError,
  }) =>
      this.channel.stream.listen(
            onData,
            onError: onError,
            onDone: onDone,
            cancelOnError: cancelOnError,
          );

  /// Sends a message to the websocket.
  void send(String message) {
    if (this.isActive) this.channel.sink.add(message);
  }

  /// Closes the connection with the server.
  /// Returns a future which is completed when the stream sink has shut down.
  /// If cleaning up can fail, the error may be reported in the returned future,
  /// otherwise it completes with null.
  Future<dynamic> close([int code = status.goingAway, String? reason]) {
    this.isActive = false;
    return this.channel.sink.close(code, reason);
  }
}
