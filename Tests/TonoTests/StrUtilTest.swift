// Tono (Tools Of New Operation) library
//  MIT Lisence (c) 2021 Manabu Tonosaki all rights reserved
//  Created by Manabu Tonosaki on 2021/12/12.
//

import XCTest
@testable import Tono

class StrUtilsTest: XCTestCase {

    func test_toHms() {
        XCTAssertEqual(StrUtil.toHms(hour: 1.0), "1:00:00")
        XCTAssertEqual(StrUtil.toHms(hour: 2.0), "2:00:00")
        XCTAssertEqual(StrUtil.toHms(hour: 10.0), "10:00:00")
        XCTAssertEqual(StrUtil.toHms(hour: 100.0), "100:00:00")
        XCTAssertEqual(StrUtil.toHms(hour: 100.5), "100:30:00")
        XCTAssertEqual(StrUtil.toHms(hour: 10.26), "10:15:36")
    }
    
    func test_rep(){
        XCTAssertEqual(StrUtil.rep("a", n: 3), "aaa")
        XCTAssertEqual(StrUtil.rep("a", n: 2), "aa")
        XCTAssertEqual(StrUtil.rep("a", n: 1), "a")
        XCTAssertEqual(StrUtil.rep("a", n: 0), "")
        XCTAssertEqual(StrUtil.rep("a", n: -1), "")
        XCTAssertEqual(StrUtil.rep("ab", n: 3), "ababab")
        XCTAssertEqual(StrUtil.rep("1234567890", n: 200).count, 2000)
        XCTAssertNotEqual(StrUtil.rep("1234567890", n: 1000).count, 10000) // overflow

        XCTAssertEqual(StrUtil.rep("あ", n: 3), "あああ")
    }
    
    func test_mid() throws {
        let str = "ABCDEFGHIJKLMN"
        XCTAssertEqual(StrUtil.mid(str, start:0, len:3), "ABC")
        XCTAssertEqual(StrUtil.mid(str, start:1, len:3), "BCD")
        XCTAssertEqual(StrUtil.mid(str, start:1, len:2), "BC")
        XCTAssertEqual(StrUtil.mid(str, start:1, len:1), "B")
        XCTAssertEqual(StrUtil.mid(str, start:1, len:0), "")
        XCTAssertEqual(StrUtil.mid(str, start:11, len:3), "LMN")
        XCTAssertEqual(StrUtil.mid(str, start:12, len:3), "MN")
        XCTAssertEqual(StrUtil.mid(str, start:13, len:3), "N")
        XCTAssertEqual(StrUtil.mid(str, start:14, len:3), "")
        XCTAssertEqual(StrUtil.mid(str, start:15, len:3), "")
        XCTAssertEqual(StrUtil.mid(str, start:-1, len:3), "AB")
        XCTAssertEqual(StrUtil.mid(str, start:-2, len:3), "A")
        XCTAssertEqual(StrUtil.mid(str, start:-3, len:3), "")
        XCTAssertEqual(StrUtil.mid(str, start:-4, len:3), "")
        XCTAssertEqual(StrUtil.mid(str, start:5), "FGHIJKLMN")
    }
    
    func test_parseBoolFuzzy() throws {
        XCTAssertTrue(StrUtil.parseBoolFuzzy("true") ?? false)
        XCTAssertTrue(StrUtil.parseBoolFuzzy("ok") ?? false)
        XCTAssertTrue(StrUtil.parseBoolFuzzy("yes") ?? false)
        XCTAssertFalse(StrUtil.parseBoolFuzzy("hoge") ?? false) // test default value
    }
}
