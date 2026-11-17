import 'package:flutter/material.dart';

void main() => runApp(const MuntahiApp());

const Color kPrimary = Color(0xFF6C5CE7);
const Color kPrimary2 = Color(0xFF8E7CFF);
const Color kBg = Color(0xFFF4F5FB);
const Color kText = Color(0xFF2D2A4A);
const Color kMuted = Color(0xFF9A9AB5);
const Color kSoft = Color(0xFFE6E2FF);

// ---------- البيانات ----------

class Alarm {
  final int id;
  final int category;
  final String title;
  final TimeOfDay time;
  final String repeat;
  const Alarm({
    required this.id,
    required this.category,
    required this.title,
    required this.time,
    required this.repeat,
  });
}

const List<List<String>> kCategories = [
  ['🕌', 'الفجر'],
  ['☀️', 'الظهر'],
  ['🌇', 'العصر'],
  ['🌆', 'المغرب'],
  ['🌙', 'العشاء'],
  ['💪', 'تمرين'],
  ['📚', 'مذاكرة'],
  ['📖', 'قرآن'],
  ['🎧', 'بودكاست'],
  ['📅', 'موعد'],
  ['💊', 'دواء'],
  ['📕', 'قراءة'],
];

const List<String> kRepeats = ['كل يوم', 'مرة واحدة', 'أيام العمل'];

final ValueNotifier<List<Alarm>> alarmsNotifier = ValueNotifier<List<Alarm>>([]);

String formatTime(TimeOfDay t) {
  final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
  final m = t.minute.toString().padLeft(2, '0');
  final p = t.period == DayPeriod.am ? 'ص' : 'م';
  return '$h:$m $p';
}

// ---------- التطبيق ----------

class MuntahiApp extends StatelessWidget {
  const MuntahiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'منتهي',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimary),
        scaffoldBackgroundColor: kBg,
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox(),
        );
      },
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final List<Widget> _pages = const [
    HomePage(),
    AlarmsPage(),
    PlaceholderPage(title: 'التحديات'),
    PlaceholderPage(title: 'الإحصائيات'),
    PlaceholderPage(title: 'الإعدادات'),
  ];

  void _openAdd() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const AddAlarmSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'منتهي',
          style: TextStyle(
            color: kPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 18),
                SizedBox(width: 4),
                Text('0', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: _pages),
      floatingActionButton: _index == 1
          ? FloatingActionButton(
              backgroundColor: kPrimary,
              foregroundColor: Colors.white,
              onPressed: _openAdd,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        backgroundColor: Colors.white,
        indicatorColor: kSoft,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: kPrimary),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.alarm),
            selectedIcon: Icon(Icons.alarm, color: kPrimary),
            label: 'التنبيهات',
          ),
          NavigationDestination(
            icon: Icon(Icons.track_changes),
            selectedIcon: Icon(Icons.track_changes, color: kPrimary),
            label: 'التحديات',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            selectedIcon: Icon(Icons.bar_chart, color: kPrimary),
            label: 'الإحصائيات',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: kPrimary),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}

// ---------- مكونات مشتركة ----------

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(title, style: const TextStyle(fontSize: 20, color: kMuted)),
    );
  }
}

class EmptyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  const EmptyCard({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: kMuted)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: kMuted, fontSize: 12)),
        ],
      ),
    );
  }
}

class AlarmTile extends StatelessWidget {
  final Alarm alarm;
  const AlarmTile({super.key, required this.alarm});

  void _delete() {
    alarmsNotifier.value =
        alarmsNotifier.value.where((a) => a.id != alarm.id).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(kCategories[alarm.category][0],
              style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alarm.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: kText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatTime(alarm.time)} · ${alarm.repeat}',
                  style: const TextStyle(color: kMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline, color: kMuted),
          ),
        ],
      ),
    );
  }
}

// ---------- الرئيسية ----------

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const List<List<String>> _prayers = [
    ['الفجر', '04:52'],
    ['الظهر', '11:41'],
    ['العصر', '14:40'],
    ['المغرب', '17:00'],
    ['العشاء', '18:20'],
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _summaryCard(),
        const SizedBox(height: 20),
        _sectionTitle('🕌 مواقيت الصلاة'),
        const SizedBox(height: 8),
        _prayerCard(),
        const SizedBox(height: 20),
        _sectionTitle('⏰ تنبيهات اليوم'),
        const SizedBox(height: 8),
        ValueListenableBuilder<List<Alarm>>(
          valueListenable: alarmsNotifier,
          builder: (context, list, _) {
            if (list.isEmpty) {
              return const EmptyCard(
                title: 'لا توجد تنبيهات اليوم',
                subtitle: 'من تبويب التنبيهات اضغط + لإضافة تنبيه',
              );
            }
            return Column(
              children: list.map((a) => AlarmTile(alarm: a)).toList(),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimary, kPrimary2],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الثلاثاء، 17 نوفمبر',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Stat(value: '0', label: 'نقطة'),
              _Stat(value: '0', label: 'يوم متواصل'),
              _Stat(value: '0', label: 'أطول سلسلة'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: kText,
      ),
    );
  }

  Widget _prayerCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE9E6FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: _prayers.map((p) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Text(p[0], style: const TextStyle(color: kText)),
                const Spacer(),
                Text(
                  p[1],
                  style: const TextStyle(
                    color: kPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

// ---------- التنبيهات ----------

class AlarmsPage extends StatelessWidget {
  const AlarmsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Alarm>>(
      valueListenable: alarmsNotifier,
      builder: (context, list, _) {
        if (list.isEmpty) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              EmptyCard(
                title: 'لسه مفيش تنبيهات',
                subtitle: 'اضغط + وإضافة أول تنبيه',
              ),
            ],
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: list.map((a) => AlarmTile(alarm: a)).toList(),
        );
      },
    );
  }
}

class AddAlarmSheet extends StatefulWidget {
  const AddAlarmSheet({super.key});

  @override
  State<AddAlarmSheet> createState() => _AddAlarmSheetState();
}

class _AddAlarmSheetState extends State<AddAlarmSheet> {
  int _cat = 0;
  final TextEditingController _titleCtrl = TextEditingController();
  TimeOfDay _time = const TimeOfDay(hour: 7, minute: 0);
  String _repeat = kRepeats[0];

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null && mounted) {
      setState(() => _time = picked);
    }
  }

  void _save() {
    final typed = _titleCtrl.text.trim();
    final alarm = Alarm(
      id: DateTime.now().millisecondsSinceEpoch,
      category: _cat,
      title: typed.isEmpty ? kCategories[_cat][1] : typed,
      time: _time,
      repeat: _repeat,
    );
    final list = [...alarmsNotifier.value, alarm];
    list.sort((a, b) => (a.time.hour * 60 + a.time.minute)
        .compareTo(b.time.hour * 60 + b.time.minute));
    alarmsNotifier.value = list;
    Navigator.pop(context);
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, color: kText),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '⏰ تنبيه جديد',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kText,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            _label('التصنيف'),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.1,
              children: List.generate(kCategories.length, (i) {
                final selected = i == _cat;
                return GestureDetector(
                  onTap: () => setState(() => _cat = i),
                  child: Container(
                    decoration: BoxDecoration(
                      color: selected ? kSoft : const Color(0xFFF1F2F8),
                      border: Border.all(
                        color: selected ? kPrimary : Colors.transparent,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(kCategories[i][0],
                            style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 2),
                        Text(kCategories[i][1],
                            style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                );
              }),
            ),
            _label('العنوان (اختياري)'),
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                hintText: 'مثال: صلاة الفجر',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            _label('الوقت'),
            InkWell(
              onTap: _pickTime,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD5D6E5)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(formatTime(_time)),
              ),
            ),
            _label('التكرار'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD5D6E5)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                value: _repeat,
                isExpanded: true,
                underline: const SizedBox(),
                items: kRepeats
                    .map((r) => DropdownMenuItem<String>(
                          value: r,
                          child: Text(r),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _repeat = v);
                },
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'حفظ التنبيه',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
