import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/domain/enums.dart';
import '../../core/storage/photo_store.dart';

IconData speciesIcon(Species s) => switch (s) {
  Species.bird => Icons.flutter_dash,
  Species.reptile => Icons.pest_control_rodent_outlined,
  _ => Icons.pets,
};

class PetAvatar extends ConsumerWidget {
  const PetAvatar({super.key, required this.pet, this.radius = 24});

  final Pet pet;
  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final photo = pet.photoFile;
    ImageProvider? image;
    if (photo != null) {
      final store = ref.watch(photoStoreProvider).value;
      final file = store?.fileFor(photo);
      if (file != null) image = FileImage(file);
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primaryContainer,
      foregroundImage: image,
      child: Icon(
        speciesIcon(pet.species),
        size: radius,
        color: scheme.onPrimaryContainer,
      ),
    );
  }
}
