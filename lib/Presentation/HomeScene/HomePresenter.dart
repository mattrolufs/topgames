import 'package:raul_twitch_swift_kotlin/Clutter3.dart';
import 'package:raul_twitch_swift_kotlin/Domain/Entities/TopGamesEntity.dart';
import 'package:raul_twitch_swift_kotlin/Domain/TwitchRepo.dart';
import 'package:raul_twitch_swift_kotlin/Domain/UseCases/GetTopGamesUseCase.dart';
import 'package:raul_twitch_swift_kotlin/Presentation/HomeScene/GameCellWidget/GameCellWidget.dart';

class HomeViewModel {
  List<GameCellWidget> games;
  HomeViewModel(this.games);
}

class HomePresenter implements PresenterC3<HomeViewModel> {
  void Function(DisplayedStateC3 state) display;
  final _repo = TwitchRepo();
  DomainError error;
  HomeViewModel viewModel;

  void getTopGames() {
    final getTopGamesRequest = GetTopGamesUseCase();
    _repo.performAsyncRequest(getTopGamesRequest).then((entity) {
      if (entity != null) {
        final viewModel = HomeViewModel(createViewModel(entity));
        this.viewModel = viewModel;
        final state = DisplayedStateC3.populated;
        display(state);
      } else {
        print("unable to parse");
        throw DomainError(DomainErrorKind.unableToParse);
      }
    }).catchError((error) {
      // Catch errors
      print("Presenter error $error");
      final viewModel = HomeViewModel(createMockData());
      this.viewModel = viewModel;
      final state = DisplayedStateC3.populated;
      display(state);
    });
  }

  List<GameCellWidget> createViewModel(TopGamesEntity entity) {
    final list = List<GameCellWidget>();
    for (final eachGame in entity.games) {
      list.add(GameCellWidget(GameCellViewModel(
          eachGame.name, eachGame.viewers + " viewers", eachGame.imageURL)));
    }
    return list;
  }

  List<GameCellWidget> createMockData() {
    return [
      GameCellWidget(GameCellViewModel(
          'Zelda', '4567 viewers', 'assets/images/sampleImage.jpg')),
      GameCellWidget(GameCellViewModel(
          'Mass Effect', '234 viewers', 'assets/images/sampleImage.jpg')),
      GameCellWidget(GameCellViewModel(
          'Mario Party', '345 viewers', 'assets/images/sampleImage.jpg')),
      GameCellWidget(GameCellViewModel(
          'Fortnite', '324 viewers', 'assets/images/sampleImage.jpg')),
      GameCellWidget(GameCellViewModel(
          'Zelda', '234 viewers', 'assets/images/sampleImage.jpg')),
      GameCellWidget(GameCellViewModel(
          'Zelda', '234 viewers', 'assets/images/sampleImage.jpg')),
      GameCellWidget(GameCellViewModel(
          'Zelda', '23654654 viewers', 'assets/images/sampleImage.jpg')),
      GameCellWidget(GameCellViewModel(
          'Zelda', '234 viewers', 'assets/images/sampleImage.jpg')),
      GameCellWidget(GameCellViewModel(
          'Zelda', '234 viewers', 'assets/images/sampleImage.jpg')),
      GameCellWidget(GameCellViewModel(
          'Zelda', '234 viewers', 'assets/images/sampleImage.jpg')),
    ];
  }

  HomePresenter(this.display);
}
