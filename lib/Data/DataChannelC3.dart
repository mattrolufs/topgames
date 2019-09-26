import 'package:flutter/services.dart';

/*
  This channel will be used to communicate with native data sources like Bluetooth, AWS SDKs and the like.
  Expected requests and its corresponding response maps should be declared in the DataRequest enum
  Note: If the app contains multiple data sources that would make this channel too clunky, please implement a data channel for each.
 */

enum DataChannelRequest { TopGamesEntity, StartNewActivity }

class DataChannelError extends Error {
  DCErrorKind kind;
  DataChannelError(this.kind);
}

enum DCErrorKind { missingRequest, mappingError }

typedef EntityMapper<Entity> = Entity Function(Map<dynamic, dynamic> map);

class DataChannel {
  /// Singleton setup. Source https://stackoverflow.com/a/12649574
  static final DataChannel _dataChannel = new DataChannel._internal();
  factory DataChannel() {
    return _dataChannel;
  }
  DataChannel._internal();

  /// end singleton setup

  final dataChannel = MethodChannel("dataChannel");

  /// Arguments are always passed in a Map<dynamic, dynamic> using the "parameters" key
  Future<Map<dynamic, dynamic>> _performRequest(DataChannelRequest request,
      {Map<dynamic, dynamic> parameters}) {
    Map<dynamic, dynamic> arguments = {"parameters": parameters};
    return dataChannel.invokeMapMethod(request.toString(), arguments);
  }

  /// Mapper is used to translate the received Map from native into the requested Entity.
  Future<Entity> perform<Entity>(DataChannelRequest request,
      {Map<dynamic, dynamic> parameters, EntityMapper<Entity> mapper}) {
    Future<Entity> future = this
        ._performRequest(request, parameters: parameters)
        .then((response) => mapper(response["parameters"]));
    return future;
  }

  getNewActivity() async {
    try {
      await dataChannel
          .invokeMethod(DataChannelRequest.StartNewActivity.toString());
    } on PlatformException catch (e) {
      print(e.message);
    }
  }
}

/*
Example Usage
 */
