import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/settings_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const appVersion = '1.0.0';

  Future<void> _editName(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    final ctrl = TextEditingController(text: settings.userName);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nama panggilan'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Nama Anda'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('Simpan')),
        ],
      ),
    );
    ctrl.dispose();
    if (name != null) await settings.setUserName(name);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final p = context.palette;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.l, Gap.xl, 120),
        children: [
          Text('Profil', style: AppText.heading(context)),
          const SizedBox(height: Gap.xl),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: p.primary,
                child: Text(settings.userName.characters.first.toUpperCase(),
                    style: AppText.section(context).copyWith(color: onPrimary, fontSize: 24)),
              ),
              const SizedBox(width: Gap.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(settings.userName, style: AppText.section(context)),
                    Text('Pengguna TeukuCash', style: AppText.caption(context)),
                  ],
                ),
              ),
              IconButton(
                  tooltip: 'Ubah nama',
                  onPressed: () => _editName(context),
                  icon: Icon(Icons.edit_outlined, color: p.muted)),
            ],
          ),
          const SizedBox(height: Gap.xxl),
          Text('TAMPILAN', style: AppText.overline(context)),
          const SizedBox(height: Gap.m),
          SegmentedButton<ThemeMode>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: ThemeMode.light, label: Text('Terang'), icon: Icon(Icons.light_mode_outlined)),
              ButtonSegment(value: ThemeMode.dark, label: Text('Gelap'), icon: Icon(Icons.dark_mode_outlined)),
              ButtonSegment(value: ThemeMode.system, label: Text('Sistem'), icon: Icon(Icons.settings_suggest_outlined)),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (s) => settings.setThemeMode(s.first),
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: p.primary,
              selectedForegroundColor: onPrimary,
              foregroundColor: p.text,
              side: BorderSide(color: p.divider),
            ),
          ),
          const SizedBox(height: Gap.xxl),
          Text('TENTANG', style: AppText.overline(context)),
          const SizedBox(height: Gap.s),
          _InfoRow(label: 'Aplikasi', value: 'TeukuCash'),
          const Divider(),
          _InfoRow(label: 'Versi', value: appVersion),
          const Divider(),
          _InfoRow(label: 'Mata uang', value: 'Rupiah (IDR)'),
          const Divider(),
          _InfoRow(label: 'Penyimpanan', value: 'Lokal (SQLite)'),
          const SizedBox(height: Gap.l),
          Text(
            'TeukuCash membantu Anda mencatat pemasukan dan pengeluaran, memantau anggaran bulanan, '
            'dan memahami pola keuangan. Semua data tersimpan di perangkat Anda.',
            style: AppText.caption(context).copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Gap.m),
      child: Row(children: [
        Expanded(child: Text(label, style: AppText.body(context))),
        Text(value, style: AppText.caption(context).copyWith(fontSize: 13.5)),
      ]),
    );
  }
}
