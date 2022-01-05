// Tono (Tools Of New Operation) library
//  MIT Lisence (c) 2021 Manabu Tonosaki all rights reserved
//  Created by Manabu Tonosaki on 2021/12/12.
//

import XCTest
@testable import Tono

class GeoEuTest: XCTestCase {
    
    func test_isIntegerString() {
        let ret = GeoEu.getDistanceGrateCircle(lon0: 139.7645065, lat0: 35.684705, lon1: 139.6934743, lat1: 35.6879586)
        let expectedByOtherMethod = 6432.667
        XCTAssertLessThan(abs(ret - expectedByOtherMethod), 10)
    }
}
