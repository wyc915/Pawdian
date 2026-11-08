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

  File fileFor(String name) => File(p.join(directory.path, name));

  Future<String> importFile(String sourcePath) async {
    final ext = p.extension(sourcePath).toLowerCase();
    final name = '${const Uuid().v4()}${ext.isEmpty ? '.jpg' : ext}';
    await File(sourcePath).copy(fileFor(name).path);
    return name;
  }

  Future<void> delete(String name) async {
    final f = fileFor(name);
    if (await f.exists()) await f.delete();
  }
}

final photoStoreProvider = FutureProvider<PhotoStore>((ref) async {
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory(p.join(docs.path, 'pet_photos'));
  await dir.create(recursive: true);
  return PhotoStore(dir);
});
