// Tono (Tools Of New Operation) library
//  MIT Lisence (c) 2025 Manabu Tonosaki all rights reserved
//  Created by Manabu Tonosaki on 2025/05/10

import Foundation
import Security

@available(macOS 10.15, iOS 13.0, *)
open class Rsa {
    public enum Error: LocalizedError {
        case encrypt(String)
        case decrypt(String)
        case sign(String)
        case verify(String)
    }

    var nameMain: String
    var nameSub: String

    static let algorithmEncrypt: SecKeyAlgorithm = .rsaEncryptionOAEPSHA512
    static let algorithmSign: SecKeyAlgorithm = .rsaSignatureMessagePKCS1v15SHA512

    private var myPrivateKey: SecKey? = nil
    private var myPublicKey: SecKey? = nil

    private var keyChainTag: Data {
        "\(nameMain):\(nameSub)".data(using: .utf8)!
    }
    private var keyChainLabel: String {
        "\(nameMain) -- \(nameSub)"
    }

    public init(nameMain: String, nameSub: String) {
        self.nameMain = nameMain
        self.nameSub = nameSub

        // find private key from my key chain then create one if not registered yet.
        self.myPrivateKey = getPrivateKeyFromKeyChain()
        if self.myPrivateKey == nil {
            self.myPrivateKey = createPrivateKeyAndSaveToKeyChain()
        }
        guard let privateKey = self.myPrivateKey else {
            return
        }

        // create my public key from my private key
        self.myPublicKey = SecKeyCopyPublicKey(privateKey)
    }

    private func getPrivateKeyFromKeyChain() -> SecKey? {
        let getquery: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyChainTag,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecReturnRef as String: true,
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(getquery as CFDictionary, &item)
        if status == errSecSuccess {
            return (item as! SecKey)
        }
        return nil
    }

    private func createPrivateKeyAndSaveToKeyChain() -> SecKey? {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: 2048,
            kSecPrivateKeyAttrs as String: [
                kSecAttrLabel as String: keyChainLabel,
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: keyChainTag,
            ],
        ]
        var error: Unmanaged<CFError>?
        guard let generatedPrivateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            return nil
        }
        return generatedPrivateKey
    }

    public func getMyPublicKey() throws -> Base64String {
        guard let myPublicKey = self.myPublicKey else {
            throw Error.encrypt("public key is not ready")
        }
        guard let publicKeyData = (SecKeyCopyExternalRepresentation(myPublicKey, nil) as Data?) else {
            throw Error.encrypt("cannot make public key data")
        }
        let publicKeyBase64 = publicKeyData.base64EncodedString(options: [])
        return publicKeyBase64
    }

    public static func getPublicKey(publicKeyBase64: Base64String) throws -> SecKey {
        let keyData = Data(base64Encoded: publicKeyBase64, options: [.ignoreUnknownCharacters])!
        let sizeInBits = keyData.count * 8
        let keyDict: [CFString: Any] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits: NSNumber(value: sizeInBits),
            kSecReturnPersistentRef: true,
        ]
        var error: Unmanaged<CFError>?
        guard let publicKey = SecKeyCreateWithData(keyData as CFData, keyDict as CFDictionary, &error) else {
            throw Error.encrypt("cannot create public key")
        }
        return publicKey
    }

    public func encryptWithMyPublicKey(plainText: String) throws -> Base64String {
        guard let myPublicKey = self.myPublicKey else {
            throw Error.encrypt("public key is not ready")
        }
        return try Rsa.encryptWithSpecifiedKey(plainText: plainText, key: myPublicKey)
    }

    public func encryptWithMyPrivateKey(plainText: String) throws -> Base64String {
        guard let myPrivateKey = self.myPrivateKey else {
            throw Error.encrypt("private key is not ready")
        }
        return try Rsa.encryptWithSpecifiedKey(plainText: plainText, key: myPrivateKey)
    }

    public static func encryptWithSpecifiedPublicKey(plainText: String, publicKeyBase64: Base64String) throws -> Base64String {
        let publicKey = try Rsa.getPublicKey(publicKeyBase64: publicKeyBase64)
        return try encryptWithSpecifiedKey(plainText: plainText, key: publicKey)
    }

    public static func encryptWithSpecifiedKey(plainText: String, key: SecKey) throws -> Base64String {
        guard SecKeyIsAlgorithmSupported(key, .encrypt, algorithmEncrypt) else {
            throw Error.encrypt("an algorithm is not suppoted")
        }
        let secKeyBlockSize = SecKeyGetBlockSize(key)
        let textSize = plainText.data(using: .utf8)?.count ?? 32767
        guard textSize < (secKeyBlockSize - 130) else {
            throw Error.encrypt("plainText is too long")
        }

        let plainData = plainText.data(using: .utf8)!
        var error: Unmanaged<CFError>?
        guard
            let cipherData = SecKeyCreateEncryptedData(
                key,
                algorithmEncrypt,
                plainData as CFData,
                &error
            ) as Data?
        else {
            throw error!.takeRetainedValue() as CFError
        }

        let cipherBase64 = cipherData.base64EncodedString()
        return cipherBase64
    }
    
    public static func decryptWithPrivateKey(cipherBase64: Base64String, privateKey: SecKey) throws -> String {
        guard SecKeyIsAlgorithmSupported(privateKey, .decrypt, Rsa.algorithmEncrypt) else {
            throw Error.decrypt("an algorithm is not suppoted")
        }

        guard let cipherData = Data(base64Encoded: cipherBase64, options: []) else {
            throw Error.decrypt("cannot decode the input base64")
        }
        guard cipherData.count == SecKeyGetBlockSize(privateKey) else {
            throw Error.decrypt("input string is too long")
        }

        var error: Unmanaged<CFError>?
        guard
            let clearData = SecKeyCreateDecryptedData(
                privateKey,
                Rsa.algorithmEncrypt,
                cipherData as CFData,
                &error
            ) as Data?
        else {
            throw error!.takeRetainedValue() as CFError
        }

        guard let clearString = String(data: clearData, encoding: .utf8) else {
            throw Error.decrypt("cannot convert data to string")
        }
        return clearString
    }

    public func decryptWithMyPrivateKey(cipherBase64: Base64String) throws -> String {
        guard let myPrivateKey = self.myPrivateKey else {
            throw Error.decrypt("private key is not ready")
        }
        return try Rsa.decryptWithPrivateKey(cipherBase64: cipherBase64, privateKey: myPrivateKey)
    }
    
    public func decryptWithMyPublicKey(cipherBase64: Base64String) throws -> String {
        guard let myPublicKey = self.myPublicKey else {
            throw Error.decrypt("public key is not ready")
        }
        return try Rsa.decryptWithPrivateKey(cipherBase64: cipherBase64, privateKey: myPublicKey)
    }

    public func createSignatureWithMyPrivateKey(plainText: String) throws -> Base64String {
        guard let myPrivateKey = self.myPrivateKey else {
            throw Error.decrypt("private key is not ready")
        }
        guard SecKeyIsAlgorithmSupported(myPrivateKey, .sign, Rsa.algorithmSign) else {
            throw Error.sign("an algorithm is not suppoted")
        }

        let plainData = plainText.data(using: .utf8)!
        var error: Unmanaged<CFError>?
        guard
            let signature = SecKeyCreateSignature(
                myPrivateKey,
                Rsa.algorithmSign,
                plainData as CFData,
                &error
            ) as Data?
        else {
            throw error!.takeRetainedValue() as CFError
        }

        let signatureBase64 = signature.base64EncodedString()
        return signatureBase64
    }

    public static func verifySignWithPublicKey(plainText: String, signatureBase64: Base64String, publicKey: SecKey) throws -> Bool {
        let signatureVerify = Data(base64Encoded: signatureBase64, options: [])
        guard SecKeyIsAlgorithmSupported(publicKey, .verify, algorithmSign) else {
            throw Error.verify("an algorithm is not suppoted")
        }

        let plainData = plainText.data(using: .utf8)!
        var error: Unmanaged<CFError>?
        guard
            SecKeyVerifySignature(
                publicKey,
                algorithmSign,
                plainData as CFData,
                signatureVerify! as CFData,
                &error
            )
        else {
            return false
        }
        return true
    }

    public static func verifySignWithPublicKey(plainText: String, signatureBase64: Base64String, publicKeyBase64: Base64String) throws -> Bool
    {
        let publicKey = try Rsa.getPublicKey(publicKeyBase64: publicKeyBase64)
        return try verifySignWithPublicKey(plainText: plainText, signatureBase64: signatureBase64, publicKey: publicKey)
    }

    public func verifySignWithMyPublicKey(plainText: String, signatureBase64: Base64String) throws -> Bool {
        guard let myPublicKey = self.myPublicKey else {
            throw Error.verify("public key is not ready")
        }
        return try Rsa.verifySignWithPublicKey(
            plainText: plainText,
            signatureBase64: signatureBase64,
            publicKey: myPublicKey
        )
    }
}
