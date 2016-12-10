//
//  ViewController.swift
//  Sweeft
//
//  Created by Mathias Quintero on 11/20/2016.
//  Copyright (c) 2016 Mathias Quintero. All rights reserved.
//

import UIKit
import Sweeft

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Here are a few examples of how to use Sweeft
        
        let array: [Int?]? = [1, 2, 3, nil, 5, nil]
        
        let res = (array ?? [])
            .flatMap { $0 }
            .filter { $0 & 1 == 0 }
        
        print(res)
        
        let even = !array |> { $0 & 1 == 0 }
        
        array => { item, index in
            // Do Stuff
        }
        
        print(even)
        
        let extra = (0...100) => { $0 ** 2 } |> { ($0 + 1).isPrime || ($0 - 1).isPrime }
        
        print(extra)
        
        let palindromePrimes = (0...1000) |> { $0.isPalindrome } |> { $0.isPrime }
        
        print(palindromePrimes)
        
        let sum = !array ==> (+)
        
        print(sum.?)
        
        print(24.reversed)
        
        let dict = ["String": "Other String"]
        
        print(dict.flipped)
        
        print(79.primeFactors)
        
        let item = dict.flipped.flipped | "String"
        
        print(item.?)
        
        let arrayWithDuplicates = [1, 2, 1, 5, 3]
        
        let secondToLast = arrayWithDuplicates | -2
        
        print(secondToLast.?)
        
        print(arrayWithDuplicates.noDuplicates)
        
        5.0 >>> {
            print("Other Thread Called!")
        }
        
        let dates = Date.array(ofSize: 5)
        
        let seconds = dates.join { $0.string(with: "ss") }
        
        print(seconds)
        
        let hours = dates ==> { $0.string(with: "HH") } >>> { Int($0) }
        
        print(hours)
        
        dates => { item in
            print(item.string(with: "dd hh:mm a"))
        }
        
        let valueOfString = dict.match(containing: "str").?
        
        print(valueOfString)
        
    }

}

