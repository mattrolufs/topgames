import 'package:flutter/services.dart';
import 'package:raul_twitch_swift_kotlin/Clutter3.dart';
import 'package:raul_twitch_swift_kotlin/Domain/Entities/TopGamesEntity.dart';
import 'package:raul_twitch_swift_kotlin/Domain/TwitchRepo.dart';

/*
  This channel is used to receive async and observing requests from native UI via the FlutterRepo native class.
  It is a two way channel. Native to Flutter side requests entities with async or observable use cases.
  Flutter to native only used to send back observed entities
 */

class FlutterRepoChannel {
  /// Singleton setup. Source https://stackoverflow.com/a/12649574
  static final FlutterRepoChannel _shared = new FlutterRepoChannel._internal();
  factory FlutterRepoChannel() {
    return _shared;
  }
  FlutterRepoChannel._internal();

  /// end singleton setup

  final _methodChannel = MethodChannel("flutterRepositoryChannel");

  /// Sends value update to the native flutter repo. Future returns true if call was delivered. If there are no observers expecting this call natively, nothing will happen and future will still return true.
  Future<bool> notifyObserversOfValueUpdate(
      String entityName, String observedKey, Map<String, dynamic> entityMap) {
    entityMap["observedKey"] = observedKey;
    return _methodChannel.invokeMethod(entityName, entityMap);
  }

  Future<dynamic> request;
  void setupNativePresentationRequestsHandler() {
    _methodChannel.setMethodCallHandler(_handleNativePresentationRequests);
  }

  Future<Map<dynamic, dynamic>> _handleNativePresentationRequests(
      MethodCall call) async {
    String entityName = call.method;
    // route call based on the requested entity
    switch (entityName) {
      case "TopGamesEntity":
        print("requested top games");
        if (call.arguments != null && call.arguments["observedKey"] != null) {
          // Observable request. Reply needed right away. Entity Response will be sent via notifyObserversOfValueUpdate.
          print("requested observed key");
          // Empty reply. This a sample as the Twitch API does not use sockets / subscriptions.
//          return Future.value("");
        } else {
          // Async request
          print("requesting entity");
          final repoRequest =
              RepoRequest<TwitchRepoAsyncUseCase, Nothing, TopGamesEntity>(
                  TwitchRepoAsyncUseCase.getTopGames);
          final entity = await TwitchRepo().performAsyncRequest(repoRequest);
          if (entity is TopGamesEntity) {
            Map<dynamic, dynamic> responseMap = {};
            responseMap["parameters"] = entity.originalMap;
            print("sending back map of top games as parameters");
            return Future.value(responseMap); //responseMap
          } else {
            throw DomainError(DomainErrorKind.unableToParse);
          }
        }
        break;
      default:
        break;
    }
    throw MissingPluginException();
  }
}
