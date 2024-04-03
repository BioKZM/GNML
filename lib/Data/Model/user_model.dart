class FUser {
  final String? username;

  FUser({this.username});
}

class UserData {
  final String? username;

  final Map<String, dynamic>? games;
  final Map<String, dynamic>? movies;
  final Map<String, dynamic>? series;
  final Map<String, dynamic>? books;

  UserData({
    this.username,
    this.games,
    this.movies,
    this.series,
    this.books,
  });
}
