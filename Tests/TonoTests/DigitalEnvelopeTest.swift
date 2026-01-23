//
//  DigitalEnvelopeTests.swift
//  TonoTests
//
//  Created by Manabu Tonosaki on 2026-01-12.
//

import XCTest
@testable import Tono

class DigitalEnvelopeTests: XCTestCase {
    var rsaTomomi: Rsa!
    var rsaMasahiko: Rsa!
    var rsaHanako: Rsa!
    
    override func setUpWithError() throws {
        rsaTomomi = RsaLocalKeyChain(nameMain: "com.tomarika.tonoswift.test", nameSub: "Tomomi")
        rsaMasahiko = RsaLocalKeyChain(nameMain: "com.tomarika.tonoswift.test", nameSub: "Masahiko")
        rsaHanako = RsaLocalKeyChain(nameMain: "com.tomarika.tonoswift.test", nameSub: "Hanako")
    }
    
    func test_SealAndOpen_inOnePerson_Success() throws {
        // GIVEN: Tomomi make envelop with Masahiko's public key
        let masahikoPublicKey = try rsaMasahiko.getMyPublicKey()
        let envelopeFromTomomi = try DigitalEnvelope.seal(
            plainText: "真彦さん、智美よ。今日の待ち合わせ場所は ABCに変更です...",
            recipientPublicKeyBase64: masahikoPublicKey
        )

        // WHEN: Masahiko open the envelop
        let openedMessageByMasahiko = try DigitalEnvelope.open(sealedString: envelopeFromTomomi, myRsa: rsaMasahiko)
        
        // THEN
        XCTAssertEqual("真彦さん、智美よ。今日の待ち合わせ場所は ABCに変更です...", openedMessageByMasahiko, "Should be same")
    }
    
    func test_SealAndOpen_UnicodeAndLongText() throws {
        // GIVEN: Tomomi make long special message with Masahiko's public key
        let masahikoPublicKey = try rsaMasahiko.getMyPublicKey()
        let longText = String(repeating: "Hoge-Fuga-Piyo ", count: 100)
        let longSpecialText = "😊 📝爆弾💣" + longText
        let envelopeFromTomomi = try DigitalEnvelope.seal(
            plainText: longSpecialText,
            recipientPublicKeyBase64: masahikoPublicKey
        )
        
        // WHEN:  open the Envelop from Tomomi
        let openedMessageByMasahiko = try DigitalEnvelope.open(sealedString: envelopeFromTomomi, myRsa: rsaMasahiko)
        
        // THEN
        XCTAssertEqual(longSpecialText, openedMessageByMasahiko, "Shoud be decoded as same")
    }
    
    func test_OpenWithWrongPrivateKey_ShouldFail() throws {
        // GIVEN: Tomomi make an envelop with Masahiko's public key
        let masahikoPublicKey = try rsaMasahiko.getMyPublicKey()
        let envelope = try DigitalEnvelope.seal(plainText: "真彦さん、智美です。今夜空いてる？", recipientPublicKeyBase64: masahikoPublicKey)
        
        XCTAssertThrowsError(
            // WHEN: Hanako have tried to open the Tomomi's envelop to Masahiko
            try DigitalEnvelope.open(sealedString: envelope, myRsa: rsaHanako)
        ) {
            // THEN
            if let error = $0 as? DigitalEnvelope.Error {
                XCTAssertTrue(error == .decryptionFailed)
            } else {
                XCTFail("The exception is not the expected type.")
            }
        }
    }
    
    func test_CorruptedEnvelope_ShouldFail() throws {
        // GIVEN
        let masahikoPublicKey = try rsaMasahiko.getMyPublicKey()
        let validEnvelope = try DigitalEnvelope.seal(plainText: "真彦さん、今日は残業になりました", recipientPublicKeyBase64: masahikoPublicKey)
        
        // WHEN - Hanako break the envelop
        let brokenEnvelope = String(validEnvelope.dropLast(4))
        
        XCTAssertThrowsError(
            // - and tried to open it by Masahiko
            try DigitalEnvelope.open(sealedString: brokenEnvelope, myRsa: rsaMasahiko)
        ) {
            // THEN
            print("Expected Corrupted Data could not be used: \($0)")
        }
    }
    
    func test_TamperedPayload_ShouldFail() throws {
        // GIVEN
        let masahikoPublicKey = try rsaMasahiko.getMyPublicKey()
        let ValidEnvelope = try DigitalEnvelope.seal(plainText: "内緒ですよ", recipientPublicKeyBase64: masahikoPublicKey)
        
        // - somebody receive the envelop
        guard let data = Data(base64Encoded: ValidEnvelope), var jsonStr = String(data: data, encoding: .utf8) else {
            XCTFail("Unexpected failure.")
            return
        }
        // - and replace the message in JSON
        jsonStr = String(jsonStr.dropLast(5)) + "AAAAA"
        
        // - and send
        let tamperedEnvelopeOnNetwork = jsonStr.data(using: .utf8)!.base64EncodedString()
        
        XCTAssertThrowsError(
            // WHEN
            try DigitalEnvelope.open(sealedString: tamperedEnvelopeOnNetwork, myRsa: rsaMasahiko)
        ){
            // THEN
            print("Expected error: \($0)")
        }
    }
}
