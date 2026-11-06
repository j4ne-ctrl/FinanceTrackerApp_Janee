import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/categories.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/user_avatar.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email = currentUser?.email ?? '-';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 130),
      children: [
        Text('Profil',
            style:
                GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w700)),
        const SizedBox(height: 18),
        UserProfileBuilder(
          builder: (context, p) => Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.glossColors,
              ),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8), width: 1.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              children: [
                UserAvatar.fromProfile(p, size: 92),
                const SizedBox(height: 14),
                Text(p.name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.w700)),
                Text(email,
                    style: GoogleFonts.poppins(
                        fontSize: 12.5, color: AppColors.muted)),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => EditProfileScreen(profile: p)),
                  ),
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: const Text('Edit Profil'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 112,
          child: TxStreamBuilder(
            builder: (context, list) {
              final income = list
                  .where((t) => t.type == TxType.income)
                  .fold<int>(0, (s, t) => s + t.amount);
              final expense = list
                  .where((t) => t.type == TxType.expense)
                  .fold<int>(0, (s, t) => s + t.amount);
              return Row(
                children: [
                  Expanded(
                    child: _InfoTile(
                      color: const Color(0xFFD8ECFD),
                      label: 'Transaksi tercatat',
                      value: '${list.length}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InfoTile(
                      color: const Color(0xFFFDEFD6),
                      label: 'Saldo saat ini',
                      value: rupiah(income - expense),
                      small: true,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 22),
        PrimaryButton(
          label: 'Keluar',
          icon: Icons.logout_rounded,
          color: AppColors.expense,
          onPressed: () => confirmLogout(context),
        ),
        const SizedBox(height: 18),
        
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final bool small;
  const _InfoTile(
      {required this.color,
      required this.label,
      required this.value,
      this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.muted)),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: GoogleFonts.poppins(
                    fontSize: small ? 18 : 28, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}