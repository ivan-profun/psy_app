import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/firebase_service.dart';
import '../../core/l10n/app_localizations.dart';

class AvatarPicker extends StatelessWidget {
  final String? currentAvatarUrl;
  final double size;
  final bool canEdit;

  const AvatarPicker({
    super.key,
    this.currentAvatarUrl,
    this.size = 80,
    this.canEdit = true,
  });

  Future<String?> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 85,
    );

    if (image == null) return null;

    final file = File(image.path);
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> _uploadAvatar(BuildContext context, String base64Image) async {
    try {
      final firebaseService = context.read<FirebaseService>();
      await firebaseService.updateUserAvatar(base64Image);
      
      if (context.mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations?.translate('avatar_updated') ?? 'Аватарка успешно обновлена'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations?.translate('avatar_error') ?? 'Ошибка загрузки аватарки'}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: canEdit ? () async {
        final base64Image = await _pickImage(context);
        if (base64Image != null && context.mounted) {
          await _uploadAvatar(context, base64Image);
        }
      } : null,
      child: Stack(
        children: [
          CircleAvatar(
            radius: size / 2,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            backgroundImage: currentAvatarUrl != null
                ? MemoryImage(base64Decode(currentAvatarUrl!))
                : null,
            child: currentAvatarUrl == null
                ? Icon(
                    Icons.person,
                    size: size * 0.6,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
          ),
          if (canEdit)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
