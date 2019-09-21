

class TopGamesEntity {
  List<GameEntity> games;
  TopGamesEntity(this.games);
  Map<dynamic,dynamic> originalMap;

  static TopGamesEntity mapEntity(Map<dynamic,dynamic> map) {
    var topGames = TopGamesEntity(List<GameEntity>());
    topGames.originalMap = map;
    final gameMaps = map["games"] as List<dynamic>;
    for (final eachGame in gameMaps) {
      final eachGameMap = eachGame as Map<dynamic,dynamic>;
//      print("parsing game $eachGameMap");
      topGames.games.add(GameEntity.mapEntity(eachGameMap));
    }
    return topGames;
  }
}

class GameEntity {
  String imageURL;
  String name;
  String viewers;

  GameEntity(this.imageURL, this.name, this.viewers);

  static GameEntity mapEntity(Map<dynamic,dynamic> map) {
    return GameEntity(map["imageURL"], map["name"], map["viewers"].toString());
  }
}