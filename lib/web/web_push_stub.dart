import 'server_api.dart';
import 'web_push.dart';

/// Only the web build creates a Web Push gateway.
WebPushGateway createWebPushGateway(ServerApi api) =>
    throw UnsupportedError('Web Push is only available in the web edition');
