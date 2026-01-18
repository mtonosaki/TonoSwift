//
//  File.swift
//  Tono
//
//  Created by Manabu Tonosaki on 2026-01-12.
//

import Foundation
import CryptoKit

@available(macOS 10.15, iOS 13.0, *)
public class DigitalEnvelope {
    struct Message: Codable {
        let encryptedBody: Base64String
        let encryptedKey: Base64String
    }
    
    public enum Error: LocalizedError {
        case keyRestorationFailed
        case encodingFailed
        case decodingFailed
        case invalidEnvelopeFormat
        case decryptionFailed
    }
    
    public static func seal(plainText: String, recipientPublicKeyBase64: Base64String) throws -> SealedEnvelope {
        let aes = Aes()
        let encryptedBody = try aes.encrypt(plainText: plainText)
        let aesKeyBase64 = aes.symmetricKey.toBase64()
        let encryptedAesKey = try Rsa.encryptWithSpecifiedPublicKey(
            plainText: aesKeyBase64,
            publicKeyBase64: recipientPublicKeyBase64
        )
        let message = Message(encryptedBody: encryptedBody, encryptedKey: encryptedAesKey)
        guard let jsonData = try? JSONEncoder().encode(message) else {
            throw Error.encodingFailed
        }
        return jsonData.base64EncodedString()
    }
    
    public static func open(sealedString: SealedEnvelope, myRsa: Rsa) throws -> String {
        guard let jsonData = Data(base64Encoded: sealedString) else {
            throw Error.invalidEnvelopeFormat
        }
        guard let message = try? JSONDecoder().decode(Message.self, from: jsonData) else {
            throw Error.decodingFailed
        }
        
        
        var aesKeyBase64: Base64String
        do {
            aesKeyBase64 = try myRsa.decryptWithMyPrivateKey(cipherBase64: message.encryptedKey)
        } catch {
            throw Error.decryptionFailed
        }
        guard let symmetricKey = try? SymmetricKey(base64String: aesKeyBase64) else {
            throw Error.keyRestorationFailed
        }
        let aes = Aes(symmetricKey: symmetricKey)
        let plainText = try aes.decrypt(base64String: message.encryptedBody)
        return plainText
    }
}
