import 'package:cloud_firestore/cloud_firestore.dart';
import 'categories.dart';

class TransactionModel {
  final String id;
  final String title;
  final int amount;
  final TxType type;
  final String category;
  final String note;
  final DateTime date;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.note,
    required this.date,
  });

  bool get isIncome => type == TxType.income;

  factory TransactionModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data() ?? {};
    return TransactionModel(
      id: doc.id,
      title: (m['title'] ?? '') as String,
      amount: ((m['amount'] ?? 0) as num).toInt(),
      type: m['type'] == 'income' ? TxType.income : TxType.expense,
      category: (m['category'] ?? 'Lainnya') as String,
      note: (m['note'] ?? '') as String,
      date: (m['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'amount': amount,
        'type': isIncome ? 'income' : 'expense',
        'category': category,
        'note': note,
        'date': Timestamp.fromDate(date),
      };
}
