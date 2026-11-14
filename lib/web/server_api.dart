import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:cross_file/cross_file.dart';
import 'package:uuid/uuid.dart';

import '../core/storage/photo_store.dart';

/// Talks to the Pawdian home server (web edition only).
class ServerApi {
  ServerApi(this.base, this.passcode, {http.Client? client})
    : _client = client ?? http.Client();

  /// Origin the web app was loaded from, e.g. https://pc.tailnet.ts.net:9443
  final Uri base;
  final String passcode;
  final http.Client _client;

  Map<String, String> get _headers => {'X-Pawdian-Token': passcode};

  // Built from parts: Uri.replace keeps a fragment, and WebSocket URLs
  // must not have one.
  Uri _api(String path, [Map<String, String>? query]) => Uri(
    scheme: base.scheme,
    host: base.host,
    port: base.port,
    path: '/api/$path',
    queryParameters: query,
  );

  /// WebSocket URL of the shared database.
  Uri get databaseSocket => Uri(
    scheme: base.scheme == 'https' ? 'wss' : 'ws',
    host: base.host,
    port: base.port,
    path: '/api/db',
    queryParameters: {'token': passcode},
  );

  /// Whether the server is reachable and accepts the passcode.
  Future<bool> ping() async {
    try {
      final res = await _client.get(_api('ping'), headers: _headers);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Uri fileUrl(String dir, String name) =>
      _api('files/$dir/$name', {'token': passcode});

  Future<void> putFile(String dir, String name, List<int> bytes) async {
    final res = await _client.put(
      _api('files/$dir/$name'),
      headers: _headers,
      body: bytes,
    );
    _check(res);
  }

  Future<void> deleteFile(String dir, String name) async {
    final res = await _client.delete(
      _api('files/$dir/$name'),
      headers: _headers,
    );
    _check(res);
  }

  Future<String> pushKey() async {
    final res = await _client.get(_api('push/key'), headers: _headers);
    _check(res);
    return (jsonDecode(res.body) as Map)['key'] as String;
  }

  Future<void> subscribe(Map<String, Object?> subscription) =>
      _post('push/subscribe', subscription);

  Future<void> unsubscribe(String endpoint) =>
      _post('push/unsubscribe', {'endpoint': endpoint});

  Future<void> putSchedule(List<Map<String, Object?>> items) async {
    final res = await _client.put(
      _api('push/schedule'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({'items': items}),
    );
    _check(res);
  }

  /// Sends a test notification; returns how many devices accepted it.
  Future<int> testPush(String title, String body) async {
    final res = await _client.post(
      _api('push/test'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'body': body}),
    );
    _check(res);
    return ((jsonDecode(res.body) as Map)['sent'] as num).toInt();
  }

  Future<void> _post(String path, Object body) async {
    final res = await _client.post(
      _api(path),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    _check(res);
  }

  static void _check(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ServerException(res.statusCode);
    }
  }
}

class ServerException implements Exception {
  const ServerException(this.status);

  final int status;

  @override
  String toString() => 'Server returned HTTP $status';
}

/// Only overridden in the web edition.
final serverApiProvider = Provider<ServerApi?>((ref) => null);

/// Photos and attachments stored on the home server.
class RemoteImageStore implements ImageStore {
  RemoteImageStore(this.api, this.dir);

  final ServerApi api;
  final String dir;

  @override
  ImageProvider? imageFor(String name) => PhotoStore.isSafeName(name)
      ? NetworkImage(api.fileUrl(dir, name).toString())
      : null;

  @override
  Future<String> importFile(String sourcePath) async {
    final bytes = await XFile(sourcePath).readAsBytes();
    var ext = p.extension(sourcePath).toLowerCase();
    if (!RegExp(r'^\.[a-z0-9]{1,5}$').hasMatch(ext)) ext = '.jpg';
    final name = '${const Uuid().v4()}$ext';
    await api.putFile(dir, name, bytes);
    return name;
  }

  @override
  Future<void> delete(String name) async {
    if (!PhotoStore.isSafeName(name)) return;
    try {
      await api.deleteFile(dir, name);
    } catch (_) {
      // The record is already gone; a leftover file is harmless.
    }
  }
}
