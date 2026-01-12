//
//  RsaTest.swift
//  Tono
//
//  Created by Manabu Tonosaki on 2025/05/10.
//

import XCTest
import CryptoKit

@testable import Tono

class AesTest: XCTestCase {

    func test_givenEncoded_whenInputIt_thenDecoded() {
        // GIVEN make encrypted data
        let aesForEncryption = Aes()
        let encryptedBase64 = try? aesForEncryption.encrypt(plainText: "Hello AES World !!!")
        XCTAssertNotNil(encryptedBase64)
        let keyBase64 = aesForEncryption.symmetricKey.toBase64()
        
        let aesForDecryption = try? Aes(symmetricKey: SymmetricKey(base64String: keyBase64))
        XCTAssertNotNil(aesForDecryption)

        // WHEN
        let plainText = try? aesForDecryption?.decrypt(base64String: encryptedBase64!)
        
        // THEN
        XCTAssertEqual("Hello AES World !!!", plainText)
    }

    func test_givenEncoded_whenInputItWithBadKey_thenDecoded() {
        // GIVEN make encrypted data
        let aesForEncryption = Aes()
        let encryptedBase64 = try? aesForEncryption.encrypt(plainText: "Hello AES World !!!")

        do {
            // WHEN
            let anotherAes = Aes()
            _ = try anotherAes.decrypt(base64String: encryptedBase64!)
        } catch {
            // THEN
            if let aesError = error as? Aes.Error {
                switch aesError {
                case .decriptFailed:
                    // The expected exception
                    break
                default:
                    XCTFail("Unexpected AesError: \(aesError)")
                }
            } else {
                XCTFail("Unexpected exception: \(error)")
            }
        }
    }
}
