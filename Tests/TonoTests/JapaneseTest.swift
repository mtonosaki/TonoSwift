// Tono (Tools Of New Operation) library
//  MIT Lisence (c) 2021 Manabu Tonosaki all rights reserved
//  Created by Manabu Tonosaki on 2021/12/12.
//

import XCTest
@testable import Tono

class JapaneseTest: XCTestCase {

    func test_Getあかさたな() {
        let jp = Japanese()
        XCTAssertEqual(jp.Getあかさたな("あかさたなはまやらわ"), "あかさたなはまやらわ")
        XCTAssertEqual(jp.Getあかさたな("いきしちにひみいりゐ"), "あかさたなはまあらわ")
        XCTAssertEqual(jp.Getあかさたな("うくすつぬふむゆるう"), "あかさたなはまやらあ")
        XCTAssertEqual(jp.Getあかさたな("えけせてねへめえれゑ"), "あかさたなはまあらわ")
        XCTAssertEqual(jp.Getあかさたな("おこそとのほもよろを"), "あかさたなはまやらあ") // NOTE: を-->お-->あ
        XCTAssertEqual(jp.Getあかさたな("がざだばぱ"), "かさたはは")
        XCTAssertEqual(jp.Getあかさたな("ぎじぢびぴ"), "かささはは") // NOTE: ぢ-->じ-->さ
        XCTAssertEqual(jp.Getあかさたな("ぐずづぶぷ"), "かささはは") // NOTE: づ-->ず-->さ
        XCTAssertEqual(jp.Getあかさたな("げぜでべぺ"), "かさたはは")
        XCTAssertEqual(jp.Getあかさたな("ごぞどぼぽ"), "かさたはは")
    }
    
    func test_Fuzzy() {
        let jp = Japanese()
        XCTAssertEqual(jp.GetKeyJp("ＴＰＳの二本柱の一つは自働化です。"), "tpsノ2本柱ノ1ツハ自動化デス。")
        XCTAssertEqual(jp.GetKeyJp("にゅーん、にょ-ん"), "ヌン、ニヨン")
        XCTAssertEqual(jp.GetKeyJp("よくリードタイムを L/Tと略するけど分かりにくいよね"), "ヨクリドタイムオltト略スルケド分カリニクイヨネ")
    }
}
