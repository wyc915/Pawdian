import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/domain/enums.dart';
import '../../core/storage/photo_store.dart';
import '../../core/theme/app_theme.dart';

IconData speciesIcon(Species s) => switch (s) {
  Species.bird => Icons.flutter_dash,
  Species.reptile => Icons.pest_control_rodent_outlined,
  _ => Icons.pets,
};

class PetAvatar extends ConsumerWidget {
  const PetAvatar({
    super.key,
    required this.pet,
    this.radius = 24,
    this.ring = false,
  });

  final Pet pet;
  final double radius;

  /// White ring around the avatar (on coloured backgrounds).
  final bool ring;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tone = context.paw.petTone(pet.id);
    final photo = pet.photoFile;
    ImageProvider? image;
    if (photo != null) {
      final store = ref.watch(photoStoreProvider).value;
      final file = store?.fileFor(photo);
      if (file != null) image = FileImage(file);
    }
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: tone.bg,
      foregroundImage: image,
      child: Icon(speciesIcon(pet.species), size: radius, color: tone.fg),
    );
    if (!ring) return avatar;
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: avatar,
    );
  }
}
