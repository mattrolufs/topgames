import 'package:raul_twitch_swift_kotlin/Clutter3.dart';
import 'package:raul_twitch_swift_kotlin/Domain/Entities/TopGamesEntity.dart';
import 'package:raul_twitch_swift_kotlin/Domain/TwitchRepo.dart';

class GetTopGamesUseCase
    extends RepoRequest<TwitchRepoAsyncUseCase, Nothing, TopGamesEntity> {
  GetTopGamesUseCase() : super(TwitchRepoAsyncUseCase.getTopGames);
}
