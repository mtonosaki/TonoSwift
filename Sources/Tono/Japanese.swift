// Tono (Tools Of New Operation) library
//  MIT Lisence (c) 2021 Manabu Tonosaki all rights reserved
//
//  Created by Manabu Tonosaki on 2022/01/03.

import Foundation

public struct Japanese
{
    var c2c1 = Dictionary<String, String>()       // for Passs1
    var hkana2c1 = Dictionary<String, String>()   // for Pass1(byte kana)
    
    public init() {
        do {
            let from = "あいうえおぁぃぅぇぉヴかきくけこがぎぐげごさしすせそざじずぜぞたちつてとだぢヂづヅでどっなにぬねのはひふへほばびぶべぼぱぴぷぺぽまみむめもやゆよゃゅょらりるれろわをヲんａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ０１２３４５６７８９零一二三四五六七八九！”＃＄％＆’（）＝－＾～￥｜／｛｝［］＜＞，．＿";
            let to = "アイウエオァィゥェォブカキクケコガギグゲゴサシスセソザジズゼゾタチツテトダジジズズデドッナニヌネノハヒフヘホバビブベボパピプペポマミムメモヤユヨャュョラリルレロワオオンabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz01234567890123456789!\"#$%&'()=-^~\\|/{}[]<>,._";
            
            // Pass1
            for index in 0..<from.count {
                let cs = String(StrUtil.mid(from, start: index, length: 1))
                var cr = String(StrUtil.mid(to, start: index, length: 1))
                if (cs == cr) {
                    cr = "_"
                }
                self.c2c1[cs] = cr
            }
            self.c2c1["ー"] = "-"
            self.c2c1["－"] = "-"
            self.c2c1["～"] = "-"
            self.c2c1["→"] = "-"
        }
        
        // Hankaku kana
        do {
            let from = "ｱｲｳｴｵｧｨｩｪｫｶｷｸｹｺｻｼｽｾｿﾀﾁﾂｯﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖｬｭｮﾗﾘﾙﾚﾛﾜｦﾝ"
            let to = "アイウエオァィゥェォカキクケコサシスセソタチツッテトナニヌネノハヒフヘホマミムメモヤユヨャュョラリルレロワヲン"
            for index in 0..<from.count {
                let cs = String(StrUtil.mid(from, start: index, length: 1))
                let cr = String(StrUtil.mid(to, start: index, length: 1))
                self.hkana2c1[cs] = cr
            }
        }
        do {
            let from = "ｶﾞｷﾞｸﾞｹﾞｺﾞｻﾞｼﾞｽﾞｾﾞｿﾞﾀﾞﾁﾞﾂﾞﾃﾞﾄﾞﾊﾞﾋﾞﾌﾞﾍﾞﾎﾞﾊﾟﾋﾟﾌﾟﾍﾟﾎﾟ"
            let to = "ガギグゲゴザジズゼゾダジズデドバビブベボパピプペポ"
            for index in 0..<from.count {
                let cs = String(StrUtil.mid(from, start: index, length: 2))
                let cr = String(StrUtil.mid(to, start: index / 2, length: 1))
                self.hkana2c1[cs] = cr
            }
        }
    }

    // Get あかさたな character for index.
    public func Getあかさたな(_ str: String) -> String {
        let from = "アイウエオァィゥェォヴカキクケコガギグゲゴサシスセソザジズゼゾタチツテトダヂヅデドッナニヌネノハヒフヘホバビブベボパピプペポマミムメモヤユヨャュョラリルレロワヲンゐゑ0123456789０１２３４５６７８９"
        let to = "あああああああああああかかかかかかかかかかささささささささささたたたたたたたたたたたなななななはははははははははははははははまままままややややややらららららわわわわわ11111111111111111111"
        
        var sb = ""
        for c in str {
            var s1 = GetKeyOne(c, mode: .keepAbbreviation)
            s1 = s1.uppercased()
            if let i = from.firstIndex(of: Character(s1)) {// org.IndexOf(s1); {
                let c = to[i...i]
                sb += c
            }
            else {
                sb += s1
            }
        }
        return sb
    }
    

    // Make fuzzy search string
    public func GetKeyJpKeepver(_ str: String) -> String
    {
        var ret = GetKeyOne(str, mode: .keepAbbreviation)
        ret = wordSpecialSynonim(ret)
        return ret
    }

    // make string for fazzy search
    public func GetKeyJp(_ str: String) -> String
    {
        var ret = GetKeyOne(str, mode: .full)
        ret = wordSpecialSynonim(ret)
        return ret
    }
    
    // normalize some synonim character
    private func wordSpecialSynonim(_ str: String) -> String
    {
        var s = str
        s = s.replacingOccurrences(of: "稼", with: "可")
        s = s.replacingOccurrences(of: "働", with: "動")
        s = s.replacingOccurrences(of: "標", with: "表")
        s = s.replacingOccurrences(of: "可視", with: "みえる")
        s = s.replacingOccurrences(of: "見える", with: "みえる")
        s = s.replacingOccurrences(of: "視界", with: "みえる")
        s = s.replacingOccurrences(of: "インスタンス", with: "実体")
        s = s.replacingOccurrences(of: "オブジェクト", with: "実体")
        s = s.replacingOccurrences(of: "クラス", with: "型")
        s = s.replacingOccurrences(of: "改善", with: "カイゼン")
        s = s.replacingOccurrences(of: "平準化", with: "ヘイジュンカ")
        s = s.replacingOccurrences(of: "無駄", with: "ムダ")
        s = s.replacingOccurrences(of: "表準", with: "標準")
        s = s.replacingOccurrences(of: "表順", with: "標準")
        return s
    }
    
    private func GetChar(_ s: String, i: inout Int) -> String
    {
        // Hankaku-Dakuten
        if i < s.count - 1 {
            let ss = String(StrUtil.mid(s, start: i, length: 2))
            if let cr = hkana2c1[ss] {
                i += 1
                return cr
            }
        }
        // Hankaku
        let sss = String(StrUtil.mid(s, start: i, length: 1))
        if let cr = hkana2c1[sss] {
            return cr
        }
        
        // Etc
        let c = String(StrUtil.mid(s, start: i, length: 1))
        if let cr = c2c1[c] {
            return cr
        } else {
            return c
        }
    }
    
    public enum Modes {
        case full
        case keepAbbreviation
    }

    // Fuzzy single character
    private func GetKeyOne(_ character: String.Element, mode: Modes) -> String {
        return GetKeyOne(String(character), mode: mode)
    }
    
    // Fuzzy single character
    private func GetKeyOne(_ str: String, mode: Modes) -> String
    {
        let normalizedString = str.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        var ret = ""
        var index = 0
        while index < normalizedString.count {
            let char = GetChar(normalizedString, i: &index)
            ret += char
            index += 1
        }
        ret = ret.replacingOccurrences(of: "", with: "")
        ret = ret.replacingOccurrences(of: "クァ", with: "カ")
        ret = ret.replacingOccurrences(of: "クィ", with: "キ")
        ret = ret.replacingOccurrences(of: "クゥ", with: "ク")
        ret = ret.replacingOccurrences(of: "クェ", with: "ケ")
        ret = ret.replacingOccurrences(of: "クォ", with: "コ")
        ret = ret.replacingOccurrences(of: "クワ", with: "クア")
        ret = ret.replacingOccurrences(of: "ディ", with: "デ")
        ret = ret.replacingOccurrences(of: "デュ", with: "ド")
        ret = ret.replacingOccurrences(of: "ヴァ", with: "バ")
        ret = ret.replacingOccurrences(of: "ファ", with: "ハ")
        ret = ret.replacingOccurrences(of: "フィ", with: "ヒ")
        ret = ret.replacingOccurrences(of: "フェ", with: "ヘ")
        ret = ret.replacingOccurrences(of: "フォ", with: "ホ")
        ret = ret.replacingOccurrences(of: "ヒュ", with: "フ")
        ret = ret.replacingOccurrences(of: "ファ", with: "ハ")
        ret = ret.replacingOccurrences(of: "フィ", with: "ヒ")
        ret = ret.replacingOccurrences(of: "フゥ", with: "フ")
        ret = ret.replacingOccurrences(of: "フュ", with: "フ")
        ret = ret.replacingOccurrences(of: "フェ", with: "ヘ")
        ret = ret.replacingOccurrences(of: "フォ", with: "ホ")
        ret = ret.replacingOccurrences(of: "ニュ", with: "ヌ")
        ret = ret.replacingOccurrences(of: "㎥", with: "m3")
        ret = ret.replacingOccurrences(of: "㎡", with: "m2")
        ret = ret.replacingOccurrences(of: "&", with: "and")
        ret = ret.replacingOccurrences(of: "v.s.", with: "vs")
        ret = ret.replacingOccurrences(of: "#", with: "no")
        ret = ret.replacingOccurrences(of: "no.", with: "no")
        ret = ret.replacingOccurrences(of: "　", with: " ")
        if (mode == .full) {
            ret = ret.replacingOccurrences(of: " ", with: "")
            ret = ret.replacingOccurrences(of: "_", with: "")
            ret = ret.replacingOccurrences(of: "-", with: "")
            ret = ret.replacingOccurrences(of: ".", with: "")   // A.K.A --> AKA
            ret = ret.replacingOccurrences(of: "/", with: "")   // S/F --> SF
            ret = ret.replacingOccurrences(of: "・", with: "")
            ret = ret.replacingOccurrences(of: "ッ", with: "")
        }
        
        // a contracted sound.（拗音）
        let from = "ァィゥェォッャュョ"
        let to = "アイウエオッヤユヨ"
        for index in 0..<from.count {
            let o = String(StrUtil.mid(from, start: index, length: 1))
            let n = String(StrUtil.mid(to, start: index, length: 1))
            ret = ret.replacingOccurrences(of: o, with: n);
        }
        
        // a long sound.（長音）
        let longs = "アアカアガアサアザアタアダアナアハアバアパアマアヤアラアワアイイキイギイシイジイチイニイヒイビイピイミイリイウウクウグウスウズウツウヌウフウブウプウムウユウルウエエケエゲエセエゼエテエデエネエヘエベエペエメエレエオオコオゴオソオゾオトオドオノオホオボオポオモオヨオロオ";
        for index in stride(from: 0, to: longs.count, by: 2) {
            let w2 = StrUtil.mid(longs, start: index, length: 2)
            let s1 = StrUtil.left(w2, length: 1)
            var length: Int
            repeat {
                length = ret.count
                ret = ret.replacingOccurrences(of: w2, with: s1)
            } while (ret.count != length)
        }
        return ret
    }
}
