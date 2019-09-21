import 'package:flutter/material.dart';
import 'package:raul_twitch_swift_kotlin/Clutter3.dart';
import 'package:raul_twitch_swift_kotlin/Data/DataChannelC3.dart';
import 'package:raul_twitch_swift_kotlin/Presentation/HomeScene/HomePresenter.dart';
import 'dart:io' show Platform;

class HomeScene extends StatefulWidget {
  HomeScene({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _HomeSceneState createState() => _HomeSceneState();
}

class _HomeSceneState extends State<HomeScene>
    implements DisplayableC3<HomeViewModel, HomePresenter> {
  /*
    Clean Architecture layout
   */

  HomePresenter presenter;

  /// Initial state. Can be loading, or empty, or populated if there is hard coded content.
  DisplayedStateC3 state = DisplayedStateC3.loading;

  /// Display function called from the Presenter
  void display(DisplayedStateC3 state) {
    setState(() {
      this.state = state;
    });
  }

  /// Display logic triggered by the scaffold refresh after calling setState() in the display(state) function
  /// This widget is the body of the scene
  Widget buildStateBasedWidget() {
    switch (state) {
      case DisplayedStateC3.empty:
        break;
      case DisplayedStateC3.loading:
        return CircularProgressIndicator();
      case DisplayedStateC3.error:
        break;
      case DisplayedStateC3.populated:
        // Default return below
        break;
    }

    /// Default return
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 0.6,
      crossAxisSpacing: 4 * MediaQuery.of(context).devicePixelRatio,
      mainAxisSpacing: 4 * MediaQuery.of(context).devicePixelRatio,
      children: presenter.viewModel.games,
      // Top, sides and bottom insets of the list view
      padding: EdgeInsets.all(16.0),
    );
  }

  Widget returnAndroidNativeButton() {
    if (Platform.isAndroid) {
      return MaterialButton(
          child: const Text('Open Screen'),
          elevation: 5.0,
          height: 48.0,
          minWidth: 250.0,
          color: Colors.blue,
          textColor: Colors.white,
          onPressed: () {
            DataChannel().getNewActivity();
          });
    } else {
      return null;
    }
  }

  /// This will be called once after the widget finished rendering the layout
  @override
  void initState() {
    super.initState();
    createPresenter();
    presenter?.getTopGames();
  }

  /// Assign the presenter's
  void createPresenter() {
    presenter = HomePresenter(this.display);
  }

  /*
    End Clean Architecture layout
   */

  // Build scene widget. Body will call buildStateBasedWidget()
  @override
  Widget build(BuildContext context) {
    bool notNull(Object o) => o != null;
    return Scaffold(
//      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        // Here we take the value from the HomeScene object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        backgroundColor: Theme.of(context).primaryColor,
        // Accent line at the bottom of the app bar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            constraints: BoxConstraints.expand(
              height: 4,
              width: MediaQuery.of(context).size.width,
            ),
            decoration: BoxDecoration(color: Theme.of(context).accentColor),
            child: null,
          ),
        ),
      ),
      body: Center(
          child: Stack(
        children: <Widget>[
          buildStateBasedWidget(),
          returnAndroidNativeButton(),
        ].where(notNull).toList(),
      )),
    );
  }
}
