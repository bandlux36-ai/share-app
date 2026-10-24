import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/share_theme.dart';
import '../../../core/widgets/share_logo.dart';
import '../../auth/data/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.authService});
  final AuthService authService;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _Platform {
  const _Platform(this.name, this.icon, this.color);
  final String name;
  final FaIconData icon;
  final Color color;
}

class _Content {
  const _Content(this.name, this.image);
  final String name;
  final Uint8List? image;
}

class _HomeScreenState extends State<HomeScreen> {
  static const _platforms = [
    _Platform('فيسبوك', FontAwesomeIcons.facebookF, Color(0xFF1877F2)),
    _Platform('تيك توك', FontAwesomeIcons.tiktok, Colors.black),
    _Platform('إكس', FontAwesomeIcons.xTwitter, Colors.black),
    _Platform('إنستقرام', FontAwesomeIcons.instagram, Color(0xFFDD2A7B)),
    _Platform('بينترست', FontAwesomeIcons.pinterestP, Color(0xFFE60023)),
    _Platform('لينكدإن', FontAwesomeIcons.linkedinIn, Color(0xFF0077B5)),
    _Platform('سناب شات', FontAwesomeIcons.snapchat, Color(0xFFFFEB00)),
    _Platform('يوتيوب', FontAwesomeIcons.youtube, Color(0xFFFF0033)),
    _Platform('واتساب', FontAwesomeIcons.whatsapp, Color(0xFF00C853)),
    _Platform('تيليجرام', FontAwesomeIcons.telegram, Color(0xFF20A8E0)),
    _Platform('ثريدز', FontAwesomeIcons.threads, Colors.black),
  ];
  final _selected = <int>{for (var i = 0; i < 11; i++) i};
  final List<_Content?> _content = [null, null, null];
  int _tab = 0;
  bool _signingOut = false;
  int? _picking;
  void _message(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
  Future<void> _signOut() async {
    if (_signingOut) return;
    setState(() => _signingOut = true);
    try {
      await widget.authService.signOut();
    } catch (e) {
      if (mounted) {
        _message(
          e is AuthFailure ? e.message : 'تعذّر تسجيل الخروج. حاول مرة أخرى.',
        );
      }
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  Future<void> _pick(int index) async {
    if (_picking != null) return;
    setState(() => _picking = index);
    try {
      final file = await openFile(
        acceptedTypeGroups: [
          const XTypeGroup(
            label: 'صور وفيديو',
            extensions: ['jpg', 'jpeg', 'png', 'webp', 'mp4', 'mov', 'webm'],
            mimeTypes: [
              'image/jpeg',
              'image/png',
              'image/webp',
              'video/mp4',
              'video/quicktime',
              'video/webm',
            ],
          ),
        ],
      );
      if (file == null || !mounted) return;
      final image = RegExp(
        r'\.(jpe?g|png|webp)$',
        caseSensitive: false,
      ).hasMatch(file.name);
      if (await file.length() > (image ? 10 : 100) * 1024 * 1024) {
        if (mounted) {
          _message(
            image
                ? 'اختر صورة لا تتجاوز 10 ميجابايت.'
                : 'اختر فيديو لا يتجاوز 100 ميجابايت.',
          );
        }
        return;
      }
      final bytes = image ? await file.readAsBytes() : null;
      if (mounted) setState(() => _content[index] = _Content(file.name, bytes));
    } catch (_) {
      if (mounted) _message('تعذّر فتح الملف. حاول اختيار ملف آخر.');
    } finally {
      if (mounted) setState(() => _picking = null);
    }
  }

  void _prepare(int? index) {
    if (index != null && _content[index] == null) {
      _pick(index);
      return;
    }
    if (!_content.any((e) => e != null)) {
      _message('اختر محتوى من جهازك أولًا.');
      return;
    }
    if (_selected.isEmpty) {
      _message('اختر منصة واحدة على الأقل.');
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'محتواك جاهز للمعاينة',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: ShareTheme.navy,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _content.whereType<_Content>().map((e) => e.name).join('\n'),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              const Text(
                'اربط حساباتك بالمنصات قبل النشر. ربط المنصات والنشر غير متاحين حاليًا، ولم يتم إرسال ملفاتك.',
                style: TextStyle(height: 1.8),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  _manage();
                },
                child: const Text('إدارة المنصات'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _manage() => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .65,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'إدارة المنصات',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'اختر منصات النشر في الرئيسية. ربط الحسابات سيتوفر لاحقًا.',
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  for (final p in _platforms)
                    ListTile(
                      leading: FaIcon(
                        p.icon,
                        color: p.color == Colors.black
                            ? ShareTheme.navy
                            : p.color,
                      ),
                      title: Text(p.name),
                      trailing: const Text(
                        'غير مرتبط',
                        style: TextStyle(color: ShareTheme.muted),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  Widget _card(int index) {
    final item = _content[index];
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [ShareTheme.warmShadow],
      ),
      child: Column(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _pick(index),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFDFE2E8)),
                  borderRadius: BorderRadius.circular(18),
                ),
                clipBehavior: Clip.antiAlias,
                child: _picking == index
                    ? const Center(child: CircularProgressIndicator())
                    : item?.image != null
                    ? Image.memory(
                        item!.image!,
                        fit: BoxFit.cover,
                        cacheWidth: 400,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.broken_image_outlined,
                          color: ShareTheme.muted,
                        ),
                      )
                    : Icon(
                        item == null
                            ? Icons.image_outlined
                            : Icons.video_library_outlined,
                        size: 48,
                        color: ShareTheme.muted,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item?.name ?? 'ارفع محتواك من جهازك',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: ShareTheme.muted),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: IconButton.filledTonal(
              tooltip: item == null
                  ? 'اختيار المحتوى ${index + 1}'
                  : 'معاينة المحتوى ${index + 1}',
              onPressed: () => _prepare(index),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFFFFCF6),
                foregroundColor: ShareTheme.navy,
              ),
              icon: const FaIcon(FontAwesomeIcons.paperPlane, size: 21),
            ),
          ),
        ],
      ),
    );
  }

  Widget _platform(int index) {
    if (index == _platforms.length) {
      return InkWell(
        onTap: _manage,
        borderRadius: BorderRadius.circular(18),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 27,
              backgroundColor: Color(0xFFF5F6F8),
              child: Icon(Icons.add, color: ShareTheme.muted, size: 30),
            ),
            SizedBox(height: 7),
            Text(
              'إضافة منصة',
              style: TextStyle(fontSize: 11, color: ShareTheme.navy),
            ),
          ],
        ),
      );
    }
    final p = _platforms[index];
    final selected = _selected.contains(index);
    return Semantics(
      button: true,
      selected: selected,
      label: p.name,
      child: InkWell(
        onTap: () => setState(() {
          if (selected) {
            _selected.remove(index);
          } else {
            _selected.add(index);
          }
        }),
        borderRadius: BorderRadius.circular(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: p.color,
                    gradient: index == 3
                        ? const LinearGradient(
                            colors: [
                              Color(0xFF833AB4),
                              Color(0xFFFD1D1D),
                              Color(0xFFFCAF45),
                            ],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          )
                        : null,
                  ),
                  child: Center(
                    child: FaIcon(
                      p.icon,
                      color: index == 6 ? Colors.black : Colors.white,
                      size: 31,
                    ),
                  ),
                ),
                if (selected)
                  Positioned(
                    bottom: -3,
                    right: -3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: ShareTheme.yellow,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 13,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              p.name,
              style: const TextStyle(fontSize: 11, color: ShareTheme.navy),
            ),
          ],
        ),
      ),
    );
  }

  Widget _home() => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(18, 6, 18, 20),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                PopupMenuButton<String>(
                  tooltip: 'الحساب',
                  onSelected: (_) => _signOut(),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'logout',
                      enabled: !_signingOut,
                      child: const Text('تسجيل الخروج'),
                    ),
                  ],
                  child: const CircleAvatar(
                    radius: 23,
                    backgroundColor: Color(0xFFF3F4F5),
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: ShareTheme.muted,
                    ),
                  ),
                ),
                const Expanded(
                  child: SizedBox(
                    height: 88,
                    child: FittedBox(fit: BoxFit.contain, child: ShareLogo()),
                  ),
                ),
                IconButton(
                  tooltip: 'التنبيهات',
                  onPressed: () => setState(() => _tab = 2),
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: ShareTheme.navy,
                    size: 29,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'ارفع محتواك .. وانشره في كل مكان',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: ShareTheme.heading,
                ),
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              'صور، فيديوهات .. إلى جميع منصاتك بسهولة',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: ShareTheme.muted),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 216,
              child: Row(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(child: _card(i)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'منصات النشر',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                      color: ShareTheme.heading,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _manage,
                  icon: const Icon(Icons.settings_outlined, size: 19),
                  label: const Text(
                    'إدارة المنصات',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
            const Text(
              'اختر المنصات التي تريد النشر عليها',
              style: TextStyle(fontSize: 13, color: ShareTheme.muted),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 12,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisExtent: 100,
                crossAxisSpacing: 5,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (_, i) => _platform(i),
            ),
          ],
        ),
      ),
    ),
  );
  Widget _profile() => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 42,
            child: Icon(Icons.person_outline_rounded, size: 48),
          ),
          const SizedBox(height: 20),
          const Text(
            'مرحبًا بك في شير',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: ShareTheme.navy,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _signingOut ? null : _signOut,
            child: _signingOut
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      semanticsLabel: 'جارٍ تسجيل الخروج',
                    ),
                  )
                : const Text('تسجيل الخروج'),
          ),
        ],
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: switch (_tab) {
        0 => _home(),
        1 => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FaIcon(
                  FontAwesomeIcons.paperPlane,
                  size: 55,
                  color: ShareTheme.yellow,
                ),
                const SizedBox(height: 20),
                const Text(
                  'جهّز محتواك للنشر',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: ShareTheme.navy,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'اختر محتواك ومنصاتك من الرئيسية، ثم راجعها هنا.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => _prepare(null),
                  child: const Text('معاينة المحتوى'),
                ),
              ],
            ),
          ),
        ),
        2 => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                size: 54,
                color: ShareTheme.muted,
              ),
              SizedBox(height: 16),
              Text(
                'لا توجد تنبيهات حتى الآن',
                style: TextStyle(fontSize: 19, color: ShareTheme.navy),
              ),
            ],
          ),
        ),
        _ => _profile(),
      },
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab,
      onDestinationSelected: (i) => setState(() => _tab = i),
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFFFFF7DE),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded, color: ShareTheme.yellow),
          label: 'الرئيسية',
        ),
        NavigationDestination(
          icon: FaIcon(FontAwesomeIcons.paperPlane, size: 23),
          label: 'شير',
        ),
        NavigationDestination(
          icon: Icon(Icons.notifications_none_rounded),
          label: 'التنبيهات',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          label: 'الملف الشخصي',
        ),
      ],
    ),
  );
}
