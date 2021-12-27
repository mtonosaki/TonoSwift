//
//  File.swift
//  
//
//  Created by Manabu Tonosaki on 2021/12/27.
//

import XCTest
@testable import Tono

class TspResolverLoopTest: XCTestCase, TspResolverDelegate {

    func getTspCost(from: TspNode, to: TspNode, stage: TspCaluclationStage) -> Double {
        guard let nodex = from as? Node else { fatalError() }
        guard let nodey = to as? Node else { fatalError() }
        
        switch "\(nodex.name)\(nodey.name)" {
            case "AB": return 6
            case "BA": return 6
            case "AC": return 5
            case "CA": return 5
            case "AD": return 5
            case "DA": return 5
            case "BC": return 7
            case "CB": return 7
            case "BD": return 4
            case "DB": return 4
            case "CD": return 3
            case "DC": return 3
            default: fatalError()
        }
    }
    
    
    struct Node: TspNode {
        var name: String
    }
    
    func test_Loop() {
        let tsp = TspResolverLoop()
        tsp.delegate = self
        let nodes = [Node(name: "A"), Node(name: "B"), Node(name: "C"), Node(name: "D")]
        let ret = tsp.solve(data: nodes)
        let retstr = ret.compactMap { $0 as? Node }.map{ $0.name }
        let retjoin = retstr.joined(separator: "")
        XCTAssertEqual(retjoin, "ABDC")
    }

    func test_Shuffle() {
        let tsp = TspResolverShuffle()
        tsp.delegate = self
        let nodes = [Node(name: "A"), Node(name: "B"), Node(name: "C"), Node(name: "D")]
        let ret = tsp.solve(data: nodes)
        let retstr = ret.compactMap { $0 as? Node }.map{ $0.name }
        let retjoin = retstr.joined(separator: "")
        XCTAssertEqual(retjoin, "BDCA")
    }
    
    func test_TspResolverStartEndFix() {
        let tsp = TspResolverStartEndFix()
        tsp.delegate = self
        let nodes = [Node(name: "A"), Node(name: "B"), Node(name: "C"), Node(name: "D")]
        let ret = tsp.solve(data: nodes)
        let retstr = ret.compactMap { $0 as? Node }.map{ $0.name }
        let retjoin = retstr.joined(separator: "")
        XCTAssertEqual(retjoin, "ABCD")
    }
}

