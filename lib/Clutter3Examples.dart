import 'package:raul_twitch_swift_kotlin/Clutter3.dart';
import 'package:flutter/material.dart';

/*

 Presentation Layer Examples

 */

class MyViewModel {}

class MyViewModelPresenter implements PresenterC3<MyViewModel> {
  void Function(DisplayedStateC3 state) display;
  void fetchAndPresentSomething() {}
  MyViewModel viewModel;
  DomainError error;
  MyViewModelPresenter(this.display);
}

class MyViewModelDisplayLogic
    implements DisplayableC3<MyViewModel, MyViewModelPresenter> {
  DisplayedStateC3 state;
  MyViewModelPresenter presenter;

  void display(DisplayedStateC3 state) {}

  Widget buildStateBasedWidget() {
    return null;
  }

  void createPresenter() {
    presenter = MyViewModelPresenter(this.display);
  }
}

/*

 Domain Layer Examples

 */

// Repo call sample
class LoginScenePresenter {
  UserRepository repo = UserRepository();

  /// Synchronous request
  void checkIfUserIsLoggedIn() {
    final request =
        RepoRequest<UserUseCase, Nothing, bool>(UserUseCase.isUserLoggedIn);
    if (repo.performRequest(request)) {
      print('user logged in');
    } else {
      print('user not logged in');
    }
  }

  /// Asynchronous request
  void loginUser() {
    final loginParameters =
        UserLoginParameters("hi@hi.com", "flyingGargoyles25");
    final request =
        RepoRequest<UserAsyncUseCase, UserLoginParameters, UserEntity>(
            UserAsyncUseCase.loginUserWithEmailAndPassword,
            parameters: loginParameters);
    repo.performAsyncRequest(request).then((userEntity) {
      if (userEntity != null) {
      } else {
        throw DomainError(DomainErrorKind.notFound);
      }
    }).catchError((error) {
      if (error is DomainError) {
        DomainError domainError = error;
        String description = domainError.localizedDescription;
        print('Got domain error $description');
      } else {
        print('Got domain error $error.toString()');
      }
    });
  }

  /// Observable request
  void observeUserProfile() {
    final observer = Observer<UserEntity>(
        "LoginScenePresenter", this.handleUserProfileUpdates);
    final request =
        ObservableRepoRequest<UserObservableUseCase, String, UserEntity>(
            observer, UserObservableUseCase.observeUserProfile,
            parameters: "4598");

    repo.performObservingRequest(request);
  }

  void handleUserProfileUpdates({UserEntity result, DomainError error}) {
    /// Observed user profile updated or received and error.
  }
}

class UserEntity {
  String name;
  String lastName;
  String userId;

  UserEntity(this.name, this.lastName, this.userId);
}

class UserLoginParameters {
  String email;
  String password;

  UserLoginParameters(this.email, this.password);
}

enum UserUseCase { noUseCase, isUserLoggedIn }

enum UserAsyncUseCase {
  noUseCase,

  /// Parameters: UserLoginParameters. Returns entity: UserEntity
  loginUserWithEmailAndPassword
}

enum UserObservableUseCase { noUseCase, observeUserProfile }

class UserRepository
    extends Repository<UserUseCase, UserAsyncUseCase, UserObservableUseCase> {
  /// Singleton setup. Source https://stackoverflow.com/a/12649574
  static final UserRepository _userRepository = new UserRepository._internal();
  factory UserRepository() {
    return _userRepository;
  }
  UserRepository._internal();

  /// end singleton setup

  /// Key: user Id.
  Map<String, UserEntity> userEntityMemoryStore;

  /// Key: User Id, value: EntityObservers for that entity. This allows the repo to observe multiple users.
  Map<String, EntityObservers<UserEntity>> userObservers =
      Map<String, EntityObservers<UserEntity>>();

  /// Use cases that can retrieve data synchronously (cached in memory)
  Entity performRequest<Parameters, Entity>(
      RepoRequest<UserUseCase, Parameters, Entity> request) {
    switch (request.useCase ?? UserUseCase.noUseCase) {
      case UserUseCase.isUserLoggedIn:
        if ((request.parameters is String) != null) {
          final userId = request.parameters as String;
          return (userEntityMemoryStore[userId] != null) as Entity;
        }
        break;
      default:
        break;
    }
    return null;
  }

  /// Async
  ///
  /// Use cases that retrieve data from database, remote server or any other of asynchronous request.
  Future<Entity> performAsyncRequest<Parameters, Entity>(
      RepoRequest<UserAsyncUseCase, Parameters, Entity> request) {
    switch (request.useCase ?? UserAsyncUseCase.noUseCase) {
      case UserAsyncUseCase.loginUserWithEmailAndPassword:
        if (request.parameters is UserLoginParameters) {
          return login(request.parameters as UserLoginParameters)
              as Future<Entity>;
        }
        break;
      default:
        break;
    }

    return null;
  }

  Future<UserEntity> login(UserLoginParameters parameters) async {
    // Whenever possible implement a cache manager  that checks if the requested entity exists in memory or local database
    // Perform a remote server call and wait for it to respond with await keyword
    // UserEntity testEntity = await MyServerCall(parameters.email, parameters.password);
    UserEntity testEntity = UserEntity("Raul", "Rea", "4598");
    // Store in memory or database as needed.
    this.userEntityMemoryStore[testEntity.userId] = testEntity;
    return testEntity;
  }

  /// Observable
  ///
  /// Use cases that retrieve data from a source that supports subscription like WebSockets, MQTT or BLE notifications.
  void performObservingRequest<Parameters, Entity>(
      ObservableRepoRequest<UserObservableUseCase, Parameters, Entity>
          request) {
    switch (request.useCase ?? UserObservableUseCase.noUseCase) {
      case UserObservableUseCase.observeUserProfile:
        registerUserObserver(request.parameters as String,
            request.observer as Observer<UserEntity>);
        break;

      default:
        break;
    }
  }

  /// Observing key: user Id
  void removeUserObserver(Observer<UserEntity> observer, String observingKey) {
    if (userObservers[observingKey] != null) {
      final observers = userObservers[observingKey];
      observers.removeObserver(observer);
      userObservers[observingKey] = observers;
    }
  }

  /// Parameters: User Id
  void registerUserObserver(String parameters, Observer<UserEntity> observer) {
    final result = ObserverHelper.registerObserver(
        observer, parameters, userObservers, userEntityMemoryStore);
    this.userObservers = result.updatedObservers;
    if (result.shouldCallRemote) {
      // Make call
      observeRemoteUserProfile(parameters)
          .then((userEntity) {})
          .catchError((error) {});
    }
  }

  /// Parameters: User Id String
  Future<UserEntity> observeRemoteUserProfile(String parameters) async {
    // Observe user with parameter given (user id)
    UserEntity testEntity = UserEntity("Raul", "Rea", "4598");
    this.userEntityMemoryStore[testEntity.userId] = testEntity;
    return testEntity;
  }
}
