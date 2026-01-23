// Tono (Tools Of New Operation) library
//  MIT Lisence (c) 2025 Manabu Tonosaki all rights reserved
//  Created by Manabu Tonosaki on 2025/05/10

public protocol Rsa {
    func getMyPublicKey() throws -> PublicKeyBase64String
    func encryptWithMyPublicKey(plainText: PlainString) throws -> CipherBase64String
    func decryptWithMyPrivateKey(cipherBase64: CipherBase64String) throws -> PlainString
    func createSignatureWithMyPrivateKey(plainText: String) throws -> SignatureBase64String
    func verifySignWithMyPublicKey(plainText: PlainString, signatureBase64: SignatureBase64String) throws -> Bool
    func verifySignWithPublicKey(plainText: PlainString, signatureBase64: SignatureBase64String, publicKeyBase64: PublicKeyBase64String) throws -> Bool
}
