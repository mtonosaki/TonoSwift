//
//  RsaTest.swift
//  Tono
//
//  Created by Manabu Tonosaki on 2025/05/10.
//

import XCTest

@testable import Tono

class RsaLocalKeyChainTest: RsaBaseTest {
    override func createRsaInstance(nameMain: String, nameSub: String) -> Rsa {
        return RsaLocalKeyChain(nameMain: nameMain, nameSub: nameSub)
    }
}

class RsaBaseTest: XCTestCase {
    var rsaA: Rsa!
    var rsaB: Rsa!
    
    func createRsaInstance(nameMain: String, nameSub: String) -> Rsa {
        fatalError("Subclasses must override createRsaInstance")
    }
    
    override class var defaultTestSuite: XCTestSuite {
        if self == RsaBaseTest.self {
            return XCTestSuite(name: "Skipping Base Test")
        }
        return super.defaultTestSuite
    }
    
    override func setUpWithError() throws {
        rsaA = createRsaInstance(nameMain: "com.tomarika.tonoswift.test", nameSub: "persona-a")
        rsaB = createRsaInstance(nameMain: "com.tomarika.tonoswift.test", nameSub: "persona-b")
    }


    func test_whenEncryptWithMyPublicKeyThenDecryptWithMyPrivateKey() {
        do {
            // WHEN: A encrypt text with A's public key
            let cipherBase64 = try rsaA.encryptWithMyPublicKey(plainText: "Hello, Secret World!")
            
            // THEN: A can decrypt it with A's private key
            let plainText = try rsaA.decryptWithMyPrivateKey(cipherBase64: cipherBase64)
            XCTAssertEqual("Hello, Secret World!", plainText)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_inputLengthShouldBeLessThan126() {
        // GIVEN
        let text125 = StrUtil.rep("A", n: 125)
        let text126 = StrUtil.rep("A", n: 126)
        XCTAssertNoThrow(try rsaA.encryptWithMyPublicKey(plainText: text125), "Should be success")
        
        do {
            // WHEN
            _ = try rsaA.encryptWithMyPublicKey(plainText: text126)
            XCTFail("Test failed because no error was thrown")
        } catch {
            // THEN
            if let rsaError = error as? RsaLocalKeyChain.Error {
                switch rsaError {
                case .encrypt(let msg):
                    XCTAssertEqual(msg, "plainText is too long", "Should be thrown exception")
                default:
                    XCTFail("Unexpected RsaException: \(rsaError)")
                }
            } else {
                XCTFail("Unexpected exception: \(error)")
            }
        }
    }
    
    func test_inputSizeShouldBeLessThan126ConsideringMultiByteCharacters() {
        // GIVEN
        let kanji125 = StrUtil.rep("悪", n: 125)
        
        do {
            // WHEN
            _ = try rsaA.encryptWithMyPublicKey(plainText: kanji125)
            XCTFail("Test failed because no error was thrown")
        } catch {
            // THEN
            if let rsaError = error as? RsaLocalKeyChain.Error {
                switch rsaError {
                case .encrypt(let msg):
                    XCTAssertEqual(msg, "plainText is too long", "Should be thrown exception")
                default:
                    XCTFail("Unexpected RsaException: \(rsaError)")
                }
            } else {
                XCTFail("Unexpected exception: \(error)")
            }
        }
    }
    
    func test_whenSignTHenVerify() {
        do {
            // WHEN: A sign the text
            let signatureBase64 = try rsaA.createSignatureWithMyPrivateKey(plainText: "Hello, Secret World!")
            
            // THEN: A can verify it with A theirself
            XCTAssertTrue(try rsaA.verifySignWithMyPublicKey(plainText: "Hello, Secret World!", signatureBase64: signatureBase64))
        }
        catch{
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_when_B_encrypt_with_publicKey_of_A_then_A_decrypt_with_privateKey_of_A() {
        do {
            // GIVEN: A provide their public key
            let publicKeyA = try rsaA.getMyPublicKey()

            // WHEN: B encrypt with A's public key
            let encryptedBase64 = try RsaLocalKeyChain.encryptWithSpecifiedPublicKey(plainText: "Hoge", publicKeyBase64: publicKeyA)
            
            // THEN: A can decrypt with A's private key
            let plainText = try rsaA.decryptWithMyPrivateKey(cipherBase64: encryptedBase64)
            XCTAssertEqual("Hoge", plainText)
        }
        catch{
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_when_B_provide_sign_then_somebody_can_verify() {
        do {
            // GIVEN: B provide B's public key
            let publicKeyB = try rsaB.getMyPublicKey()
            
            // WHEN: B sign with B's private key
            let signatureB = try rsaB.createSignatureWithMyPrivateKey(plainText: "Fuga" )
            
            // THEN: Somebody can verify B with B's public key
            let isOk = try rsaA.verifySignWithPublicKey(plainText: "Fuga", signatureBase64: signatureB, publicKeyBase64: publicKeyB)
            XCTAssertTrue(isOk)
        }
        catch{
            XCTFail(error.localizedDescription)
        }
    }
}
