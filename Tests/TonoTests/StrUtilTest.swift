// Tono (Tools Of New Operation) library
//  MIT Lisence (c) 2021 Manabu Tonosaki all rights reserved
//  Created by Manabu Tonosaki on 2021/12/12.
//

import XCTest
@testable import Tono

class StrUtilsTest: XCTestCase {

    func testMid() throws {
        let str = "ABCDEFGHIJKLMN"
        XCTAssertEqual(StrUtil.Mid(str, start:0, len:3), "ABC")
        XCTAssertEqual(StrUtil.Mid(str, start:1, len:3), "BCD")
        XCTAssertEqual(StrUtil.Mid(str, start:1, len:2), "BC")
        XCTAssertEqual(StrUtil.Mid(str, start:1, len:1), "B")
        XCTAssertEqual(StrUtil.Mid(str, start:1, len:0), "")
        XCTAssertEqual(StrUtil.Mid(str, start:11, len:3), "LMN")
        XCTAssertEqual(StrUtil.Mid(str, start:12, len:3), "MN")
        XCTAssertEqual(StrUtil.Mid(str, start:13, len:3), "N")
        XCTAssertEqual(StrUtil.Mid(str, start:14, len:3), "")
        XCTAssertEqual(StrUtil.Mid(str, start:15, len:3), "")
        XCTAssertEqual(StrUtil.Mid(str, start:-1, len:3), "AB")
        XCTAssertEqual(StrUtil.Mid(str, start:-2, len:3), "A")
        XCTAssertEqual(StrUtil.Mid(str, start:-3, len:3), "")
        XCTAssertEqual(StrUtil.Mid(str, start:-4, len:3), "")
        XCTAssertEqual(StrUtil.Mid(str, start:5), "FGHIJKLMN")
    }
    
    func testBoolStr() throws {
        XCTAssertTrue(StrUtil.parseBoolFuzzy("true") ?? false)
        XCTAssertTrue(StrUtil.parseBoolFuzzy("ok") ?? false)
        XCTAssertTrue(StrUtil.parseBoolFuzzy("yes") ?? false)
        XCTAssertFalse(StrUtil.parseBoolFuzzy("hoge") ?? false) // test default value
    }
}
