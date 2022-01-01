// Tono (Tools Of New Operation) library
//  MIT Lisence (c) 2021 Manabu Tonosaki all rights reserved
//  Created by Manabu Tonosaki on 2021/12/27.

import Foundation


// Distribute items with GCM (Goal Chasing Method) algorithm
// usage:
// var gcm = GcmDistributer()
// gcm.append(MyNodeType(...), frequency: 6)
public struct GcmDistributer : IteratorProtocol, Sequence {

    var totalFrequency = 0.0
    var inputValues = Dictionary<AnyHashable, Double>()
    var workValues = Dictionary<AnyHashable, Double>()
    var currentValue: AnyHashable? = nil
    var loop = 0.0
    
    mutating func append(_ newElement: AnyHashable, frequency: Double) {
        
        let maybeval = inputValues[newElement]
        if maybeval == nil {
            inputValues[newElement] = frequency
        } else {
            inputValues[newElement] = maybeval! + frequency
        }
        totalFrequency += frequency
    }
    
    public mutating func next() -> AnyHashable? {

        if inputValues.count == 0 {
            return nil
        }
        defer {
            if workValues.count == 0 {
                for key in inputValues.keys {
                    workValues[key] = 0
                }
                loop = 0
            }
            
            // find max value
            var maxVal = -1.0
            currentValue = nil
            for kv in inputValues {
                if let val = workValues[kv.key] {
                    workValues[kv.key] = val + kv.value
                    if val > maxVal {
                        maxVal = val
                        currentValue = kv.key
                    }
                }
            }
            workValues[currentValue!] = (workValues[currentValue!] ?? 0) + totalFrequency
            loop += 1
        }
        return loop <= totalFrequency ? currentValue : nil
    }
}
