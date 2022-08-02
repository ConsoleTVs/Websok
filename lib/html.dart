/// Copyright (c) 2019 - Èrik Campobadal Forés
library websok.html;

import 'package:websok/websok.dart';
import 'package:web_socket_channel/html.dart';

class HTMLWebsok extends Websok<HtmlWebSocketChannel> {
  /// controls what type is used for binary messages received by this socket.
  /// It defaults to [BinaryType.list], which causes binary messages to be delivered
  /// as [Uint8List]s. If it's [BinaryType.blob], they're delivered as [Blob]s instead.
  final BinaryType binaryType;

  /// Creates a new HTML web socket.
  HTMLWebsok({
    required String host,
    int? port,
    String path = '',
    Map<String, String> query = const <String, String>{},
    Iterable<String> protocols = const <String>[],
    this.binaryType = BinaryType.list,
    bool tls = false,
  }) : super(
          host: host,
          port: port,
          path: path,
          query: query,
          protocols: protocols,
          tls: tls,
        );

  /// Connects to the websocket given the following options. Keep in mind not all
  /// of them will be used, it depends on [C] (HtmlWebSocketChannel).
  HtmlWebSocketChannel connectWith(String url, Iterable<String> protocols) =>
      HtmlWebSocketChannel.connect(
        url,
        protocols: protocols,
        binaryType: this.binaryType,
      );
}
