// Tono (Tools Of New Operation) library
//  MIT Lisence (c) 2021 Manabu Tonosaki all rights reserved
//
//  Created by Manabu Tonosaki on 2021/12/12.
//

import Foundation

open class StrUtil {
    public static func Mid(_ str: String, start: Int, len: Int = 999999999) -> String.SubSequence {
        if start >= str.count {
            return str[str.endIndex..<str.endIndex]
        }
        var safeStart: Int = start
        var safeLen: Int = len
        if start < 0 {
            safeLen = safeLen + start
            safeStart = 0
        }
        if safeStart + safeLen >= str.count {
            safeLen = str.count - safeStart
        }
        let i0 = str.startIndex
        let i1 = str.index(i0, offsetBy: safeStart)
        if safeLen < 1 {
            return str[i1..<i1]
        }
        let i2 = str.index(i1, offsetBy: safeLen)
        return str[i1..<i2]
    }
    
    static func parseBoolFuzzy(_ str: String) -> Bool? {
        let s = str.lowercased()
        switch s {
        case "true": return true
        case "yes": return true
        case "ok": return true
        default:
            return nil
        }
    }
}
