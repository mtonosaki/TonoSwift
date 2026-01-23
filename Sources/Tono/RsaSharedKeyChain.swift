//
//  RsaSharedKeyChain.swift
//  Tono
//
//  Created by Manabu Tonosaki on 2026-01-21.
//

import Foundation
import Security

@available(macOS 10.15, iOS 13.0, *)
public class RsaSharedKeyChain: RsaLocalKeyChain {
    var accessGroup: String
    
    public init(nameMain: String, nameSub: String, accessGroup: String) {
        self.accessGroup = accessGroup
        super.init(nameMain: nameMain, nameSub: nameSub)
    }
    
    override func getPrivateKeyFromKeyChain() -> SecKey? {
        let getquery: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrApplicationTag as String: super.keyChainTag,
            kSecAttrSynchronizable as String: true,
            kSecAttrAccessGroup as String: self.accessGroup,
            kSecReturnRef as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(getquery as CFDictionary, &item)
        if status == errSecSuccess {
            return (item as! SecKey)
        }
        return nil
    }
    
    override func createPrivateKeyAndSaveToKeyChain() -> SecKey? {
        let attributes: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: 2048,
            kSecPrivateKeyAttrs as String: [
                kSecAttrLabel as String: keyChainLabel,
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: keyChainTag,
            ],
            kSecAttrSynchronizable as String: true,
            kSecAttrAccessGroup as String: self.accessGroup,
        ]
        var error: Unmanaged<CFError>?
        guard let generatedPrivateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            return nil
        }
        return generatedPrivateKey
        
    }
}
