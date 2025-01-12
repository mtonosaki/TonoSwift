// Tono (Tools Of New Operation) library
//  MIT Lisence (c) 2021 Manabu Tonosaki all rights reserved
//  Created by Manabu Tonosaki on 2021/12/12.
//

import XCTest
@testable import Tono

class StrUtilsTest: XCTestCase {

    func test_isIntegerString() {
        XCTAssertTrue(StrUtil.isIntegerString("0123456789"))
        XCTAssertTrue(StrUtil.isIntegerString("-1234567890"))

        XCTAssertFalse(StrUtil.isIntegerString("1-234567890"))
        XCTAssertFalse(StrUtil.isIntegerString("123a456"))
    }
    
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
    
    func test_left() {
        XCTAssertEqual(StrUtil.left("abcdefghijklmn", length:3), "abc")
        XCTAssertEqual(StrUtil.left("abcdefghijklmn", length:2), "ab")
        XCTAssertEqual(StrUtil.left("abcdefghijklmn", length:1), "a")
        XCTAssertEqual(StrUtil.left("abcdefghijklmn", length:0), "")
    }

    func test_right() {
        XCTAssertEqual(StrUtil.right("abcdefghijklmn", length:3), "lmn")
        XCTAssertEqual(StrUtil.right("abcdefghijklmn", length:2), "mn")
        XCTAssertEqual(StrUtil.right("abcdefghijklmn", length:1), "n")
        XCTAssertEqual(StrUtil.right("abcdefghijklmn", length:0), "")
    }

    func test_mid() throws {
        let str = "ABCDEFGHIJKLMN"
        XCTAssertEqual(StrUtil.mid(str, start:0, length:3), "ABC")
        XCTAssertEqual(StrUtil.mid(str, start:1, length:3), "BCD")
        XCTAssertEqual(StrUtil.mid(str, start:1, length:2), "BC")
        XCTAssertEqual(StrUtil.mid(str, start:1, length:1), "B")
        XCTAssertEqual(StrUtil.mid(str, start:1, length:0), "")
        XCTAssertEqual(StrUtil.mid(str, start:11, length:3), "LMN")
        XCTAssertEqual(StrUtil.mid(str, start:12, length:3), "MN")
        XCTAssertEqual(StrUtil.mid(str, start:13, length:3), "N")
        XCTAssertEqual(StrUtil.mid(str, start:14, length:3), "")
        XCTAssertEqual(StrUtil.mid(str, start:15, length:3), "")
        XCTAssertEqual(StrUtil.mid(str, start:-1, length:3), "AB")
        XCTAssertEqual(StrUtil.mid(str, start:-2, length:3), "A")
        XCTAssertEqual(StrUtil.mid(str, start:-3, length:3), "")
        XCTAssertEqual(StrUtil.mid(str, start:-4, length:3), "")
        XCTAssertEqual(StrUtil.mid(str, start:5), "FGHIJKLMN")
    }

    func test_mid_left_right_mix() throws {
        let str = "ABCDEFGHIJKLMN"
        XCTAssertEqual(StrUtil.mid(str, start:2, length:3), "CDE")
        XCTAssertEqual(StrUtil.left(StrUtil.mid(str, start:2, length:3), length: 2), "CD")
        XCTAssertEqual(StrUtil.right(StrUtil.mid(str, start:2, length:3), length: 2), "DE")
    }

    
    func test_parseBoolFuzzy() throws {
        XCTAssertTrue(StrUtil.parseBoolFuzzy("true") ?? false)
        XCTAssertTrue(StrUtil.parseBoolFuzzy("ok") ?? false)
        XCTAssertTrue(StrUtil.parseBoolFuzzy("yes") ?? false)
        XCTAssertFalse(StrUtil.parseBoolFuzzy("hoge") ?? false) // test default value
    }
    
    func test_isUuid() throws {
        XCTAssertTrue(StrUtil.isUuid("12345678-1234-1234-1234-1234567890ab"))
        XCTAssertFalse(StrUtil.isUuid("123456789-1234-1234-1234-1234567890ab"))
        XCTAssertFalse(StrUtil.isUuid("12345678-1234-1234-1234-123"))
        
        let uuid = "12345678-1234-1234-1234-1234567890ab"
        let uuidsec = uuid[uuid.startIndex..<uuid.endIndex]
        XCTAssertTrue(StrUtil.isUuid(uuidsec))
    }
}
