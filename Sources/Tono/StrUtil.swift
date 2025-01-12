// Tono (Tools Of New Operation) library
//  MIT Lisence (c) 2021 Manabu Tonosaki all rights reserved
//
//  Created by Manabu Tonosaki on 2021/12/12.
//

import Foundation

open class StrUtil {
    
    public static func isUuid(_ str: String) -> Bool {
        let sub = str[str.startIndex..<str.endIndex]
        return isUuid(sub)
    }
    
    public static func isUuid(_ str: String.SubSequence) -> Bool {
        let pattern =
            #"^([0-9a-f]{8})-([0-9a-f]{4})-([0-9a-f]{4})-([0-9a-f]{4})-([0-9a-f]{12})$"#
        if #available(iOS 16.0, *) {
            if #available(macOS 13.0, *) {
                let regex = try! Regex(pattern)
                return str.firstMatch(of: regex) != nil
            }
        }
        return false
    }
    
    
    
    public static func isIntegerString(_ str: String ) -> Bool {
        var index = str.startIndex
        for i in 0..<str.count {
            let c = str[index]
            index = str.index(after: index)
            if i == 0 {
                if c == "-" {
                    continue
                }
            }
            if c < "0" || c > "9" {
                return false
            }
        }
        return true
    }
    
    public static func toHms(hour: Double) -> String {
        let h = floor(hour)
        let m = Int(floor((hour - h) * 60))
        let s = Int(floor(hour * 3600)) % 60
        let ret = String(format:"%d:%02d:%02d", Int(h), m, s)
        return ret
    }
    
    public static func rep(_ character: String, n: Int) -> String {
        if n < 1 {
            return ""
        }
        if character.count * n > 4096 {
            return "Error: rep(\(character) x \(n) ... too long result"
        }
        var ret = ""
        for _ in 1...n {
            ret.append(character)
        }
        return ret
    }
    
    public static func mid(_ str: String, start: Int, length: Int = 999999999) -> String.SubSequence {
        if start >= str.count {
            return str[str.endIndex..<str.endIndex]
        }
        var safeStart: Int = start
        var safeLen: Int = length
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

    public static func mid(_ str: String.SubSequence, start: Int, length: Int = 999999999) -> String.SubSequence {
        if start >= str.count {
            return str[str.endIndex..<str.endIndex]
        }
        var safeStart: Int = start
        var safeLen: Int = length
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

    
    public static func left(_ str: String, length: Int) -> String.SubSequence {
        return mid(str, start: 0, length: length)
    }

    public static func left(_ str: String.SubSequence, length: Int) -> String.SubSequence {
        return mid(str, start: 0, length: length)
    }

    public static func right(_ str: String, length: Int) -> String.SubSequence {
        return mid(str, start: str.count - length)
    }
    
    public static func right(_ str: String.SubSequence, length: Int) -> String.SubSequence {
        return mid(str, start: str.count - length)
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
