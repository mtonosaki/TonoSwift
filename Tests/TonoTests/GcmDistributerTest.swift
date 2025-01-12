//
//  File.swift
//  
//
//  Created by Manabu Tonosaki on 2021/12/31.
//

import XCTest
@testable import Tono

class GcmDistributerTestTest: XCTestCase {
    
    struct GcmNode : Hashable {
        var id: String = UUID().uuidString
        var name: String
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        var description: String { return name }
    }
    
    func test_constant() {
        var gcm = GcmDistributer()
        gcm.append(GcmNode(name: "A"), frequency: 6)
        gcm.append(GcmNode(name: "B"), frequency: 3)
        gcm.append(GcmNode(name: "C"), frequency: 1)

        let ret1 = Array(gcm)
        let retstr1 = ret1.compactMap { $0 as? GcmNode }.map{ $0.name }
        let retjoin1 = retstr1.joined(separator: "")

        let ret2 = Array(gcm)
        let retstr2 = ret2.compactMap { $0 as? GcmNode }.map{ $0.name }
        let retjoin2 = retstr2.joined(separator: "")
        
        XCTAssertEqual(retjoin1, retjoin2)
        
        var retjoin3 = ""
        for node in gcm {
            if let node = node as? GcmNode {
                retjoin3 += node.name
            }
        }
        XCTAssertEqual(retjoin1, retjoin3)
    }

    func test_value_quality() {
        var gcm = GcmDistributer()
        gcm.append(GcmNode(name: "A"), frequency: 6)
        gcm.append(GcmNode(name: "B"), frequency: 3)
        gcm.append(GcmNode(name: "C"), frequency: 1)
        let ret1 = Array(gcm)
        let retstr1 = ret1.compactMap { $0 as? GcmNode }.map{ $0.name }
        let retjoin1 = retstr1.joined(separator: "")
        XCTAssertEqual(retjoin1.count, 10)
        XCTAssertEqual(retjoin1.filter{ $0 == "A" }.count, 6)
        XCTAssertEqual(retjoin1.filter{ $0 == "B" }.count, 3)
        XCTAssertEqual(retjoin1.filter{ $0 == "C" }.count, 1)
        XCTAssertFalse(retjoin1.contains("BB"))
    }
    
    func test_value_strange1() {
        var gcm = GcmDistributer()
        gcm.append(GcmNode(name: "A"), frequency: 10)

        let ret1 = Array(gcm)
        let retstr1 = ret1.compactMap { $0 as? GcmNode }.map{ $0.name }
        let retjoin1 = retstr1.joined(separator: "")
        XCTAssertEqual(retjoin1, "AAAAAAAAAA")
    }

    func test_value_strange2() {
        var gcm = GcmDistributer()
        gcm.append(GcmNode(name: "A"), frequency: 0)
        XCTAssertEqual(gcm.count, 0)
        XCTAssertEqual(Array(gcm).count, 0)
    }
    
    func test_value_strange3() {
        let gcm = GcmDistributer()
        XCTAssertEqual(gcm.count, 0)
        XCTAssertEqual(Array(gcm).count, 0)
    }
    
    func test_value_strange4() {
        var gcm = GcmDistributer()
        XCTAssertEqual(gcm.count, 0)
        XCTAssertEqual(Array(gcm).count, 0)

        gcm.append(GcmNode(name: "A"), frequency: 6)
        gcm.append(GcmNode(name: "B"), frequency: 3)
        gcm.append(GcmNode(name: "C"), frequency: 1)

        let ret1 = Array(gcm)
        let retstr1 = ret1.compactMap { $0 as? GcmNode }.map{ $0.name }
        let retjoin1 = retstr1.joined(separator: "")
        XCTAssertEqual(retjoin1.count, 10)
        XCTAssertEqual(retjoin1.filter{ $0 == "A" }.count, 6)
        XCTAssertEqual(retjoin1.filter{ $0 == "B" }.count, 3)
        XCTAssertEqual(retjoin1.filter{ $0 == "C" }.count, 1)
        XCTAssertFalse(retjoin1.contains("BB"))
    }
    
    func test_No6_value_small() {
        var gcm = GcmDistributer()
        gcm.append(GcmNode(name: "A"), frequency: 1)
        gcm.append(GcmNode(name: "B"), frequency: 1)
        let ret1 = Array(gcm)
        let retstr1 = ret1.compactMap { $0 as? GcmNode }.map{ $0.name }
        var retjoin1 = retstr1.joined(separator: "")
        var nMatched = 0
        let expected = "AB"
        for _ in 0..<gcm.count {
            if retjoin1 == expected {
                nMatched += 1
            }
            retjoin1 = "\(StrUtil.mid(retjoin1, start: 1))\(StrUtil.left(retjoin1, length: 1))"
        }
        XCTAssertGreaterThan(nMatched, 0)
    }
    func test_No7_value_large() {
        let n = 2000
        var gcm = GcmDistributer()
        gcm.append(GcmNode(name: "A"), frequency: n)
        gcm.append(GcmNode(name: "B"), frequency: n)
        let ret1 = Array(gcm)
        let retstr1 = ret1.compactMap { $0 as? GcmNode }.map{ $0.name }
        var retjoin1 = retstr1.joined(separator: "")
        var expected = ""
        for _ in 0..<n {
            expected += "AB"
        }
        var nMatched = 0
        for _ in 0..<2 {
            if retjoin1 == expected {
                nMatched += 1
            }
            retjoin1 = "\(StrUtil.mid(retjoin1, start: 1))\(StrUtil.left(retjoin1, length: 1))"
        }
        XCTAssertEqual(nMatched, 1)
    }
}

