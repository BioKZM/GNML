class UserLibrary {
  static const int schemaVersion = 1;

  final Map<String, dynamic> library;
  final List<String> customFolders;

  UserLibrary({
    required this.library,
    required this.customFolders,
  });

  factory UserLibrary.fromSnapshot(Map<String, dynamic> data) {
    final rawLibrary = data['library'];
    final rawCustomFolders = data['customFolders'];

    final library = <String, dynamic>{};
    if (rawLibrary is Map) {
      for (final entry in rawLibrary.entries) {
        final key = entry.key.toString();
        final value = entry.value;
        if (value is Map) {
          library[key] = Map<String, dynamic>.from(value);
        } else {
          library[key] = value;
        }
      }
    }

    final customFolders = <String>[];
    if (rawCustomFolders is List) {
      for (final f in rawCustomFolders) {
        final name = f?.toString().trim();
        if (name == null || name.isEmpty) continue;
        customFolders.add(name);
      }
    }

    return UserLibrary(
      library: library,
      customFolders: customFolders,
    );
  }

  Map<String, dynamic> toFirebaseMap() {
    return {
      'schemaVersion': schemaVersion,
      'library': library,
      'customFolders': customFolders,
      'folders': {
        'favorites': {'type': 'default'},
        'completed': {'type': 'default'},
        'backlog': {'type': 'default'},
      },
    };
  }
}
