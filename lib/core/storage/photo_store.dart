import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Stores pet photos as files in the app's private documents directory; the
/// database keeps only the file name.
class PhotoStore {
  PhotoStore(this.directory);

  final Directory directory;

  /// Whether [name] is a plain file name inside the folder. Names come from
  /// the database, which a restored backup file controls, so anything with
  /// a path separator or "." / ".." must never reach the file system.
  static bool isSafeName(String name) =>
      name.isNotEmpty &&
      name.length <= 255 &&
      !name.startsWith('.') &&
      !name.contains(RegExp(r'[/\\\x00-\x1f]'));

  /// The file for [name], or null if the name is not safe.
  File? fileFor(String name) =>
      isSafeName(name) ? File(p.join(directory.path, name)) : null;

  Future<String> importFile(String sourcePath) async {
    var ext = p.extension(sourcePath).toLowerCase();
    if (!RegExp(r'^\.[a-z0-9]{1,5}$').hasMatch(ext)) ext = '.jpg';
    final name = '${const Uuid().v4()}$ext';
    await File(sourcePath).copy(p.join(directory.path, name));
    return name;
  }

  Future<void> delete(String name) async {
    final f = fileFor(name);
    if (f != null && await f.exists()) await f.delete();
  }
}

Future<PhotoStore> _storeIn(String folder) async {
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory(p.join(docs.path, folder));
  await dir.create(recursive: true);
  return PhotoStore(dir);
}

/// Pet profile photos. Folder name must match backup_service.dart and the
/// Android backup rules.
final photoStoreProvider = FutureProvider<PhotoStore>(
  (ref) => _storeIn('pet_photos'),
);

/// Photos attached to care records.
final attachmentStoreProvider = FutureProvider<PhotoStore>(
  (ref) => _storeIn('attachments'),
);
