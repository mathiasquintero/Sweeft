//
//  PromiseHandler.swift
//  Pods
//
//  Created by Mathias Quintero on 12/11/16.
//
//

import Foundation

/// Enum For Representing an Empty Error Domain
public enum NoError: Error {}
public enum AnyError: Error {
    case error(Error)
}

extension AnyError: GenerizableError {
    
    public init(error: Error) {
        self = .error(error)
    }
    
}

extension AnyError {
    
    public var error: Error {
        switch self {
        case .error(let error):
            return error
        }
    }
    
}

/// Structure that allows us to nest callbacks more nicely
public struct PromiseSuccessHandler<R, T, E: Error> {
    
    typealias Handler = (T) -> R
    
    private weak var promise: Promise<T, E>!
    private var handler: Handler
    
    init(promise: Promise<T, E>, handler: @escaping Handler) {
        self.promise = promise
        self.handler = handler
        if let result = promise.state.value {
            _ = handler(result)
        } else {
            promise.successHandlers.append(handler**)
        }
    }
    
    /// Add an action after the current item
    @discardableResult public func then<O>(_ handler: @escaping (R) -> (O)) -> PromiseSuccessHandler<O, T, E> {
        _ = promise.successHandlers.popLast()
        return PromiseSuccessHandler<O, T, E>(promise: promise, handler: self.handler >>> handler)
    }
    
    /// Add a success Handler
    @discardableResult public func and<O>(call handler: @escaping (T) -> (O)) -> PromiseSuccessHandler<O, T, E> {
        return promise.onSuccess(call: handler)
    }
    
    /// Add an error Handler
    @discardableResult public func onError<O>(call handler: @escaping (E) -> (O)) -> PromiseErrorHandler<O, T, E> {
        return promise.onError(call: handler)
    }
    
}

public extension PromiseSuccessHandler where R: PromiseBody, R.ErrorType == E {
    
    /// Promise returned by the handler
    public var future: Promise<R.ResultType, R.ErrorType> {
        return .new { promise in
            self.then { $0.nest(to: promise, using: id) }
            self.onError(call: promise.error)
        }
    }
    
}

/// Structure that allows us to nest callbacks more nicely
public struct PromiseErrorHandler<R, T, E: Error> {
    
    typealias Handler = (E) -> R
    
    private var promise: Promise<T, E>
    private var handler: Handler
    
    init(promise: Promise<T, E>, handler: @escaping Handler) {
        self.promise = promise
        self.handler = handler
        if let error = promise.state.error {
            _ = handler(error)
        } else {
            promise.errorHandlers.append(handler**)
        }
    }
    
    /// Add an action to be done afterwards
    @discardableResult public func then<O>(_ handler: @escaping (R) -> (O)) -> PromiseErrorHandler<O, T, E> {
        _ = promise.errorHandlers.popLast()
        return PromiseErrorHandler<O, T, E>(promise: promise, handler: self.handler >>> handler)
    }
    
    /// Add a success Handler
    @discardableResult public func onSuccess<O>(call handler: @escaping (T) -> (O)) -> PromiseSuccessHandler<O, T, E> {
        return promise.onSuccess(call: handler)
    }
    
    /// Add an error Handler
    @discardableResult public func and<O>(call handler: @escaping (E) -> (O)) -> PromiseErrorHandler<O, T, E> {
        return promise.onError(call: handler)
    }
    
}
