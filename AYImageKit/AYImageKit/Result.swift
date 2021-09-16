//
//  Result.swift
//  AYImageKit
//
//  Created by Adnan Yousaf on 16/09/2021.
//

import Foundation

/**
 Represents the result of an operation that can
 either fail or succeed.
 */
public enum Result<Value> {
    
    case failure(Error)
    case success(Value)
    
    /// Returns an error in case of failure
    public var error: Error? {
        switch self {
        case .failure(let error): return error
        case .success: return nil
        }
    }
    
    /// Return the value in case of success
    public var value: Value? {
        switch self {
        case .failure: return nil
        case .success(let value): return value
        }
    }
    
    /**
    Converts the value of a result if any.
    Implements the Functor pattern.
    */
    public func map<T>(_ transform: (Value) throws -> T) -> Result<T> {
        switch self {
        case .failure(let error): return .failure(error)
        case .success(let value):
            do {
                return .success(try transform(value))
            } catch {
                return .failure(error)
            }
        }
    }
    
    /**
     Converts a throwing closure into a result.
     */
    public init(catching body: () throws -> Value) {
        do {
            let value = try body()
            self = .success(value)
        } catch {
            self = .failure(error)
        }
    }
    
}


