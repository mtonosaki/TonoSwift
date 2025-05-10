//
//  RsaTest.swift
//  Tono
//
//  Created by Manabu Tonosaki on 2025/05/10.
//

import XCTest

@testable import Tono

class RsaTest: XCTestCase {

    func test_whenEncryptWithMyPublicKeyThenDecryptWithMyPrivateKey() {
        do {
            // WHEN: A encrypt text with A's public key
            let rsa = Rsa(nameMain: "com.tomarika.tonoswift", nameSub: "persona-a")
            let cipherBase64 = try rsa.encryptWithMyPublicKey(plainText: "Hello, Secret World!")
            
            // THEN: A can decrypt it with A's private key
            let plainText = try rsa.decryptWithMyPrivateKey(cipherBase64: cipherBase64)
            XCTAssertEqual("Hello, Secret World!", plainText)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_whenSignTHenVerify() {
        do {
            // WHEN: A sign the text
            let rsa = Rsa(nameMain: "com.tomarika.tonoswift", nameSub: "persona-a")
            let signatureBase64 = try rsa.createSignatureWithMyPrivateKey(plainText: "Hello, Secret World!")
            
            // THEN: A can verify it with A theirself
            XCTAssertTrue(try rsa.verifySignWithMyPublicKey(plainText: "Hello, Secret World!", signatureBase64: signatureBase64))
        }
        catch{
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_when_B_encrypt_with_publicKey_of_A_then_A_decrypt_with_privateKey_of_A() {
        do {
            // GIVEN: A provide their public key
            let rsaA = Rsa(nameMain: "com.tomarika.tonoswift", nameSub: "persona-a")
            let publicKeyA = try rsaA.getMyPublicKey()

            // WHEN: B encrypt with A's public key
            let encryptedBase64 = try Rsa.encryptWithSpecifiedPublicKey(plainText: "Hoge", publicKeyBase64: publicKeyA)
            
            // THEN: A can decrypt with A's private key
            let plainText = try rsaA.decryptWithMyPrivateKey(cipherBase64: encryptedBase64)
            XCTAssertEqual("Hoge", plainText)
        }
        catch{
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_when_B_provide_sign_then_A_can_verify() {
        do {
            // GIVEN: A provide A's public key
            let rsaA = Rsa(nameMain: "com.tomarika.tonoswift", nameSub: "persona-b")
            let publicKeyA = try rsaA.getMyPublicKey()
            
            // WHEN: B sign with B's private key
            let rsaB = Rsa(nameMain: "com.tomarika.tonoswift", nameSub: "persona-b")
            let signatureB = try rsaB.createSignatureWithMyPrivateKey(plainText: "Fuga" )
            
            // THEN: A can verify with B's public key
            let isOk = try Rsa.verifySignWithPublicKey(plainText: "Fuga", signatureBase64: signatureB, publicKeyBase64: publicKeyA)
            XCTAssertTrue(isOk)
        }
        catch{
            XCTFail(error.localizedDescription)
        }
    }
}
