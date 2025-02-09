//
//  ColorUtil.swift
//  Tono
//
//  Created by Manabu Tonosaki on 2025-02-07.
//

import SwiftUI

@available(macOS 11.0, *)
extension Color {
    init(sharpAndHexString: String) {
        let start = sharpAndHexString.index(
            sharpAndHexString.startIndex, offsetBy: 1)
        let hexColor = String(sharpAndHexString[start...])
        if hexColor.count == 8 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0
            if scanner.scanHexInt64(&hexNumber) {
                let r = Double((hexNumber & 0xff00_0000) >> 24) / 255
                let g = Double((hexNumber & 0x00ff_0000) >> 16) / 255
                let b = Double((hexNumber & 0x0000_ff00) >> 8) / 255
                let a = Double((hexNumber & 0x0000_00ff)) / 255
                self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
                return
            }
        }
        if hexColor.count == 6 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0
            if scanner.scanHexInt64(&hexNumber) {
                let r = Double((hexNumber & 0x00ff_0000) >> 16) / 255
                let g = Double((hexNumber & 0x0000_ff00) >> 8) / 255
                let b = Double((hexNumber & 0x0000_00ff)) / 255
                self.init(.sRGB, red: r, green: g, blue: b, opacity: 1.0)
                return
            }
        }
        if hexColor.count == 3 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0
            if scanner.scanHexInt64(&hexNumber) {
                let r = Double((hexNumber & 0xf00) >> 8) / 15
                let g = Double((hexNumber & 0x0f0) >> 4) / 15
                let b = Double((hexNumber & 0x00f)) / 15
                self.init(.sRGB, red: r, green: g, blue: b, opacity: 1.0)
                return
            }
        }
        self.init(.sRGB, red: 0, green: 0, blue: 0, opacity: 0)
    }

    func toRgbaHexString() -> String {
        guard let cg = self.cgColor else {
            return "#ffffffff"
        }
        guard let components = cg.components else {
            return "#ffffffff"
        }

        return String(
            format: "#%02lx%02lx%02lx%02lx",
            lroundf(Float(components[0]) * 255.0),
            lroundf(Float(components[1]) * 255.0),
            lroundf(Float(components[2]) * 255.0),
            lroundf(Float(components[3]) * 255.0))
    }
}
