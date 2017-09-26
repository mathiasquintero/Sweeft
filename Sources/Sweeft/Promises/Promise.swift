//
//  Promise.swift
//
//  Created by Mathias Quintero on 12/2/16.
//
//

import Foundation

public typealias ResultPromise<R> = Promise<R, AnyError>

enum PromiseState<T, E: Error> {
    case done(result: Result<T, E>)
    case waiting
    
    var isDone: Bool {
        guard case .done = self else {
            return false
        }
        return true
    }
    
    var result: Result<T, E>? {
        guard case .done(let result) = self else {
            return nil
        }
        return result
    }
    
    var value: T? {
        return result?.value
    }
    
    var error: E? {
        return result?.error
    }
}

public protocol PromiseBody {
    associatedtype ResultType
    associatedtype ErrorType: Error
    func onSuccess<O>(call handler: @escaping (ResultType) -> (O)) -> PromiseSuccessHandler<O, ResultType, ErrorType>
    func onError<O>(call handler: @escaping (ErrorType) -> (O)) -> PromiseErrorHandler<O, ResultType, ErrorType>
    func nest<V>(to promise: Promise<V, ErrorType>, using mapper: @escaping (ResultType) -> (V))
    func nest<V>(to promise: Promise<V, ErrorType>, using mapper: @escaping (ResultType) -> ())
}

/// Promise Structs to prevent you from nesting callbacks over and over again
public class Promise<T, E: Error>: PromiseBody {
    /// Type of the success
    typealias SuccessHandler = (T) -> ()
    /// Type of the success
    typealias ErrorHandler = (E) -> ()
    // Result Type
    public typealias Result = Sweeft.Result<T, E>
    // Type of result handler
    public typealias ResultHandler = (Result) -> ()
    
    /// All the handlers
    var successHandlers = [SuccessHandler]()
    var errorHandlers = [ErrorHandler]()
    var resultHandlers = [ResultHandler]()
    var state: PromiseState<T, E> = .waiting
    let completionQueue: DispatchQueue
    
    /// Initializer
    public init(completionQueue: DispatchQueue = .global()) {
        self.completionQueue = completionQueue
    }
    
    public init(result: Result, completionQueue: DispatchQueue = .global()) {
        self.completionQueue = completionQueue
        self.state = .done(result: result)
    }
    
    public static func with(result: Result) -> Promise<T, E> {
        return Promise(result: result)
    }
    
    public static func successful(with value: T) -> Promise<T, E> {
        return .with(result: .value(value))
    }
    
    public static func errored(with value: E) -> Promise<T, E> {
        return .with(result: .error(value))
    }
    
    public static func new(completionQueue: DispatchQueue = .global(), _ handle: (Promise<T, E>) -> ()) -> Promise<T, E> {
        let promise = Promise<T, E>(completionQueue: completionQueue)
        handle(promise)
        return promise
    }
    
    /**
     Add success handler
     
     - Parameter handler: function that should be called
     
     - Returns: PromiseHandler Object
     */
    @discardableResult public func onSuccess<O>(call handler: @escaping (T) -> (O)) -> PromiseSuccessHandler<O, T, E> {
        return PromiseSuccessHandler<O, T, E>(promise: self, handler: handler)
    }
    
    /// Add an error Handler
    @discardableResult public func onError<O>(call handler: @escaping (E) -> (O)) -> PromiseErrorHandler<O, T, E> {
        return PromiseErrorHandler<O, T, E>(promise: self, handler: handler)
    }
    
    /// Add a
    @discardableResult public func onResult(call handler: @escaping ResultHandler) -> Promise<T, E> {
        if let result = state.result {
            handler(result)
        } else {
            resultHandlers.append(handler)
        }
        return self
    }
    
    /// Call this when the promise is fulfilled
    public func success(with value: T) {
        guard !state.isDone else {
            return
        }
        state = .done(result: .value(value))
        let handlers = successHandlers + (resultHandlers => calling)
        successHandlers = []
        errorHandlers = []
        resultHandlers = []
        completionQueue >>> {
            handlers => apply(value: value)
        }
    }
    
    /// Call this when the promise has an error
    public func error(with value: E) {
        guard !state.isDone else {
            return
        }
        state = .done(result: .error(value))
        let handlers = errorHandlers + (resultHandlers => calling)
        successHandlers = []
        errorHandlers = []
        resultHandlers = []
        completionQueue >>> {
            handlers => apply(value: value)
        }
    }
    
    /// Will nest a promise inside another one
    public func nest<V>(to promise: Promise<V, E>, using mapper: @escaping (T) -> (V)) {
        onSuccess(call: mapper >>> promise.success)
        onError(call: promise.error)
    }
    
    /// Will nest a promise inside another one
    public func nest<V>(to promise: Promise<V, E>, using mapper: @escaping (T) -> ()) {
        onSuccess(call: mapper)
        onError(call: promise.error)
    }
    
    /// Will create a Promise that is based on this promise but maps the result
    public func map<V>(completionQueue: DispatchQueue = .global(),
                          _ mapper: @escaping (T) -> V) -> Promise<V, E> {
        
        return .new(completionQueue: completionQueue) { promise in
            self.nest(to: promise, using: mapper)
        }
    }
    
    public func flatMap<V>(completionQueue: DispatchQueue = .global(),
                        _ mapper: @escaping (T) -> Promise<V, E>) -> Promise<V, E> {
        
        return .new(completionQueue: completionQueue) { promise in
            self.onSuccess(call: mapper).future.nest(to: promise, using: id)
        }
    }
    
    public func generalizeError(completionQueue: DispatchQueue = .global()) -> Promise<T, AnyError> {
        return .new(completionQueue: completionQueue) { promise in
            onSuccess(call: promise.success)
            onError(call: AnyError.error >>> promise.error)
        }
    }
    
    public func wait() -> Result {
        let group = DispatchGroup()
        var result: Result!
        group.enter()
        onResult { output in
            result = output
            group.leave()
        }
        group.wait()
        return result
    }
    
}

