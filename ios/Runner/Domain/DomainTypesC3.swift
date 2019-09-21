//
//  DataTypesC3.swift
//  HCSUser
//
//  Created by Raul Rea on 8/14/19.
//  Copyright © 2019 Raul Rea. All rights reserved.
//

import Foundation

enum DomainError: LocalizedError {
    case methodMissing
    case sourceMissing
    case sourceError
    case parsingError
}

class RequestC3<UseCase, Parameters, Entity> {
    init(useCase: UseCase, parameters: Parameters? = nil) {
        self.useCase = useCase
        self.parameters = parameters
    }
    let useCase: UseCase
    let parameters: Parameters?
}

class AsyncRequestC3<AsyncUseCase, Parameters, Entity>: RequestC3<AsyncUseCase, Parameters, Entity> {
    init(useCase: AsyncUseCase, parameters: Parameters? = nil, completionHandler: ThrowingHandler<Entity>? = nil) {
        self.completionHandler = completionHandler
        super.init(useCase: useCase, parameters: parameters)
    }
    
    var completionHandler: ThrowingHandler<Entity>?
}

class ObservingRequestC3<ObservableUseCase, Parameters, Entity>: RequestC3<ObservableUseCase, Parameters, Entity>{
    let observer: Observer<Entity>
    
    init(useCase: ObservableUseCase, parameters: Parameters? = nil, observer: Observer<Entity>) {
        self.observer = observer
        super.init(useCase: useCase, parameters: parameters)
    }
}

protocol DecodableEntity {
    static func decode(dictionary: Dictionary<String,Any>) -> Self
}

protocol RepositoryC3 {
    /// Enums
    associatedtype UseCase
    associatedtype AsyncUseCase
    associatedtype ObservableUseCase
}

protocol RequestableRepository: RepositoryC3 {
    func performRequest<Parameter, Entity>(_ request: RequestC3<UseCase, Parameter, Entity>) -> Entity?
    func performAsyncRequest<Parameter, Entity>(_ request: AsyncRequestC3<AsyncUseCase, Parameter, Entity>)
    func performObservingRequest<Parameter, Entity>(_ request: ObservingRequestC3<ObservableUseCase, Parameter, Entity>, keyToObserve: String)
}

protocol DictionaryRepositoryC3: RepositoryC3 {
    func performRequest<Entity>(_ request: RequestC3<UseCase, [String:Any], Entity>, mapper: EntityMapper<Entity>) -> Entity?
    func performAsyncRequest<Entity>(_ request: AsyncRequestC3<AsyncUseCase, [String:Any], Entity>, mapper: @escaping EntityMapper<Entity>)
    func performObservingRequest<Entity>(_ request: ObservingRequestC3<ObservableUseCase, [String:Any], Entity>, keyToObserve: String, mapper: @escaping EntityMapper<Entity>)
}


/// This handler allows for asynchronous error throwing
typealias ThrowingHandler<Response> = (() throws -> Response?) -> Void

/// Found https://stackoverflow.com/a/24128121
/// Used to hold weak references in dictionaries or arrays.
class Weak<T: AnyObject> {
    weak var reference: T?
    init(_ reference: T) {
        self.reference = reference
    }
}

// MARK: - Observers
struct ObserversError: Error {
    enum Kind {
        case observerAlreadyExists
        case observerNotFound
        case keyObservers
    }
    var kind: Kind
}

class Observer<PayloadType> {
    /// Class name is preferred.
    let uniqueId: String
    let payloadDescription: String = String(describing: PayloadType.self)
    let subscriptionHandler: ThrowingHandler<PayloadType>
    
    init(uniqueId: String = UUID().uuidString, subscriptionHandler: @escaping ThrowingHandler<PayloadType>) {
        self.uniqueId = uniqueId
        self.subscriptionHandler = subscriptionHandler
    }
}

class ModelObservers<PayloadType> {
    var mapper: EntityMapper<PayloadType>?
    
    /// Key: Observer unique id, Value: observer for payload type
    private var observers = [String: Weak<Observer<PayloadType>>]()
    private let threadSafeQueue: DispatchQueue
    
    private func getObservers() -> [String: Weak<Observer<PayloadType>>] {
        return self.threadSafeQueue.sync { return self.observers }
    }
    
    init() {
        // Initialize thread safe queue
        let identifier = Bundle.main.bundleIdentifier ?? "com.concurrent"
        let queueLabel = identifier + ".modelObservers." + String(describing: PayloadType.self)
        if #available(iOS 10.0, *) {
            self.threadSafeQueue = DispatchQueue(label: queueLabel, qos: .userInitiated, attributes: [.concurrent], autoreleaseFrequency: .workItem)
        } else {
            // Fallback on earlier versions
            self.threadSafeQueue = DispatchQueue(label: queueLabel, qos: .userInitiated, attributes: [.concurrent], autoreleaseFrequency: .inherit)
        }
    }
    
    var isEmpty: Bool {
        return observers.isEmpty
    }
    
    /// If the observer already exists, returns false. Observer is not added again.
    @discardableResult func addObserver(observer: Observer<PayloadType>) -> Bool {
        // Check if we already have an observer with this Id.
        let existingObserver = self.threadSafeQueue.sync { return self.observers[observer.uniqueId] }
        if existingObserver != nil {
            return false
        }
        self.threadSafeQueue.async(flags: .barrier) {
            self.observers[observer.uniqueId] = Weak(observer)
        }
        return self.threadSafeQueue.sync { return true }
    }
    
    func removeObserver(observer: Observer<PayloadType>)  {
        // Check if we have an observer with this Id.
        let existingObserver = self.threadSafeQueue.sync { return self.observers[observer.uniqueId] }
        if existingObserver == nil {
            observer.subscriptionHandler({ throw ObserversError(kind: .observerNotFound) })
        }
        self.threadSafeQueue.async(flags: .barrier) {
            self.observers[observer.uniqueId] = nil
        }
    }
    
    func removeAll() {
        self.threadSafeQueue.async(flags: .barrier) {
            self.observers.removeAll()
        }
    }
    
    func notify(payload: PayloadType?, error: Error?) {
        if let error = error {
            for eachObserver in getObservers() {
                eachObserver.value.reference?.subscriptionHandler({ throw error })
            }
        } else if let payload = payload {
            for eachObserver in getObservers() {
                eachObserver.value.reference?.subscriptionHandler({ return payload })
            }
        } else {
            print("Nothing to notify \(String(describing: PayloadType.self)) observers")
        }
    }
    
    func notify(dictionary: [String:Any]?, error: Error?) -> PayloadType? {
        if let error = error {
            for eachObserver in getObservers() {
                eachObserver.value.reference?.subscriptionHandler({ throw error })
            }
        } else if let dictionary = dictionary {
            if let payload = mapper?(dictionary) {
                for eachObserver in getObservers() {
                    eachObserver.value.reference?.subscriptionHandler({ return payload })
                }
                return payload
            }
        } else {
            print("Nothing to notify \(String(describing: PayloadType.self)) observers")
        }
        return nil
    }
    
    /// Registers observer into modelObservers using the provided key. If there are observers for that key in modelObservers already, it will call the observer subscription handler with the memory store.
    ///
    /// - Parameters:
    ///   - observer: observer object received from a presenter
    ///   - key: key that will be observed (user Id, date Id, center Id, device Id or serial number, etc)
    ///   - modelObservers: Key: Observed key (e.g. user Id). Value: ModelObservers class for the provided key (e.g. observers for that user id). ModelObservers keeps pointers of provided observers and manages notifying them of any updates
    ///   - memoryStore: Map holding the latest value received from a data source subscription handler for the provided key.
    /// - Returns: shouldCallRemote: Bool indicating that the memory store is stale (nil), updatedObservers: [String:ModelObservers<T>] map of the updated ModelObservers for the provided key.
    static func registerObserver<T>(_ observer: Observer<T>, for key: String, in modelObservers: [String:ModelObservers<T>], memoryStore: [String: T]) -> (shouldCallRemote: Bool, updatedObservers: [String:ModelObservers<T>]) {
        var modelObservers = modelObservers
        // Get observers for this key
        if let entityObserversForSpecifiedKey = modelObservers[key] {
            // Already being observed by this or other observers. Call add new observer, if the observer already exists, addObserver will return false.
            if entityObserversForSpecifiedKey.addObserver(observer: observer) {
                // New observer added for a key that was already being observed.
                modelObservers[key] = entityObserversForSpecifiedKey
            }
            if let memoryData = memoryStore[key] {
                // Observed data cached in memory. TTL Manager should make sure it is not stale.
                // Return memory data
                observer.subscriptionHandler({ return memoryData })
            } else {
                // No data in memory, go fetch
                // Call remote observing function
                return(true, modelObservers)
            }
        } else {
            // No observers been registerd for this key, we can assume memory store is non existent or obsolete.
            // Create model observers to track mqtt call backs.
            let newModelObserversForKey = ModelObservers<T>()
            newModelObserversForKey.addObserver(observer: observer)
            modelObservers[key] = newModelObserversForKey
            // Call remote observing function
            return(true, modelObservers)
        }
        return(false, modelObservers)
    }
    
}
