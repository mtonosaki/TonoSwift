// Tono (Tools Of New Operation) library
//  MIT Lisence (c) 2021 Manabu Tonosaki all rights reserved
//  Created by Manabu Tonosaki on 2021/12/27.

import Foundation


// usage of this class, see also TspResolverLoopTest.swift
// try to find loop distance version TSP resolver.
open class TspResolverLoop: TspResolver {

    public func solve(data: [TspNode]) -> [TspNode] {
        nodes = Array(data)
        guard var nodes = nodes else { fatalError()}
        var indexes = (0..<nodes.count).map{ $0 }
        let tarIndexes = (0..<(indexes.count - 1)).map{ indexes[$0 + 1] }
        let res = optimize(indexArray: tarIndexes)
        for i in 0..<res.count {
            indexes[i + 1] = res[i]
        }
        let tmpNodes = Array(nodes)
        nodes.removeAll()
        for i in 0..<indexes.count {
            nodes.append(tmpNodes[indexes[i]])
        }
        return nodes
    }
    
    override func calcCost(indexArray: [Int]) -> Double {
        guard let delegate = delegate else { fatalError("Set delegte first before solve") }
        guard let nodes = nodes else {fatalError() }
        
        var ret = delegate.getTspCost(from: nodes[0], to: nodes[indexArray[0]], stage: .initialCost)
        for i in 1..<indexArray.count {
            ret += delegate.getTspCost(from: nodes[indexArray[i - 1]], to: nodes[indexArray[i]], stage: .normal)
        }
        ret += delegate.getTspCost(from: nodes[indexArray[indexArray.count - 1]], to: nodes[0], stage: .finalCostLoop)
        return ret
    }
}


// Try to find optimized start to end sequence version TSP resolver
open class TspResolverStartEndFix : TspResolver {

    public func solve(data: [TspNode]) -> [TspNode] {
        nodes = Array(data)
        guard var nodes = nodes else { fatalError()}
        var indexes = (0..<nodes.count).map{ $0 }
        let tarIndexes = (0..<(indexes.count - 2)).map{ indexes[$0 + 1] }
        let res = optimize(indexArray: tarIndexes)
        for i in 0..<res.count {
            indexes[i + 1] = res[i]
        }
        let tmpNodes = Array(nodes)
        nodes.removeAll()
        for i in 0..<indexes.count {
            nodes.append(tmpNodes[indexes[i]])
        }
        return nodes
    }

    override func calcCost(indexArray: [Int]) -> Double {
        guard let delegate = delegate else { fatalError("Set delegte first before solve") }
        guard let nodes = nodes else {fatalError() }
        
        var ret = delegate.getTspCost(from: nodes[0], to: nodes[indexArray[0]], stage: .initialCost)
        for i in 1..<indexArray.count {
            ret += delegate.getTspCost(from: nodes[indexArray[i - 1]], to: nodes[indexArray[i]], stage: .normal)
        }
        ret += delegate.getTspCost(from: nodes[indexArray[indexArray.count - 1]], to: nodes[nodes.count - 1], stage: .finalCostFix)
        return ret
    }
}



// Try to find the total optimized sequence version TSP resolver
open class TspResolverShuffle : TspResolver {

    public func solve(data: [TspNode]) -> [TspNode] {
        nodes = Array(data)
        guard var nodes = nodes else { fatalError()}
        var indexes = (0..<nodes.count).map{ $0 }
        let buf = Array(indexes)
        let res = optimize(indexArray: buf)
        for i in 0..<res.count {
            indexes[i] = res[i]
        }
        let tmp = Array(nodes)
        nodes.removeAll()
        for i in 0..<indexes.count {
            nodes.append(tmp[indexes[i]])
        }
        return nodes
    }

    override func calcCost(indexArray: [Int]) -> Double {
        guard let delegate = delegate else { fatalError("Set delegte first before solve") }
        guard let nodes = nodes else { fatalError() }
        
        var ret = 0.0
        for i in 1..<indexArray.count {
            ret += delegate.getTspCost(from: nodes[indexArray[i - 1]], to: nodes[indexArray[i]], stage: .normal)
        }
        return ret
    }
}

public enum TspCaluclationStage
{
    case initialCost
    case normal
    case finalCostFix
    case finalCostLoop
}

public protocol TspNode {
}

public protocol TspResolverDelegate {
    func getTspCost(from: TspNode, to: TspNode, stage: TspCaluclationStage) -> Double
}

open class TspResolver {

    final var delegate: TspResolverDelegate? = nil
    internal var nodes: Array<TspNode>? = nil
    
    // Cost Calculator
    func calcCost(indexArray: [Int]) -> Double {
        fatalError("need implement this method")
    }
    
    func optimize(indexArray: [Int]) -> [Int] {
        var indexes = Array(indexArray)
        let n = indexes.count
        var cs = (0...n).map{ $0 }
        var res = Array(indexes)
        if indexes.count <= 0 {
            return res
        }
        var rescost = calcCost(indexArray: indexes)
        var i = 0
        repeat {
            let t = indexes[i]
            let q = (i & 1) == 0 ? 0 : cs[i]
            indexes[i] = indexes[q]
            indexes[q] = t
            
            let cost = calcCost(indexArray: indexes)
            if rescost > cost {
                res = Array(indexes)
                rescost = cost
            }
            i = 0
            while  cs[i] == 0 {
                cs[i] = i
                i += 1
            }
            cs[i] -= 1
            
        } while i < n
        
        return res
    }
}
