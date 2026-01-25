// Tono (Tools Of New Operation) library
//  MIT Lisence (c) 2021 Manabu Tonosaki all rights reserved
//  Created by Manabu Tonosaki on 2021/12/12.
//

import XCTest
@testable import Tono

class JapaneseTest: XCTestCase {

    func test_Getあかさたな() {
        let jp = Japanese()
        XCTAssertEqual(jp.getあかさたな("あかさたなはまやらわ"), "あかさたなはまやらわ")
        XCTAssertEqual(jp.getあかさたな("いきしちにひみいりゐ"), "あかさたなはまあらわ")
        XCTAssertEqual(jp.getあかさたな("うくすつぬふむゆるう"), "あかさたなはまやらあ")
        XCTAssertEqual(jp.getあかさたな("えけせてねへめえれゑ"), "あかさたなはまあらわ")
        XCTAssertEqual(jp.getあかさたな("おこそとのほもよろを"), "あかさたなはまやらあ") // NOTE: を-->お-->あ
        XCTAssertEqual(jp.getあかさたな("がざだばぱ"), "かさたはは")
        XCTAssertEqual(jp.getあかさたな("ぎじぢびぴ"), "かささはは") // NOTE: ぢ-->じ-->さ
        XCTAssertEqual(jp.getあかさたな("ぐずづぶぷ"), "かささはは") // NOTE: づ-->ず-->さ
        XCTAssertEqual(jp.getあかさたな("げぜでべぺ"), "かさたはは")
        XCTAssertEqual(jp.getあかさたな("ごぞどぼぽ"), "かさたはは")
    }
    
    func test_Fuzzy() {
        XCTAssertEqual(Japanese.def.getKeyJp("ＴＰＳの二本柱の一つは自働化です。"), "tpsノ2本柱ノ1ツハ自動化デス。")
        XCTAssertEqual(Japanese.def.getKeyJp("にゅーん、にょ-ん"), "ヌン、ニヨン")
        XCTAssertEqual(Japanese.def.getKeyJp("よくリードタイムを L/Tと略するけど分かりにくいよね"), "ヨクリドタイムオltト略スルケド分カリニクイヨネ")
    }
}
