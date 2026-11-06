import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/categories.dart';
import '../models/transaction_model.dart';
import '../screens/transaction_detail_screen.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel tx;
  const TransactionTile({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final cat = Categories.find(tx.category, tx.type);
    final color = tx.isIncome ? AppColors.income : AppColors.expense;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => TransactionDetailScreen(id: tx.id)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: cat.color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(cat.icon, color: cat.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${tx.category} • ${tanggalPendek(tx.date)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                            fontSize: 11.5, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${tx.isIncome ? '+' : '-'}${rupiah(tx.amount)}',
                  style: GoogleFonts.poppins(
                      fontSize: 13.5, fontWeight: FontWeight.w700, color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
