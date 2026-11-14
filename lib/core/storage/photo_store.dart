import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Where pet photos and attachments live. The database keeps only the file
/// name; the phone app stores files locally, the web edition on the home
/// server.
abstract interface class ImageStore {
  /// Image for a stored [name], or null if the name is not safe.
  ImageProvider? imageFor(String name);

  /// Copies a picked file (path or browser blob URL) in; returns its name.
  Future<String> importFile(String sourcePath);

  Future<void> delete(String name);
}

/// Preview of a file the user just picked, before it is saved.
ImageProvider pickedImage(String path) =>
    kIsWeb ? NetworkImage(path) : FileImage(File(path));

/// Stores pet photos as files in the app's private documents directory.
class PhotoStore implements ImageStore {
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

  @override
  ImageProvider? imageFor(String name) {
    final f = fileFor(name);
    return f == null ? null : FileImage(f);
  }

  @override
  Future<String> importFile(String sourcePath) async {
    var ext = p.extension(sourcePath).toLowerCase();
    if (!RegExp(r'^\.[a-z0-9]{1,5}$').hasMatch(ext)) ext = '.jpg';
    final name = '${const Uuid().v4()}$ext';
    await File(sourcePath).copy(p.join(directory.path, name));
    return name;
  }

  @override
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
final photoStoreProvider = FutureProvider<ImageStore>(
  (ref) => _storeIn('pet_photos'),
);

/// Photos attached to care records.
final attachmentStoreProvider = FutureProvider<ImageStore>(
  (ref) => _storeIn('attachments'),
);
