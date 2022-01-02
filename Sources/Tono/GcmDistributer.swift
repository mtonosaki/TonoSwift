// Tono (Tools Of New Operation) library
//  MIT Lisence (c) 2021 Manabu Tonosaki all rights reserved
//  Created by Manabu Tonosaki on 2021/12/27.

import Foundation


// Distribute items with GCM (Goal Chasing Method) algorithm
// usage:
// var gcm = GcmDistributer()
// gcm.append(MyNodeType(...), frequency: 6)
public struct GcmDistributer : IteratorProtocol, Sequence {

    var totalFrequency: Int = 0
    var inputValues = Dictionary<AnyHashable, Int>()
    var workValues = Dictionary<AnyHashable, Int>()
    var currentValue: AnyHashable? = nil
    var loop: Int = 0
    var isInitialNext = true

    var count: Int {
        get {
            return totalFrequency
        }
    }
    
    mutating func append(_ newElement: AnyHashable, frequency: Int) {
        
        let maybeval = inputValues[newElement]
        if maybeval == nil {
            inputValues[newElement] = frequency
        } else {
            inputValues[newElement] = maybeval! + frequency
        }
        totalFrequency += frequency
    }
    
    public mutating func next() -> AnyHashable? {

        if isInitialNext {
            if inputValues.count == 0 {
                return nil
            }
            for key in inputValues.keys {
                workValues[key] = 0
            }
            isInitialNext = false
            loop = 0
            doNext()    // make initial currentValue
        }
        defer {
            doNext()
        }
        return currentValue
    }
    
    private mutating func doNext() {
        
        if loop >= totalFrequency {
            currentValue = nil
            return
        }
        // find max value
        var maxVal = -1
        currentValue = nil
        for inputKeyValue in inputValues {
            let workValue = workValues[inputKeyValue.key]! + inputKeyValue.value
            workValues[inputKeyValue.key] = workValue
            if workValue > maxVal {
                maxVal = workValue
                currentValue = inputKeyValue.key
            }
        }
        workValues[currentValue!] = (workValues[currentValue!] ?? 0) - totalFrequency
        loop += 1
    }
}
