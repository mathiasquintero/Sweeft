//
//  Functional.swift
//  Swiftoids
//
//  Created by Mathias Quintero on 11/20/16.
//  Copyright © 2016 Mathias Quintero. All rights reserved.
//

import Foundation

infix operator **

/**
 Exponentiates
 
 - Parameters:
 - a: Base
 - b: Exponent
 
 - Returns: a to the b
 */
public func **(_ a: Double, _ b: Double) -> Double {
    return pow(a, b)
}

/**
 Exponentiates
 
 - Parameters:
 - a: Base
 - b: Exponent
 
 - Returns: a to the b
 */
public func **(_ a: Int, _ b: Int) -> Int {
    let a = 5 % 2
    return Int(Double(a) ** Double(b))
}

/**
 Remainder
 
 - Parameters:
 - a: number
 - b: divider
 
 - Returns: remainder of a after dividing by b
 */
public func %(_ a: Double, _ b: Double) -> Double {
    return a.remainder(dividingBy: b)
}

prefix operator |

/**
 Abs
 
 - Parameters:
 - value: Number
 
 - Returns: absolut value of the input
 */
public prefix func |(_ value: Int) -> Int {
    return abs(value)
}

infix operator ~~

/**
 Matches
 
 - Parameters:
 - left: String
 - right: Pattenr
 
 - Returns: does the string match the pattern
 */
public func ~~(left: String, right: String) -> Bool {
    return .?(try? left.matches(pattern: right, options: []))
}