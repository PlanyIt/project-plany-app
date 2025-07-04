import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool multiline;
  final VoidCallback? onEdit;
  final Widget? trailing;

  const InfoRow({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.multiline = false,
    this.onEdit,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment:
            multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey[700],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
          if (onEdit != null)
            IconButton(
              icon: const Icon(
                Icons.edit,
                size: 18,
                color: Color(0xFF3425B5),
              ),
              onPressed: onEdit,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
            ),
        ],
      ),
    );
  }
}

class ActionRow extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const ActionRow({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: Colors.grey[700],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 15),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}

class SwitchRow extends StatelessWidget {
  final String title;
  final bool value;
  final IconData icon;
  final ValueChanged<bool> onChanged;

  const SwitchRow({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey[700],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF3425B5),
          ),
        ],
      ),
    );
  }
}

class PremiumStatusRow extends StatelessWidget {
  final bool isPremium;
  final VoidCallback onTap;

  const PremiumStatusRow({
    Key? key,
    required this.isPremium,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isPremium
              ? Colors.amber.withValues(alpha: 0.1)
              : const Color(0xFF3425B5).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPremium
                ? Colors.amber
                : const Color(0xFF3425B5).withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.workspace_premium,
              size: 20,
              color: isPremium ? Colors.amber[700] : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPremium ? 'Premium Actif' : 'Devenir Premium',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isPremium
                          ? Colors.amber[700]
                          : const Color(0xFF3425B5),
                    ),
                  ),
                  Text(
                    isPremium
                        ? 'Vous bénéficiez de toutes les fonctionnalités'
                        : 'Débloquez toutes les fonctionnalités',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isPremium
                    ? Colors.amber.withValues(alpha: 0.2)
                    : const Color(0xFF3425B5).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isPremium ? 'ACTIF' : 'UPGRADE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color:
                      isPremium ? Colors.amber[700] : const Color(0xFF3425B5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
