// (c) 2019 Manabu Tonosaki
// Licensed under the MIT license.
// Ported to Swift

import Foundation

/// make integer distribution
///
/// - Example:
/// USAGE-1: Divide value mode ================================================
/// ```swift
/// let id = IntegerDistributer(value: 27, div: 8) // 27 ÷ 8 = 3.375
/// for n in id {
///     print("\(n) : ", terminator: "")
/// }
/// // Result: 4 : 3 : 4 : 3 : 3 : 4 : 3 : 3 :  (8 numbers, sum of them = 27)
/// ```
///
/// USAGE-2: Add value mode ================================================
/// ```swift
/// let id = IntegerDistributer()
/// id.add(1.6)
/// id.add(1.6)
/// id.add(2.6)
/// id.add(1.8)
/// id.add(1.4) // 5 items. Total=9
/// for n in id {
///     print("\(n) : ", terminator: "")
/// }
/// // Result: 2 : 2 : 2 : 2 : 1 :  (5 numbers, sum of them = 9)
/// ```
///
/// Priority Modes:
/// - Normal : head weight
/// - Option : middle weight
public class IntegerDistributer: Sequence {
    
    private var isFirstPriority: Bool = true
    private var value: Double = 0
    private var div: Double = 1
    private var rets: [Int]? = nil
    private var preValue: Double = 0
    
    public var count: Int {
        if let rets = rets {
            return rets.count
        }
        return Int(div)
    }
    
    @discardableResult
    public func setFirstPriorityMode() -> IntegerDistributer {
        isFirstPriority = true
        return self
    }
    
    @discardableResult
    public func setMiddlePriorityMode() -> IntegerDistributer {
        isFirstPriority = false
        return self
    }
    
    public init() {
        initAsValueAddMode()
    }
    
    public init(vals: [Double]) {
        initAsValueAddMode()
        add(vals)
    }
    
    private func initAsValueAddMode() {
        rets = []
        value = 0
        preValue = 0
        div = 0
    }
    
    public func add(_ val: Double) {
        assert(rets != nil, "The functionality differs depending on the constructor. Currently, it is not built in a mode that allows adding.")
        
        preValue = value
        value += val
        div += 1
        
        let ret: Int
        if isFirstPriority {
            ret = Int(ceil(value) - ceil(preValue))
        } else {
            ret = Int(round(value) - round(preValue))   // NOT use .toNearestOrEven
        }
        rets?.append(ret)
    }
    
    public func add(_ vals: [Double]?) {
        guard let vals = vals else { return }
        for val in vals {
            add(val)
        }
    }
    
    public init(value: Double, div: Int) {
        self.value = value
        self.div = Double(div)
        self.rets = nil
    }
    
    public convenience init(value: Int, div: Int) {
        self.init(value: Double(value), div: div)
    }
    
    public subscript(index: Int) -> Int {
        if index < 0 || index >= Int(div) {
            return 0
        }
        
        if let rets = rets {
            return rets[index]
        } else {
            let pre = value / div * Double(index)
            let now = value / div * Double(index + 1)
            
            if isFirstPriority {
                return Int(ceil(now) - ceil(pre))
            } else {
                return Int(round(now) - round(pre))   // NOT use .toNearestOrEven
            }
        }
    }
    
    public func makeIterator() -> AnyIterator<Int> {
        var pos = 0
        let limit = Int(self.div)
        
        return AnyIterator {
            if pos >= limit {
                return nil
            }
            let current = self[pos]
            pos += 1
            return current
        }
    }
}
