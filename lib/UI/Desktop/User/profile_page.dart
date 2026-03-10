import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'dart:math' as math;
import 'package:vault/Helper/auth.dart';
import 'package:vault/Helper/theme_helper.dart';
import 'package:vault/Providers/library_provider.dart';
import 'package:vault/UI/Authentication/login_page.dart';
import 'package:vault/UI/Desktop/Details/anime_detail_page.dart';
import 'package:vault/UI/Desktop/Details/game_detail_page.dart';
import 'package:vault/UI/Desktop/Details/movie_detail_page.dart';
import 'package:vault/UI/Desktop/Details/serie_detail_page.dart';
import 'package:vault/Widgets/custom_app_window.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vault/Services/database_service.dart';
import 'package:vault/Services/firebase_database_impl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user = FirebaseAuth.instance.currentUser;
  final AuthService _auth = AuthService();
  final DatabaseService _database = FirebaseDatabaseImpl();
  final firebase = FirebaseStorage.instance;
  int _reloadToken = 0;
  @override
  void initState() {
    getUser();
    super.initState();
  }

  void getUser() async {
    user = FirebaseAuth.instance.currentUser;
    setState(() {});
  }

  Future<Map<String, dynamic>?> _loadProfile() async {
    final uid = user?.uid;
    if (uid == null) return null;
    return _database.getUserDocument(uid);
  }

  void _reload() {
    setState(() {
      _reloadToken += 1;
    });
  }

  Future<void> _pickAndUploadAvatar() async {
    final uid = user?.uid;
    if (uid == null) return;

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      lockParentWindow: true,
      dialogTitle: "Pick an image",
      type: FileType.image,
    );
    if (result == null) return;

    final path = result.files.single.path;
    if (path == null) return;
    final file = File(path);
    final bytes = await file.readAsBytes();

    final storagePath = "profiles/$uid/avatar.jpg";
    await firebase.ref(storagePath).putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
    final url = await firebase.ref(storagePath).getDownloadURL();

    await _database.updateProfileCustomization(
      uid: uid,
      profileImageUrl: url,
    );
    _reload();
  }

  Future<void> _changeBannerFromLibrary(
    LibraryProvider libraryProvider,
    Map<String, dynamic> profile,
  ) async {
    final uid = user?.uid;
    if (uid == null) return;

    final candidates = <_BannerCandidate>[];
    for (final entry in libraryProvider.libraryMap.entries) {
      final key = entry.key.toString();
      final raw = entry.value;
      if (raw is! Map) continue;
      final m = Map<String, dynamic>.from(raw);
      final type = m['type']?.toString();
      if (type != 'game' && type != 'anime') continue;
      final imageUrl = m['imageURL']?.toString();
      if (imageUrl == null || imageUrl.isEmpty) continue;
      final title = m['title']?.toString() ?? key;
      candidates.add(_BannerCandidate(
        key: key,
        title: title,
        imageUrl: imageUrl,
      ));
    }

    candidates.sort((a, b) => a.title.compareTo(b.title));

    final selected = await showDialog<_BannerCandidate>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text(
            "Banner Seç (Oyun/Anime)",
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: 900,
            height: 520,
            child: candidates.isEmpty
                ? const Center(
                    child: Text(
                      "Kütüphanede uygun içerik bulunamadı.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.7,
                    ),
                    itemCount: candidates.length,
                    itemBuilder: (context, index) {
                      final item = candidates[index];
                      return InkWell(
                        onTap: () => Navigator.pop(context, item),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CachedNetworkImage(
                                  imageUrl: item.imageUrl,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      Container(color: const Color(0xFF222222)),
                                ),
                              ),
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withValues(alpha: 0.05),
                                        Colors.black.withValues(alpha: 0.75),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 10,
                                right: 10,
                                bottom: 10,
                                child: Text(
                                  item.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Vazgeç"),
            ),
          ],
        );
      },
    );

    if (selected == null) return;

    try {
      await _database.updateProfileCustomization(
        uid: uid,
        backgroundUrl: selected.imageUrl,
      );
      _reload();
    } catch (e) {
      final settings = (profile['settings'] as Map?) ?? {};
      final last = settings['lastBackgroundChange'];
      DateTime? next;
      if (last is Timestamp) {
        next = last.toDate().add(const Duration(days: 30));
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            next == null
                ? "Banner değişimi şu an yapılamıyor."
                : "Banner ayda 1 kez değiştirilebilir. Sonraki hak: ${next.toLocal()}",
          ),
        ),
      );
    }
  }

  Future<void> _editHandle(String currentHandle) async {
    final uid = user?.uid;
    if (uid == null) return;
    final controller = TextEditingController(text: currentHandle);
    final handle = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text(
            "Profil Handle",
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "örn: biokzm",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Vazgeç"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text("Kaydet"),
            ),
          ],
        );
      },
    );
    if (handle == null) return;
    await _database.updateProfileCustomization(uid: uid, handle: handle);
    _reload();
  }

  Future<void> _editShowcases(
    Map<String, dynamic> profileData,
    LibraryProvider libraryProvider,
  ) async {
    final uid = user?.uid;
    if (uid == null) return;

    final showcases = (profileData['showcases'] as Map?)
            ?.map((k, v) => MapEntry(k.toString(), v))
            .cast<String, dynamic>() ??
        <String, dynamic>{};
    final enabled = (showcases['enabled'] as Map?)
            ?.map((k, v) => MapEntry(k.toString(), v))
            .cast<String, dynamic>() ??
        <String, dynamic>{};

    bool favEnabled = enabled['favoriteCollection'] == true;
    bool rareEnabled = enabled['rareAchievements'] == true;
    bool screenshotEnabled = enabled['screenshotGallery'] == true;

    final currentFavKeys = (showcases['favoriteCollection'] is List)
        ? (showcases['favoriteCollection'] as List)
            .map((e) => e.toString())
            .toList()
        : <String>[];
    final selectedFav = currentFavKeys.toSet();

    final allItems = <_LibraryCandidate>[];
    for (final entry in libraryProvider.libraryMap.entries) {
      final key = entry.key.toString();
      final raw = entry.value;
      if (raw is! Map) continue;
      final m = Map<String, dynamic>.from(raw);
      final title = m['title']?.toString() ?? key;
      final imageUrl = m['imageURL']?.toString();
      allItems.add(_LibraryCandidate(
        compoundKey: key,
        title: title,
        imageUrl: imageUrl,
      ));
    }
    allItems.sort((a, b) => a.title.compareTo(b.title));

    final result = await showDialog<_ShowcaseEditResult>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: const Text(
              "Vitrin Ayarları",
              style: TextStyle(color: Colors.white),
            ),
            content: SizedBox(
              width: 950,
              height: 620,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    value: favEnabled,
                    onChanged: (v) => setStateDialog(() => favEnabled = v),
                    title: const Text("Favorite Collection (5 içerik)",
                        style: TextStyle(color: Colors.white)),
                  ),
                  SwitchListTile(
                    value: rareEnabled,
                    onChanged: (v) => setStateDialog(() => rareEnabled = v),
                    title: const Text("Rare Achievements (Steam)",
                        style: TextStyle(color: Colors.white)),
                  ),
                  SwitchListTile(
                    value: screenshotEnabled,
                    onChanged: (v) =>
                        setStateDialog(() => screenshotEnabled = v),
                    title: const Text("Screenshot Gallery (Steam)",
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Favorite Collection Seçimi (${selectedFav.length}/5)",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: ListView.separated(
                        itemCount: allItems.length,
                        separatorBuilder: (context, index) => Divider(
                            color: Colors.white.withValues(alpha: 0.06),
                            height: 1),
                        itemBuilder: (context, index) {
                          final item = allItems[index];
                          final selected =
                              selectedFav.contains(item.compoundKey);
                          return ListTile(
                            dense: true,
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(8),
                                image: item.imageUrl == null
                                    ? null
                                    : DecorationImage(
                                        image: CachedNetworkImageProvider(
                                            item.imageUrl!),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            title: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: Checkbox(
                              value: selected,
                              onChanged: favEnabled
                                  ? (v) {
                                      setStateDialog(() {
                                        if (v == true) {
                                          if (selectedFav.length < 5) {
                                            selectedFav.add(item.compoundKey);
                                          }
                                        } else {
                                          selectedFav.remove(item.compoundKey);
                                        }
                                      });
                                    }
                                  : null,
                            ),
                            onTap: favEnabled
                                ? () {
                                    setStateDialog(() {
                                      if (selected) {
                                        selectedFav.remove(item.compoundKey);
                                      } else {
                                        if (selectedFav.length < 5) {
                                          selectedFav.add(item.compoundKey);
                                        }
                                      }
                                    });
                                  }
                                : null,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Vazgeç"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(
                  context,
                  _ShowcaseEditResult(
                    favEnabled: favEnabled,
                    rareEnabled: rareEnabled,
                    screenshotEnabled: screenshotEnabled,
                    favoriteKeys: selectedFav.toList(),
                  ),
                ),
                child: const Text("Kaydet"),
              ),
            ],
          );
        });
      },
    );

    if (result == null) return;

    await _database.updateProfileCustomization(
      uid: uid,
      showcases: {
        'enabled': {
          'favoriteCollection': result.favEnabled,
          'rareAchievements': result.rareEnabled,
          'screenshotGallery': result.screenshotEnabled,
        },
        'favoriteCollection': result.favoriteKeys,
      },
    );
    _reload();
  }

  Widget _detailPageFromCompoundKey(String compoundKey, dynamic id) {
    final prefix = compoundKey.split('_').first;
    switch (prefix) {
      case 'game':
        return GameDetailPage(gameID: id as int);
      case 'movie':
        return MovieDetailPage(movieID: id as int);
      case 'serie':
        return SerieDetailPage(serieID: id as int);
      case 'anime':
        return AnimeDetailPage(animeId: id as int);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    int themeColor = Provider.of<ThemeProvider>(context).color;
    final primaryColor = Color(themeColor);
    final libraryProvider = Provider.of<LibraryProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _loadProfile(),
        key: ValueKey(_reloadToken),
        builder: (context, snapshot) {
          final profileData = snapshot.data;
          if (snapshot.connectionState != ConnectionState.done) {
            return Skeletonizer(
              enabled: true,
              child: _buildSkeleton(primaryColor),
            );
          }

          if (profileData == null) {
            return const Center(
              child: Text("Profile not found",
                  style: TextStyle(color: Colors.white)),
            );
          }

          final username = (profileData['username'] ?? 'User').toString();
          final handle = (profileData['handle'] ?? '').toString();

          final profile = (profileData['profile'] as Map?) ?? {};
          final bannerUrl = profile['bannerUrl']?.toString();
          final photoUrl =
              (profile['photoUrl'] ?? profileData['imageURL'])?.toString();

          final settings = (profileData['settings'] as Map?) ?? {};
          final lastBackgroundChange = settings['lastBackgroundChange'];

          DateTime? nextBackground;
          if (lastBackgroundChange is Timestamp) {
            nextBackground =
                lastBackgroundChange.toDate().add(const Duration(days: 30));
          }

          final showcases = (profileData['showcases'] as Map?) ?? {};
          final enabled = (showcases['enabled'] as Map?) ?? {};
          final favEnabled = enabled['favoriteCollection'] == true;
          final rareEnabled = enabled['rareAchievements'] == true;
          final screenshotEnabled = enabled['screenshotGallery'] == true;

          final favKeys = (showcases['favoriteCollection'] is List)
              ? (showcases['favoriteCollection'] as List)
                  .map((e) => e.toString())
                  .toList()
              : <String>[];

          final rawLibrary = (profileData['library'] is Map)
              ? Map<String, dynamic>.from(profileData['library'])
              : <String, dynamic>{};

          final totalCount = rawLibrary.length;
          final level = math.max(1, (totalCount ~/ 10) + 1);
          final levelProgress = (totalCount % 10) / 10.0;

          final favItems = <_ShowcaseItem>[];
          for (final key in favKeys) {
            final raw = rawLibrary[key];
            if (raw is! Map) continue;
            final m = Map<String, dynamic>.from(raw);
            favItems.add(
              _ShowcaseItem(
                compoundKey: key,
                id: m['id'],
                title: (m['title'] ?? key).toString(),
                imageUrl: m['imageURL']?.toString(),
              ),
            );
          }

          final lastActivity = _findLastActivity(rawLibrary);

          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    _ProfileHeader(
                      primaryColor: primaryColor,
                      bannerUrl: bannerUrl,
                      photoUrl: photoUrl,
                      username: username,
                      handle: handle,
                      level: level,
                      levelProgress: levelProgress,
                      nextBackgroundChange: nextBackground,
                      onCopyLink: handle.isEmpty
                          ? null
                          : () {
                              Clipboard.setData(
                                ClipboardData(
                                    text: "vault.app/$handle/profile"),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Profil linki kopyalandı.")),
                              );
                            },
                      onEditHandle: () => _editHandle(handle),
                      onEditAvatar: _pickAndUploadAvatar,
                      onEditBanner: () => _changeBannerFromLibrary(
                          libraryProvider, profileData),
                      onEditShowcases: () =>
                          _editShowcases(profileData, libraryProvider),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 18),
                          const _SectionTitle(title: "LAST ACTIVITY"),
                          const SizedBox(height: 10),
                          _LastActivityCard(
                            primaryColor: primaryColor,
                            activity: lastActivity,
                          ),
                          const SizedBox(height: 18),
                          const _SectionTitle(title: "SHOWCASES"),
                          const SizedBox(height: 10),
                          _ShowcaseCard(
                            title: "Favorite Collection",
                            enabled: favEnabled,
                            trailing: TextButton(
                              onPressed: () =>
                                  _editShowcases(profileData, libraryProvider),
                              child: const Text("Edit"),
                            ),
                            child: favEnabled
                                ? _FavoriteShowcase(
                                    items: favItems,
                                    onOpen: (item) {
                                      final page = _detailPageFromCompoundKey(
                                          item.compoundKey, item.id);
                                      if (page is SizedBox) return;
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => page),
                                      );
                                    },
                                  )
                                : const _DisabledShowcase(),
                          ),
                          const SizedBox(height: 12),
                          _ShowcaseCard(
                            title: "Rare Achievements",
                            enabled: rareEnabled,
                            child: const _DisabledShowcase(
                              message:
                                  "Steam API entegrasyonu için Steam hesabı bağlama desteği eklenecek.",
                            ),
                          ),
                          const SizedBox(height: 12),
                          _ShowcaseCard(
                            title: "Screenshot Gallery",
                            enabled: screenshotEnabled,
                            child: const _DisabledShowcase(
                              message:
                                  "Steam ekran görüntüleri için Steam hesabı bağlama desteği eklenecek.",
                            ),
                          ),
                          const SizedBox(height: 18),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black87,
                                foregroundColor: Colors.red,
                              ),
                              onPressed: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.remove('userEmail');
                                await _auth.signOut();
                                if (!context.mounted) return;
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                );
                              },
                              child: Text(
                                "Logout",
                                style: TextStyle(color: primaryColor),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 45,
                width: MediaQuery.of(context).size.width,
                child: CustomAppWindow(isExitable: true),
              ),
            ],
          );
        },
      ),
    );
  }

  _LastActivity _findLastActivity(Map<String, dynamic> library) {
    int? best;
    Map<String, dynamic>? bestItem;
    String? bestKey;
    for (final entry in library.entries) {
      final raw = entry.value;
      if (raw is! Map) continue;
      final m = Map<String, dynamic>.from(raw);
      final addedAt = m['addedAt'];
      if (addedAt is int) {
        if (best == null || addedAt > best) {
          best = addedAt;
          bestItem = m;
          bestKey = entry.key.toString();
        }
      }
    }
    if (best == null || bestItem == null || bestKey == null) {
      return const _LastActivity.empty();
    }
    return _LastActivity(
      compoundKey: bestKey,
      id: bestItem['id'],
      title: (bestItem['title'] ?? bestKey).toString(),
      imageUrl: bestItem['imageURL']?.toString(),
      addedAt: DateTime.fromMillisecondsSinceEpoch(best),
    );
  }

  Widget _buildSkeleton(Color primaryColor) {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              height: 280,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1B1B1B), Color(0xFF121212)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 14, width: 160, color: Colors.white12),
                    const SizedBox(height: 12),
                    Container(
                        height: 120,
                        width: double.infinity,
                        color: Colors.white12),
                    const SizedBox(height: 18),
                    Container(height: 14, width: 160, color: Colors.white12),
                    const SizedBox(height: 12),
                    Container(
                        height: 220,
                        width: double.infinity,
                        color: Colors.white12),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 45,
          width: MediaQuery.of(context).size.width,
          child: CustomAppWindow(isExitable: true),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final Color primaryColor;
  final String? bannerUrl;
  final String? photoUrl;
  final String username;
  final String handle;
  final int level;
  final double levelProgress;
  final DateTime? nextBackgroundChange;
  final VoidCallback? onCopyLink;
  final VoidCallback onEditHandle;
  final VoidCallback onEditAvatar;
  final VoidCallback onEditBanner;
  final VoidCallback onEditShowcases;

  const _ProfileHeader({
    required this.primaryColor,
    required this.bannerUrl,
    required this.photoUrl,
    required this.username,
    required this.handle,
    required this.level,
    required this.levelProgress,
    required this.nextBackgroundChange,
    required this.onCopyLink,
    required this.onEditHandle,
    required this.onEditAvatar,
    required this.onEditBanner,
    required this.onEditShowcases,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          Positioned.fill(
            child: bannerUrl == null
                ? Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1B1B1B), Color(0xFF121212)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: bannerUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      color: const Color(0xFF1B1B1B),
                    ),
                  ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF121212).withValues(alpha: 0.9),
                    const Color(0xFF121212).withValues(alpha: 0.65),
                    const Color(0xFF121212).withValues(alpha: 0.95),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            top: 20,
            child: Row(
              children: [
                const Spacer(),
                _HeaderButton(
                  label: "Showcases",
                  icon: Icons.view_module,
                  onTap: onEditShowcases,
                ),
                const SizedBox(width: 10),
                _HeaderButton(
                  label: "Banner",
                  icon: Icons.wallpaper,
                  onTap: onEditBanner,
                ),
                const SizedBox(width: 10),
                _HeaderButton(
                  label: "Avatar",
                  icon: Icons.photo_camera,
                  onTap: onEditAvatar,
                ),
              ],
            ),
          ),
          Positioned(
            left: 24,
            bottom: 18,
            right: 24,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.7),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: const Color(0xFF252525),
                    backgroundImage: photoUrl == null
                        ? null
                        : CachedNetworkImageProvider(photoUrl!),
                    child: photoUrl == null
                        ? const Icon(Icons.person,
                            color: Colors.white54, size: 42)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              username,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: primaryColor.withValues(alpha: 0.35)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "LV $level",
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 90,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: levelProgress,
                                      minHeight: 8,
                                      backgroundColor:
                                          Colors.white.withValues(alpha: 0.12),
                                      valueColor:
                                          AlwaysStoppedAnimation(primaryColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              handle.isEmpty
                                  ? "Handle ayarlanmadı"
                                  : "vault.app/$handle/profile",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          if (onCopyLink != null) ...[
                            IconButton(
                              onPressed: onCopyLink,
                              icon: const Icon(Icons.copy,
                                  color: Colors.white70, size: 18),
                            )
                          ],
                          TextButton(
                            onPressed: onEditHandle,
                            child: const Text("Edit Handle"),
                          ),
                        ],
                      ),
                      if (nextBackgroundChange != null)
                        Text(
                          "Banner hakkı: ${nextBackgroundChange!.toLocal()}",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.6),
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _ShowcaseCard extends StatelessWidget {
  final String title;
  final bool enabled;
  final Widget child;
  final Widget? trailing;

  const _ShowcaseCard({
    required this.title,
    required this.enabled,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: enabled ? Colors.white : Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              if (trailing != null) trailing!,
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: enabled
                      ? Colors.green.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: enabled
                        ? Colors.green.withValues(alpha: 0.35)
                        : Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Text(
                  enabled ? "ACTIVE" : "INACTIVE",
                  style: TextStyle(
                    color: enabled ? Colors.greenAccent : Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DisabledShowcase extends StatelessWidget {
  final String? message;
  const _DisabledShowcase({this.message});

  @override
  Widget build(BuildContext context) {
    return Text(
      message ?? "Bu vitrin şu an kapalı.",
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.6),
        fontSize: 12,
      ),
    );
  }
}

class _FavoriteShowcase extends StatelessWidget {
  final List<_ShowcaseItem> items;
  final void Function(_ShowcaseItem item) onOpen;

  const _FavoriteShowcase({required this.items, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(
        "Henüz seçilmiş içerik yok. Edit ile 5 favori seç.",
        style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65), fontSize: 12),
      );
    }
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.take(5).map((item) {
        return InkWell(
          onTap: () => onOpen(item),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 160,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              image: item.imageUrl == null
                  ? null
                  : DecorationImage(
                      image: CachedNetworkImageProvider(item.imageUrl!),
                      fit: BoxFit.cover,
                    ),
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              alignment: Alignment.bottomLeft,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF121212).withValues(alpha: 0.0),
                    const Color(0xFF121212).withValues(alpha: 0.9),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _LastActivityCard extends StatelessWidget {
  final Color primaryColor;
  final _LastActivity activity;

  const _LastActivityCard({
    required this.primaryColor,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              image: activity.imageUrl == null
                  ? null
                  : DecorationImage(
                      image: CachedNetworkImageProvider(activity.imageUrl!),
                      fit: BoxFit.cover,
                    ),
            ),
            child: activity.imageUrl == null
                ? const Icon(Icons.history, color: Colors.white38)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.isEmpty ? "Henüz aktivite yok" : activity.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  activity.isEmpty
                      ? "Kütüphanene içerik ekleyerek aktivite oluştur."
                      : "Added: ${activity.addedAt?.toLocal()}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              activity.isEmpty ? "NEW" : "RECENT",
              style: TextStyle(
                color: primaryColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _BannerCandidate {
  final String key;
  final String title;
  final String imageUrl;

  _BannerCandidate(
      {required this.key, required this.title, required this.imageUrl});
}

class _LibraryCandidate {
  final String compoundKey;
  final String title;
  final String? imageUrl;

  _LibraryCandidate({
    required this.compoundKey,
    required this.title,
    required this.imageUrl,
  });
}

class _ShowcaseEditResult {
  final bool favEnabled;
  final bool rareEnabled;
  final bool screenshotEnabled;
  final List<String> favoriteKeys;

  _ShowcaseEditResult({
    required this.favEnabled,
    required this.rareEnabled,
    required this.screenshotEnabled,
    required this.favoriteKeys,
  });
}

class _ShowcaseItem {
  final String compoundKey;
  final dynamic id;
  final String title;
  final String? imageUrl;

  _ShowcaseItem({
    required this.compoundKey,
    required this.id,
    required this.title,
    required this.imageUrl,
  });
}

class _LastActivity {
  final String compoundKey;
  final dynamic id;
  final String title;
  final String? imageUrl;
  final DateTime? addedAt;
  final bool isEmpty;

  const _LastActivity.empty()
      : compoundKey = '',
        id = null,
        title = '',
        imageUrl = null,
        addedAt = null,
        isEmpty = true;

  const _LastActivity({
    required this.compoundKey,
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.addedAt,
  }) : isEmpty = false;
}
