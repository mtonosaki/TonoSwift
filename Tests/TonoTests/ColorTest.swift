// Tono (Tools Of New Operation) library
//  MIT Lisence (c) 2021 Manabu Tonosaki all rights reserved
//  Created by Manabu Tonosaki on 2021/12/12.
//

import SwiftUI
import XCTest

@testable import Tono

class ColorTest: XCTestCase {

    func test_toRgba1() {
        XCTAssertEqual(
            "#ffffffff", Color(sharpAndHexString: "#ffffffff").toRgbaHexString()
        )
        XCTAssertEqual(
            "#ffffffff", Color(sharpAndHexString: "#ffffff").toRgbaHexString())
        XCTAssertEqual(
            "#ffffffff", Color(sharpAndHexString: "#fff").toRgbaHexString())
    }
    func test_toRgba2() {
        XCTAssertEqual(
            "#aaaaaaaa", Color(sharpAndHexString: "#aaaaaaaa").toRgbaHexString()
        )
        XCTAssertEqual(
            "#aaaaaaff", Color(sharpAndHexString: "#aaaaaa").toRgbaHexString())
        XCTAssertEqual(
            "#aaaaaaff", Color(sharpAndHexString: "#aaa").toRgbaHexString())
    }
}
