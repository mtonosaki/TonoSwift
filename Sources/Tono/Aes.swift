//
//  File.swift
//  Tono
//
//  Created by Manabu Tonosaki on 2026-01-12.
//

import Foundation
import CryptoKit

@available(macOS 10.15, iOS 13.0, *)
class Aes {
    enum Error: LocalizedError {
        case stringToDataFailed
        case dataToStringFailed
        case base64ToDataFailed
        case decriptFailed
    }
    
    private let _symmetricKey: SymmetricKey
    
    @available(macOS 11.0, iOS 14.0, *)
    init (_ saltString: String = "") {
        let masterKey = SymmetricKey(size: .bits256)
        let saltData = saltString.data(using: .utf8) ?? Data()
        self._symmetricKey = HKDF<SHA256>.deriveKey(
            inputKeyMaterial: masterKey,
            salt: saltData,
            info: "AdditionalSecurityLayer".data(using: .utf8)!,
            outputByteCount: 32
        )
    }
    
    init(symmetricKey: SymmetricKey) {
        self._symmetricKey = symmetricKey
    }
    
    var symmetricKey: SymmetricKey {
        return self._symmetricKey
    }
    
    func encrypt(plainText: String) throws -> Base64String {
        guard let data = plainText.data(using: .utf8) else {
            throw Error.stringToDataFailed
        }
        let sealedBox = try AES.GCM.seal(data, using: self.symmetricKey)
        guard let combinedData = sealedBox.combined else {
            throw Error.stringToDataFailed
        }
        let combinedBase64String = combinedData.base64EncodedString()
        return combinedBase64String
    }
    
    func decrypt(base64String: Base64String) throws -> String {
        guard let combinedData = Data(base64Encoded: base64String, options: []) else {
            throw Error.base64ToDataFailed
        }
        let sealedBox = try AES.GCM.SealedBox(combined: combinedData)
        let decryptedData = try? AES.GCM.open(sealedBox, using: self.symmetricKey)
        guard let decryptedData else {
            throw Error.decriptFailed
        }
        guard let text = String(data: decryptedData, encoding: .utf8) else {
            throw Error.dataToStringFailed
        }
        return text
    }
}

@available(macOS 10.15, iOS 13.0, *)
extension SymmetricKey {
    enum Base64Error: Error {
        case base64ToDataFailed
    }

    func toBase64() -> Base64String {
        return self.withUnsafeBytes { Data($0) }.base64EncodedString()
    }
    
    init(base64String: Base64String) throws {
        guard let data = Data(base64Encoded: base64String, options: []) else {
            throw Base64Error.base64ToDataFailed
        }
        if data.count != 32 {
            throw Base64Error.base64ToDataFailed
        }
        self = SymmetricKey(data: data)
    }
}
