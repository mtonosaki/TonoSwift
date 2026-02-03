// Tono (Tools Of New Operation) library
//  MIT Lisence (c) 2021 Manabu Tonosaki all rights reserved
//  Created by Manabu Tonosaki on 2026/02/03.
//

import XCTest
@testable import Tono

class ImageUtilTest: XCTestCase {
    
    func test_calculatePixelOccupancy3_3() {
        let ret = ImageUtil.calculatePixelOccupancy(size: 3, subdivisions: 3)
        XCTAssertEqual(ret[0].map { Int($0 * 100) }, [ 0,  33,  66,  33,  0])
        XCTAssertEqual(ret[1].map { Int($0 * 100) }, [33, 100, 100, 100, 33])
        XCTAssertEqual(ret[2].map { Int($0 * 100) }, [66, 100, 100, 100, 66])
        XCTAssertEqual(ret[3].map { Int($0 * 100) }, [33, 100, 100, 100, 33])
        XCTAssertEqual(ret[4].map { Int($0 * 100) }, [ 0,  33,  66,  33,  0])
    }
    
    func test_calculatePixelOccupancy3_100() {
        let ret = ImageUtil.calculatePixelOccupancy(size: 3, subdivisions: 100)
        XCTAssertEqual(ret[0].map { Int($0 * 100) }, [ 0,  34,  60,  34,  0])
        XCTAssertEqual(ret[1].map { Int($0 * 100) }, [34, 100, 100, 100, 34])
        XCTAssertEqual(ret[2].map { Int($0 * 100) }, [60, 100, 100, 100, 60])
        XCTAssertEqual(ret[3].map { Int($0 * 100) }, [34, 100, 100, 100, 34])
        XCTAssertEqual(ret[4].map { Int($0 * 100) }, [ 0,  34,  60,  34,  0])
    }
    
    func test_calculatePixelOccupancy5_100() {
        let ret = ImageUtil.calculatePixelOccupancy(size: 4, subdivisions: 100)
        for y in 0..<(ret[0].count) {
            let line = ret[y].map { String($0) }.joined(separator: "|")
            print(line)
        }
    }
    

    func test_calculatePixelOccupancy2_100() {
        let ret = ImageUtil.calculatePixelOccupancy(size: 2, subdivisions: 100)
        XCTAssertEqual(ret[0].map { Int($0 * 100) }, [ 43,  88,  43])
        XCTAssertEqual(ret[1].map { Int($0 * 100) }, [ 88, 100,  88])
        XCTAssertEqual(ret[2].map { Int($0 * 100) }, [ 43,  88,  43])
    }
    
    func test_calculatePixelOccupancy1_100() {
        let ret = ImageUtil.calculatePixelOccupancy(size: 1, subdivisions: 100)
        XCTAssertEqual(ret, [[1.0]])
    }

    func test_calculatePixelOccupancy0_100() {
        let ret = ImageUtil.calculatePixelOccupancy(size: 0, subdivisions: 100)
        XCTAssertEqual(ret, [])
    }
}
