//
//  PresentationToDomainChannel.swift
//  Runner
//
//  Created by Raul Rea on 9/5/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation

enum FlutterUseCase: String  {
    case noSyncRequests
}

enum FlutterAsyncUseCase: String  {
    case TopGamesEntity
}

enum FlutterObservableUseCase: String  {
    case sampleObserver
}

typealias EntityMapper<Entity> = (Dictionary<String,Any>) -> Entity?

/// This repository lets native Presenters talk to the Flutter domain layer.
class FlutterRepo: DictionaryRepositoryC3 {
    enum Constants {
        static let observedKey = "observedKey"
        static let flutterRepositoryChannel = "flutterRepositoryChannel"
    }
    typealias UseCase = FlutterUseCase
    typealias AsyncUseCase = FlutterAsyncUseCase
    typealias ObservableUseCase = FlutterObservableUseCase
    
    static let shared = FlutterRepo()
    private init() { }
    private var channel: FlutterMethodChannel?
  
    /// Must be set from the landing view controller as the flutter view controller is allocated
    func setup(flutterViewController: FlutterViewController) {
        self.channel = FlutterMethodChannel(name: Constants.flutterRepositoryChannel, binaryMessenger: flutterViewController.binaryMessenger)
        self.channel?.setMethodCallHandler({ [weak self] (call, result) in
            self?.handleFlutterObservedCalls(call)
            result(NSNumber(booleanLiteral: true))
        })
    }
    
    /// No sync calls to this repo
    func performRequest<Entity>(_ request: RequestC3<FlutterUseCase, [String:Any], Entity>, mapper: EntityMapper<Entity>)  -> Entity? {
        return nil
    }
    
    // MARK: - Async requests
    
    /// Mapping function should be part of the given entity. This function will map the received response from flutter (dictionary) to the requested Entity.
    /// Request parameters must be sent as a key / value pair. They will be sent to flutter inside a key value pair as the value for key "parameters"
    func performAsyncRequest<Entity>(_ request: AsyncRequestC3<FlutterAsyncUseCase, [String:Any], Entity>, mapper: @escaping EntityMapper<Entity>) {
        guard let channel = self.channel else {
            request.completionHandler?({ throw DomainError.sourceMissing })
            return
        }
        /// Get from remote
        let flutterParameters: [String: Any] = request.parameters != nil ? ["parameters": request.parameters!] : [String: Any]()
        channel.invokeMethod(request.useCase.rawValue, arguments: flutterParameters, result: { [request, mapper] (result) in
            if let result = result as? [String:Any], let parameters = result["parameters"] as? [String:Any] {
                if let entity = mapper(parameters) {
                    request.completionHandler?({ return entity })
                    return
                } else {
                     request.completionHandler?({ throw DomainError.parsingError })
                    return
                }
            } else if let result = result as? FlutterError {
                print("Flutter error \(result.message)")
                request.completionHandler?({ throw DomainError.sourceError })
                return
            } else if let result = result as? NSObject, result == FlutterMethodNotImplemented {
                // Response not nil but also not [String:Any]
                 print("Method \(request.useCase.rawValue) missing in flutter implementation")
                request.completionHandler?({ throw DomainError.methodMissing })
                return
            }
            // Nil response is considered a valid response
            request.completionHandler?({ return nil })
        })
    }
    
    // MARK: - Observable
    /// This function will store the observer along with its mapper.
    /// Mapping function should be part of the given entity. This function will map the received response from flutter (dictionary) to the requested Entity.
       /// Request parameters must be sent as a key / value pair. They will be sent to flutter inside a key value pair as the value for key "parameters"
    func performObservingRequest<Entity>(_ request: ObservingRequestC3<FlutterObservableUseCase, [String:Any], Entity>, keyToObserve: String, mapper: @escaping EntityMapper<Entity>) {
        guard let channel = self.channel else {
            request.observer.subscriptionHandler({ throw DomainError.sourceMissing })
            return
        }
     
        // Get observers for this entity
        let observersForEntity = entityObservers[request.observer.payloadDescription] as? [String:ModelObservers<Entity>] ?? [String:ModelObservers<Entity>]()
        
        // Get memory store for this entity
        let memoryStoreForEntity = observedEntityStore[request.observer.payloadDescription] as? [String:Entity] ?? [String:Entity]()
        
        // Register observer
        let registrationResult = ModelObservers<Entity>.registerObserver(request.observer, for: keyToObserve, in: observersForEntity, memoryStore: memoryStoreForEntity)

        // Update observer map. Assign mapper.
        registrationResult.updatedObservers[keyToObserve]?.mapper = mapper
        self.entityObservers[request.observer.payloadDescription] = registrationResult.updatedObservers as? [String:ModelObservers<Any>]
        
        if registrationResult.shouldCallRemote {
            let flutterParameters: [String : Any?] = [Constants.observedKey: keyToObserve, "parameters": request.parameters]
            channel.invokeMethod(request.useCase.rawValue, arguments: flutterParameters) { [request] (result) in
                /// Observing failed if we got back a FlutterError or FlutterMethodNotImplemented. Everything else is consigered a successful observation. Entity retrieval failures will be received via handleFlutterObservedCalls
                if let result = result as? FlutterError {
                    print("Flutter error \(result)")
                    request.observer.subscriptionHandler({ throw DomainError.sourceError })
                    return
                } else if let result = result as? NSObject, result == FlutterMethodNotImplemented {
                    // Response not nil but also not [String:Any]
                    print("Method \(request.useCase.rawValue) missing in flutter implementation")
                    request.observer.subscriptionHandler({ throw DomainError.methodMissing })
                    return
                }
                
            }
        }
    }
    
    /// Key: entity type name, Value: [Key: Observed key, Value: Any entity]
    private var observedEntityStore = [String: [String:Any]]()
    
    /// Key: entity type name, Value: [Key: Observerd key (e.g.: user Id, Value: ModelObservers for that key/entity]
    private var entityObservers = [String:[String:ModelObservers<Any>]]()
    
    /// Callback for observed entities and keys
    private func handleFlutterObservedCalls(_ call: FlutterMethodCall?) {
        if let entityName = call?.method, let arguments = call?.arguments as? [String:Any], let observedKey = arguments[Constants.observedKey] as? String {
            if let entityObservers = entityObservers[entityName], let keyObservers = entityObservers[observedKey]  {
                // Notify observers
                if let payload = keyObservers.notify(dictionary: arguments, error: nil) {
                    let keyStore = [observedKey:payload]
                    // Store observed value
                    observedEntityStore[entityName] = keyStore
                }
            }
        }
    }
    
    func getMemoryStore<Entity>(entityName: String, key: String) -> Entity? {
        // TODO: Manage TTL here
        return observedEntityStore[entityName]?[key] as? Entity
    }
    
    func expireEntityStore(entityName: String) {
        observedEntityStore.removeValue(forKey: entityName)
    }
    
    func expireSingleKeyStore(entityName: String, key: String) {
        observedEntityStore[entityName]?.removeValue(forKey: key)
    }
    
    func removeObserver<Entity>(observer: Observer<Entity>) {
        entityObservers[observer.payloadDescription]?.removeValue(forKey: observer.uniqueId)
    }
}
