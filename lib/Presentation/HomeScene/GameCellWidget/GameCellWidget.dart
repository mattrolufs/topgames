import 'package:flutter/material.dart';

class GameCellViewModel {
  String gameTitle;
  String viewers;
  String assetPath;
  GameCellViewModel(this.gameTitle, this.viewers, this.assetPath);
}

class GameCellWidget extends StatefulWidget {
  final GameCellViewModel _viewModel;

  @override
  _GameCellWidgetState createState() => _GameCellWidgetState();

  GameCellWidget(this._viewModel);
}

// Cell used in the home screen for each game
class _GameCellWidgetState extends State<GameCellWidget> {
  Widget getImage() {
//    print("Path $widget._viewModel.assetPath");
    if (widget._viewModel.assetPath == "assets/images/sampleImage.jpg") {
      return Image.asset(widget._viewModel.assetPath, fit: BoxFit.fitHeight);
    } else {
      final urlWithSize = widget._viewModel.assetPath.replaceAll("{width}", "800").replaceAll("{height}", "800");
//      print("updated url $urlWithSize");
      return Image.network(urlWithSize, fit: BoxFit.fitHeight);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
            child: getImage()
        ),
        Text(widget._viewModel.gameTitle,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis
        ),
        Text(widget._viewModel.viewers,
            style: TextStyle(color: Colors.white, fontSize: 13),
            overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
