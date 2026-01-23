//
//  RsaLocal.swift
//  Tono
//
//  Created by Manabu Tonosaki on 2026-01-21.
//

import Foundation
import Security

@available(macOS 10.15, iOS 13.0, *)
public class RsaLocalKeyChain: Rsa {
    public enum Error: LocalizedError {
        case publicKey(String)
        case privateKey(String)
        case encrypt(String)
        case decrypt(String)
        case sign(String)
        case verify(String)
    }
    
    var nameMain: String
    var nameSub: String
    
    static let algorithmEncrypt: SecKeyAlgorithm = .rsaEncryptionOAEPSHA512
    static let algorithmSign: SecKeyAlgorithm = .rsaSignatureMessagePKCS1v15SHA512
    
    internal var myPrivateKey: SecKey? = nil
    internal var myPublicKey: SecKey? = nil
    
    internal var keyChainTag: Data {
        "\(nameMain):\(nameSub)".data(using: .utf8)!
    }
    internal var keyChainLabel: String {
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
    
    internal func getPrivateKeyFromKeyChain() -> SecKey? {
        let getquery: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyChainTag,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecReturnRef as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(getquery as CFDictionary, &item)
        if status == errSecSuccess {
            return (item as! SecKey)
        }
        return nil
    }
    
    internal func createPrivateKeyAndSaveToKeyChain() -> SecKey? {
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
    
    public func getMyPublicKey() throws -> PublicKeyBase64String {
        guard let myPublicKey = self.myPublicKey else {
            throw Error.publicKey("public key is not ready")
        }
        guard let publicKeyData = (SecKeyCopyExternalRepresentation(myPublicKey, nil) as Data?) else {
            throw Error.publicKey("cannot make public key data")
        }
        let publicKeyBase64 = publicKeyData.base64EncodedString(options: [])
        return publicKeyBase64
    }
    
    internal static func getPublicKey(publicKeyBase64: PublicKeyBase64String) throws -> SecKey {
        guard let keyData = Data(base64Encoded: publicKeyBase64, options: [.ignoreUnknownCharacters]) else {
            throw Error.publicKey("invalid public key base64")
        }
        let sizeInBits = keyData.count * 8
        let keyDict: [CFString: Any] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits: NSNumber(value: sizeInBits),
            kSecReturnPersistentRef: true,
        ]
        var error: Unmanaged<CFError>?
        guard let publicKey = SecKeyCreateWithData(keyData as CFData, keyDict as CFDictionary, &error) else {
            throw Error.publicKey("cannot create public key")
        }
        return publicKey
    }
    
    public func encryptWithMyPublicKey(plainText: PlainString) throws -> CipherBase64String {
        guard let myPublicKey = self.myPublicKey else {
            throw Error.encrypt("public key is not ready")
        }
        return try RsaLocalKeyChain.encryptWithSpecifiedKey(plainText: plainText, key: myPublicKey)
    }
    
    internal static func encryptWithSpecifiedPublicKey(plainText: PlainString, publicKeyBase64: PublicKeyBase64String) throws -> CipherBase64String {
        let publicKey = try RsaLocalKeyChain.getPublicKey(publicKeyBase64: publicKeyBase64)
        return try encryptWithSpecifiedKey(plainText: plainText, key: publicKey)
    }
    
    internal static func encryptWithSpecifiedKey(plainText: PlainString, key: SecKey) throws -> CipherBase64String {
        guard SecKeyIsAlgorithmSupported(key, .encrypt, algorithmEncrypt) else {
            throw Error.encrypt("an algorithm is not suppoted")
        }
        let secKeyBlockSize = SecKeyGetBlockSize(key)
        let textSize = plainText.data(using: .utf8)?.count ?? 32767
        guard textSize < (secKeyBlockSize - 130) else {
            throw Error.encrypt("plainText is too long")
        }
        
        guard let plainData = plainText.data(using: .utf8) else {
            throw Error.encrypt("cannot convert plainText to Data")
        }
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
    
    internal static func decryptWithPrivateKey(cipherBase64: CipherBase64String, privateKey: SecKey) throws -> PlainString {
        guard SecKeyIsAlgorithmSupported(privateKey, .decrypt, RsaLocalKeyChain.algorithmEncrypt) else {
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
                RsaLocalKeyChain.algorithmEncrypt,
                cipherData as CFData,
                &error
            ) as Data?
        else {
            throw error!.takeRetainedValue() as CFError
        }
        
        guard let clearString = PlainString(data: clearData, encoding: .utf8) else {
            throw Error.decrypt("cannot convert data to string")
        }
        return clearString
    }
    
    public func decryptWithMyPrivateKey(cipherBase64: CipherBase64String) throws -> PlainString {
        guard let myPrivateKey = self.myPrivateKey else {
            throw Error.privateKey("private key is not ready")
        }
        return try RsaLocalKeyChain.decryptWithPrivateKey(cipherBase64: cipherBase64, privateKey: myPrivateKey)
    }
    
    public func createSignatureWithMyPrivateKey(plainText: PlainString) throws -> SignatureBase64String {
        guard let myPrivateKey = self.myPrivateKey else {
            throw Error.privateKey("private key is not ready")
        }
        guard SecKeyIsAlgorithmSupported(myPrivateKey, .sign, RsaLocalKeyChain.algorithmSign) else {
            throw Error.sign("an algorithm is not suppoted")
        }
        
        let plainData = plainText.data(using: .utf8)!
        var error: Unmanaged<CFError>?
        guard
            let signature = SecKeyCreateSignature(
                myPrivateKey,
                RsaLocalKeyChain.algorithmSign,
                plainData as CFData,
                &error
            ) as Data?
        else {
            throw error!.takeRetainedValue() as CFError
        }
        
        let signatureBase64 = signature.base64EncodedString()
        return signatureBase64
    }
    
    internal static func verifySignWithPublicSecKey(plainText: PlainString, signatureBase64: SignatureBase64String, publicKey: SecKey) throws -> Bool {
        guard let signatureVerify = Data(base64Encoded: signatureBase64, options: []) else {
            throw Error.sign("invalid signature")
        }
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
                signatureVerify as CFData,
                &error
            )
        else {
            return false
        }
        return true
    }
    
    public func verifySignWithPublicKey(plainText: PlainString, signatureBase64: SignatureBase64String, publicKeyBase64: PublicKeyBase64String) throws -> Bool
    {
        let publicKey = try RsaLocalKeyChain.getPublicKey(publicKeyBase64: publicKeyBase64)
        return try RsaLocalKeyChain.verifySignWithPublicSecKey(plainText: plainText, signatureBase64: signatureBase64, publicKey: publicKey)
    }
    
    public func verifySignWithMyPublicKey(plainText: PlainString, signatureBase64: SignatureBase64String) throws -> Bool {
        guard let myPublicKey = self.myPublicKey else {
            throw Error.publicKey("public key is not ready")
        }
        return try RsaLocalKeyChain.verifySignWithPublicSecKey(
            plainText: plainText,
            signatureBase64: signatureBase64,
            publicKey: myPublicKey
        )
    }
}
