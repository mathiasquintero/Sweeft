//
//  Int.swift
//
//  Created by Mathias Quintero on 11/20/16.
//  Copyright © 2016 Mathias Quintero. All rights reserved.
//

import Foundation

public extension Int {
    
    /// Will return all the prime factors of the number
    var primeFactors: [Int] {
        if self < 0 {
            return [-1] + (-self).primeFactors
        } else if self <= 2 {
            return [self]
        }
        let bound = Int(sqrt(Double(self))) + 1
        guard let firstPrime = (2...bound) |> { self % $0 == 0 } | 0 else {
            return [self]
        }
        return [firstPrime] + (self / firstPrime).primeFactors
    }
    
    /// Determines if the value is even
    var isEven: Bool {
        return self & 1 == 0
    }
    
    /// Determines if the value is odd
    var isOdd: Bool {
        return !isEven
    }
    
    /// Gives an Array of the digits in the number
    var digits: [Int] {
        return self.description.characters => { String($0) } ==> { Int($0) }
    }
    
    /// Will say it is prime
    var isPrime: Bool {
        if self < 2 {
            return false
        }
        return primeFactors.count == 1
    }
    
    /// Will say if the string representation is a palindrome. (Without signing)
    var isPalindrome: Bool {
        return abs(self).description.isPalindrome
    }
    
    /// Will return a reversed version of the integer
    var reversed: Int {
        return self | { $0.description.reversed } | Int.init.?
    }
    
}

extension Int: Defaultable {
    
    /// Default Value
    public static let defaultValue = 0
    
}
