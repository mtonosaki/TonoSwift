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
    }
    
    func test_No1() {
        var gcm = GcmDistributer()
        gcm.append(GcmNode(name: "A"), frequency: 6)
        gcm.append(GcmNode(name: "B"), frequency: 3)
        gcm.append(GcmNode(name: "C"), frequency: 1)
        let ret = Array(gcm)
        let retstr = ret.compactMap { $0 as? GcmNode }.map{ $0.name }
        let retjoin = retstr.joined(separator: "")
        XCTAssertEqual(retjoin, "ABAABACABA")
    }
}

