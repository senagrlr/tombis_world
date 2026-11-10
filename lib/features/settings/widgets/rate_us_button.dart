
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/external_links.dart';
import '../../../core/theme/app_colors.dart';

class RateUsButton extends StatelessWidget {
  const RateUsButton({super.key});

  Future<void> _openStore(BuildContext context) async {
    if (ExternalLinks.playStore.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon!')),
      );
      return;
    }

    final uri = Uri.parse(ExternalLinks.playStore);
    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Play Store')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _openStore(context),
      icon: const Icon(Icons.star_rounded,
          color: Color(0xFFFFD33F), size: 32),
      label: const Text(
        'Rate us',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: AppColors.darkBrown,
        ),
      ),
    );
  }
}
