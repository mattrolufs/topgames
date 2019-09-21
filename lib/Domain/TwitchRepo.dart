import 'package:raul_twitch_swift_kotlin/Clutter3.dart';
import 'package:raul_twitch_swift_kotlin/Data/DataChannelC3.dart';
import 'package:raul_twitch_swift_kotlin/Domain/Entities/TopGamesEntity.dart';

enum TwitchRepoUseCase { empty }

enum TwitchRepoAsyncUseCase { getTopGames }

enum TwitchRepoObservableUseCase { empty }

class TwitchRepo
    implements
        Repository<TwitchRepoUseCase, TwitchRepoAsyncUseCase,
            TwitchRepoObservableUseCase> {
  /// No sync requests for this repo
  Entity performRequest<Parameters, Entity>(
      RepoRequest<TwitchRepoUseCase, Parameters, Entity> request) {
    return null;
  }

  /// Use cases that retrieve data from database, remote server or any other of asynchronous request.
  Future<Entity> performAsyncRequest<Parameters, Entity>(
      RepoRequest<TwitchRepoAsyncUseCase, Parameters, Entity> request) {
    switch (request.useCase) {
      case TwitchRepoAsyncUseCase.getTopGames:
        return _getTopGames() as Future<Entity>;
        break;
    }
    return null;
  }

  /// Use cases that retrieve data from a source that supports subscription like WebSockets, MQTT or BLE notifications.
  void performObservingRequest<Parameters, Entity>(
      ObservableRepoRequest<TwitchRepoObservableUseCase, Parameters, Entity>
          request) {
    // None implemented
  }

  Future<TopGamesEntity> _getTopGames() async {
    return DataChannel().perform<TopGamesEntity>(
        DataChannelRequest.TopGamesEntity,
        mapper: TopGamesEntity.mapEntity);
  }
}
