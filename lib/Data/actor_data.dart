import 'package:vault/Logic/actorpage_logic.dart';

class ActorsData {
  Future<List<dynamic>> searchActors(String query, int page) async {
    return await ActorPageLogic().searchActors(query, page);
  }
}
