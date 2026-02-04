//
//  IntegerDistributerTest.swift
//  Tono
//
//  Created by Manabu Tonosaki on 2026-02-04.
//

import XCTest
@testable import Tono

class IntegerDistributerTest: XCTestCase {
    
    func test001() {
        let ret = IntegerDistributer(value: 27, div: 8)
        
        XCTAssertEqual(ret.count, 8)
        
        let sum = ret.reduce(0, +)
        XCTAssertEqual(sum, 27)
        
        for val in ret {
            XCTAssertTrue(type(of: val) == Int.self)
        }
    }
    
    func test002() {
        let ret = IntegerDistributer()
        
        ret.add(1.6)
        ret.add(1.6)
        ret.add(2.6)
        ret.add(1.8)
        ret.add(1.4) // 5 items. Total = 9.0
        
        let col = Array(ret)
        
        XCTAssertEqual(col[0], 2)
        XCTAssertEqual(col[1], 2)
        XCTAssertEqual(col[2], 2)
        XCTAssertEqual(col[3], 2)
        XCTAssertEqual(col[4], 1)
    }
    
    func test003() {
        let id = IntegerDistributer(value: 2, div: 24)
            .setFirstPriorityMode() // First weight mode
            .map { String($0) }
        
        let resultString = id.joined()
        XCTAssertEqual(resultString, "100000000000100000000000")
    }
    
    func test004() {
        let id = IntegerDistributer(value: 2, div: 24)
            .setMiddlePriorityMode() // middle weight mode
            .map { String($0) }
        
        let resultString = id.joined()
        XCTAssertEqual(resultString, "000001000000000001000000")
    }
}
