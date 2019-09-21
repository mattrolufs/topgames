import 'package:flutter/material.dart';

/*

Presentation Layer

 */

enum DisplayedStateC3 { empty, error, populated, loading }

/// Presentation protocols
abstract class PresenterC3<ViewModel> {
  /// Holds the display function of a DisplayableC3 class for the provided ViewModel
  void Function(DisplayedStateC3 state) display;
  ViewModel viewModel;
  DomainError error;
  PresenterC3(this.display);
}

abstract class DisplayableC3<ViewModel,
    Presenter extends PresenterC3<ViewModel>> {
  /// Memory store of the current state for this scene
  DisplayedStateC3 state;

  /// Class in charge of fetching data and mapping it into a ViewModel
  Presenter presenter;

  /// Display function called from the presenter. Updates the stored state within the setState function
  void display(DisplayedStateC3 state);

  /// Display logic triggered by the scaffold refresh after calling setState() in the display(state) function. This function must be set as the child of the Widget build(BuildContext context) function of a State class
  Widget buildStateBasedWidget();

  /// Must be called at the init state of the class implementing it
  void createPresenter();
}

/*

 Domain Layer

 */

/// Completion or subscription handler function for domain calls.
typedef RequestHandler<Result> = void Function(
    {Result result, DomainError error});

/// Empty type to indicate a generic type is not necessary
//enum Nothing {
//  nothing
//}

typedef Nothing = void Function();

/// Enum of errors
enum DomainErrorKind { noError, notAuthorized, notFound, unableToParse }

/// Domain error, localized
class DomainError extends Error {
  DomainErrorKind kind;

  String get localizedDescription {
    switch (this.kind ?? DomainErrorKind.noError) {
      case DomainErrorKind.notAuthorized:
        return "Please login";
        break;
      case DomainErrorKind.notFound:
        return "Not found";
        break;
      case DomainErrorKind.unableToParse:
        return "Unable to parse";
        break;
      default:
        return this.toString();
        break;
    }
  }

  DomainError(this.kind);
}

/// Sync or Async request
class RepoRequest<UseCase, Parameters, Entity> {
  /// Enum case indicating the use case to perform
  UseCase useCase;

  /// Optional parameters
  Parameters parameters;
  RepoRequest(this.useCase, {this.parameters});
}

/// Observable request
class ObservableRepoRequest<UseCase, Parameters, Entity>
    extends RepoRequest<UseCase, Parameters, Entity> {
  Observer<Entity> observer;
  ObservableRepoRequest(Observer<Entity> observer, UseCase useCase,
      {Parameters parameters})
      : super(useCase, parameters: parameters);
}

abstract class Repository<UseCase, AsyncUseCase, ObservableUseCase> {
  /// Use cases that can retrieve data synchronously (cached in memory)
  Entity performRequest<Parameters, Entity>(
      RepoRequest<UseCase, Parameters, Entity> request);

  /// Use cases that retrieve data from database, remote server or any other of asynchronous request.
  Future<dynamic> performAsyncRequest<Parameters, Entity>(
      RepoRequest<AsyncUseCase, Parameters, Entity> request);

  /// Use cases that retrieve data from a source that supports subscription like WebSockets, MQTT or BLE notifications.
  void performObservingRequest<Parameters, Entity>(
      ObservableRepoRequest<ObservableUseCase, Parameters, Entity> request);

  /// Repository must implement remove observer function for each entity observed.
  //  void removeObserver(Observer<Entity> observer, String observingKey);

  /// Repository must keep track of observers in memory.
  //  Map<String, EntityObserver<ObservableEntity>> entityObservers;
}

/*

Observers

 */

class Observer<Entity> {
  /// Name of the observing class
  String uniqueId;
  RequestHandler<Entity> subscriptionCallback;
  Observer(this.uniqueId, this.subscriptionCallback);
}

class EntityObservers<Entity> {
  // Key: Observer Id, Value: Observer for entity
  var observers = Map<String, Observer<Entity>>();

  bool addObserver(Observer<Entity> observer) {
    if (observers[observer.uniqueId] == null) {
      observers[observer.uniqueId] = observer;
      return true;
    }
    return false;
  }

  void removeObserver(Observer<Entity> observer) {
    observers.remove(observer.uniqueId);
  }

  void notify(Entity updatedEntity, DomainError error) {
    observers.forEach((observerId, observer) {
      observer.subscriptionCallback(result: updatedEntity, error: error);
    });
  }
}

class ObserverRegistrationResult<Entity> {
  bool shouldCallRemote = false;
  Map<String, EntityObservers<Entity>> updatedObservers;

  ObserverRegistrationResult(this.shouldCallRemote, this.updatedObservers);
}

class ObserverHelper {
  /// Observed Key: User Id, device mac address or serial number, or entity name if all entities matching that name are observed.
  static ObserverRegistrationResult<Entity> registerObserver<Entity>(
      Observer<Entity> observer,
      String observedKey,
      Map<String, EntityObservers<Entity>> entityObservers,
      Map<String, Entity> memoryStore) {
    if (entityObservers[observedKey] != null) {
      // Already being observed by this or other observers. Call add new observer, if the observer already exists, addObserver will return false.
      final observersForSpecifiedKey = entityObservers[observedKey];
      if (observersForSpecifiedKey.addObserver(observer)) {
        // Observer was added, update map
        entityObservers[observedKey] = observersForSpecifiedKey;
      }
      // If we have a memory store, send it through the subscription call back
      if (memoryStore[observedKey] != null) {
        observer.subscriptionCallback(result: memoryStore[observedKey]);
      } else {
        return ObserverRegistrationResult<Entity>(true, entityObservers);
      }
    } else {
      // No observers been registered for this key, we can assume memory store is non existent or obsolete.
      var newObserversForSpecifiedKey = EntityObservers<Entity>();
      newObserversForSpecifiedKey.addObserver(observer);
      entityObservers[observedKey] = newObserversForSpecifiedKey;
      return ObserverRegistrationResult<Entity>(true, entityObservers);
    }
    return ObserverRegistrationResult<Entity>(false, entityObservers);
  }
}
