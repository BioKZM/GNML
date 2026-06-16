class UserLibrary {
  static const int schemaVersion = 2;
  static const Map<String, dynamic> defaultFolders = {
    'favorites': {'type': 'default'},
    'completed': {'type': 'default'},
    'backlog': {'type': 'default'},
  };

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
      for (final folder in rawCustomFolders) {
        final name = folder?.toString().trim();
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
      'folders': defaultFolders,
    };
  }
}
