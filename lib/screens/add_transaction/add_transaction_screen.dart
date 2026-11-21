import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/categories.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/finance_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? editing;
  const AddTransactionScreen({super.key, this.editing});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
  late final TextEditingController _title;
  late final TextEditingController _note;
  late String _type;
  String? _category;
  late DateTime _date;
  bool _saving = false;

  bool get _isEdit => widget.editing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _type = e?.type ?? TxType.expense;
    _category = e?.category;
    _date = e?.date ?? DateTime.now();
    _amount = TextEditingController(
        text: e == null ? '' : NumberFormat.decimalPattern('id_ID').format(e.amount.round()));
    _title = TextEditingController(text: e?.title ?? '');
    _note = TextEditingController(text: e?.note ?? '');
  }

  @override
  void dispose() {
    _amount.dispose();
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih kategori terlebih dahulu')));
      return;
    }
    setState(() => _saving = true);
    final fin = context.read<FinanceProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    final tx = TransactionModel(
      id: widget.editing?.id,
      title: _title.text.trim(),
      amount: ThousandsFormatter.parse(_amount.text),
      type: _type,
      category: _category!,
      date: _date,
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      createdAt: widget.editing?.createdAt,
    );
    try {
      if (_isEdit) {
        await fin.updateTransaction(tx);
      } else {
        await fin.addTransaction(tx);
      }
      HapticFeedback.lightImpact();
      messenger.showSnackBar(SnackBar(
          content: Text(_isEdit ? 'Transaksi berhasil diperbarui' : 'Transaksi berhasil disimpan')));
      nav.pop();
    } catch (e) {
      if (mounted) setState(() => _saving = false);
      messenger.showSnackBar(const SnackBar(content: Text('Gagal menyimpan transaksi. Coba lagi.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final cats = categoriesFor(_type);
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Ubah transaksi' : 'Transaksi baru')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.s, Gap.xl, Gap.xxl),
            children: [
              SegmentedButton<String>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: TxType.expense, label: Text('Pengeluaran')),
                  ButtonSegment(value: TxType.income, label: Text('Pemasukan')),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() {
                  _type = s.first;
                  if (!categoriesFor(_type).any((c) => c.name == _category)) _category = null;
                }),
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: p.primary,
                  selectedForegroundColor: onPrimary,
                  foregroundColor: p.text,
                  side: BorderSide(color: p.divider),
                ),
              ),
              const SizedBox(height: Gap.xl),
              Text('Jumlah', style: AppText.caption(context)),
              const SizedBox(height: Gap.s),
              TextFormField(
                controller: _amount,
                keyboardType: TextInputType.number,
                inputFormatters: [LengthLimitingTextInputFormatter(18), ThousandsFormatter()],
                style: AppText.heading(context).copyWith(fontSize: 26),
                decoration: const InputDecoration(prefixText: 'Rp ', hintText: '0'),
                validator: (v) {
                  final n = ThousandsFormatter.parse(v ?? '');
                  if ((v ?? '').isEmpty) return 'Jumlah wajib diisi';
                  if (n <= 0) return 'Jumlah harus lebih dari 0';
                  return null;
                },
              ),
              const SizedBox(height: Gap.l),
              TextFormField(
                controller: _title,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Judul transaksi'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: Gap.xl),
              Text('Kategori', style: AppText.caption(context)),
              const SizedBox(height: Gap.s),
              Wrap(
                spacing: Gap.s,
                runSpacing: Gap.s,
                children: [
                  for (final c in cats)
                    ChoiceChip(
                      avatar: Icon(c.icon, size: 16,
                          color: _category == c.name ? onPrimary : p.muted),
                      label: Text(c.name),
                      selected: _category == c.name,
                      showCheckmark: false,
                      selectedColor: p.primary,
                      backgroundColor: p.surface,
                      side: BorderSide(color: _category == c.name ? p.primary : p.divider),
                      labelStyle: TextStyle(
                          color: _category == c.name ? onPrimary : p.text, fontSize: 13),
                      onSelected: (_) => setState(() => _category = c.name),
                    ),
                ],
              ),
              const SizedBox(height: Gap.xl),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Tanggal'),
                  child: Row(children: [
                    Expanded(child: Text(Fmt.dayHeader(_date), style: AppText.body(context))),
                    Icon(Icons.calendar_today_outlined, size: 18, color: p.muted),
                  ]),
                ),
              ),
              const SizedBox(height: Gap.l),
              TextFormField(
                controller: _note,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Catatan (opsional)', alignLabelWithHint: true),
              ),
              const SizedBox(height: Gap.xl),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: onPrimary))
                    : Text(_isEdit ? 'Simpan perubahan' : 'Simpan transaksi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
