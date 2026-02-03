import SwiftUI
import CryptoKit

#if canImport(UIKit)
import UIKit
public typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias PlatformImage = NSImage
#endif

@available(macOS 13.0, iOS 16.0, *)
public struct ImageHash {
    
    @MainActor
    public static func getImageHash(image: Image, callback: ((Image, Data) -> Void)? = nil) -> String {
        let renderer = ImageRenderer(content: image)
        renderer.scale = 1.0
        
#if os(iOS)
        guard let platformImage = renderer.uiImage else { return "00000000" }
#else
        guard let platformImage = renderer.nsImage else { return "00000000" }
#endif
        return self.getImageHash(from: platformImage, callback: callback)
    }
    
    private static func getImageHash(from image: PlatformImage, callback: ((Image, Data) -> Void)? = nil) -> String {
        let defaultHash = "00000000"
#if os(iOS)
        guard let sourceCGImage = image.cgImage else { return defaultHash }
#else
        guard let sourceCGImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return defaultHash }
#endif
        let sourceWidth = sourceCGImage.width
        let sourceHeight = sourceCGImage.height
        
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(
                data: nil,
                width: sourceWidth,
                height: sourceHeight,
                bitsPerComponent: 8,
                bytesPerRow: 0, // zero for auto calc
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
              )
        else { return defaultHash }
        
        context.setShouldAntialias(false)
        context.setAllowsAntialiasing(false)
        context.interpolationQuality = .none
        context.setBlendMode(.copy)
        context.clear(CGRect(x: 0, y: 0, width: sourceWidth, height: sourceHeight))
        context.draw(sourceCGImage, in: CGRect(x: 0, y: 0, width: sourceWidth, height: sourceHeight))
        
        guard let sourceDataRaw = context.data else { return defaultHash }
        
        let sourceBytes = sourceDataRaw.bindMemory(to: UInt8.self, capacity: sourceWidth * sourceHeight * 4)
        let sourceBytesPerRow = context.bytesPerRow
        let bytesPerPixel = 4 // 1byte x 4channel(RGBA)
        
        let targetWidth = 32
        let targetHeight = Int(ceil(Double(targetWidth) / Double(sourceWidth) * Double(sourceHeight)))
        
        var pixelCore = Data()
        var pixelInner = Data()
        var pixelOuter = Data()
        var pixelAll = Data()
        pixelAll.reserveCapacity(targetWidth * targetHeight)
        
        var debugPixels = Data()
        debugPixels.reserveCapacity(targetWidth * targetHeight * 4)
        
        let marginW = targetWidth / 8
        let marginH = targetHeight / 8
        let coreRangeW = (marginW * 2)..<(targetWidth - marginW * 2)
        let coreRangeH = (marginH * 2)..<(targetHeight - marginH * 2)
        
        for y in 0..<targetHeight {
            let startY = (y * sourceHeight) / targetHeight
            let endY = ((y + 1) * sourceHeight) / targetHeight
            let effectiveEndY = max(endY, startY + 1)
            
            for x in 0..<targetWidth {
                let startX = (x * sourceWidth) / targetWidth
                let endX = ((x + 1) * sourceWidth) / targetWidth
                let effectiveEndX = max(endX, startX + 1)
                
                var totalR: Int = 0
                var totalG: Int = 0
                var totalB: Int = 0
                var totalA: Int = 0
                var count: Int = 0
                
                for sy in startY..<effectiveEndY {
                    if sy >= sourceHeight { break }
                    let rowOffset = sy * sourceBytesPerRow
                    
                    for sx in startX..<effectiveEndX {
                        if sx >= sourceWidth { break }
                        
                        let offset = rowOffset + sx * bytesPerPixel
                        totalR += Int(sourceBytes[offset + 0])
                        totalG += Int(sourceBytes[offset + 1])
                        totalB += Int(sourceBytes[offset + 2])
                        totalA += Int(sourceBytes[offset + 3])
                        count += 1
                    }
                }
                
                let div = max(1, count)
                let rawAvgA = (totalA + (div / 2)) / div
                let rawAvgR = (totalR + (div / 2)) / div
                let rawAvgG = (totalG + (div / 2)) / div
                let rawAvgB = (totalB + (div / 2)) / div
                
                var finalR: UInt8
                var finalG: UInt8
                var finalB: UInt8
                let finalA = UInt8(rawAvgA)
                
                // ★修正2: アン・プリマルチプライ（Un-premultiply）
                // アルファ値の影響で暗くなっているRGB値を、元の明るさに戻す。
                // これにより、アルファ値が多少ズレても、元の「色味」自体は一致するようになる。
                if rawAvgA > 0 {
                    finalR = UInt8(min(255, (rawAvgR * 255) / rawAvgA))
                    finalG = UInt8(min(255, (rawAvgG * 255) / rawAvgA))
                    finalB = UInt8(min(255, (rawAvgB * 255) / rawAvgA))
                } else {
                    finalR = 0
                    finalG = 0
                    finalB = 0
                }
                
                // 3-3-2変換 (ビットシフトで十分に情報が丸められるため、事前のマスクは不要になりました)
                let pixelValue: UInt8
                
                // 透明度判定（アンチエイリアスの薄いゴミを消す）
                if finalA < 40 {
                    pixelValue = 0
                    debugPixels.append(contentsOf: [0, 0, 0, 0])
                } else {
                    pixelValue = makeColorValue(finalR, finalG, finalB)
                    debugPixels.append(contentsOf: [finalR, finalG, finalB, 255])
                }
                
                pixelAll.append(pixelValue)
                
                let isCore = coreRangeW.contains(x) && coreRangeH.contains(y)
                let isOuter = x < marginW || x >= (targetWidth - marginW) || y < marginH || y >= (targetHeight - marginH)
                
                if isCore {
                    pixelCore.append(pixelValue)
                } else if isOuter {
                    pixelOuter.append(pixelValue)
                } else {
                    pixelInner.append(pixelValue)
                }
            }
        }
        if let callback = callback {
            let debugImage = debugPixels.withUnsafeBytes { ptr -> Image in
                guard let baseAddress = ptr.baseAddress else { return Image(systemName: "xmark") }
                let context = CGContext(
                    data: UnsafeMutableRawPointer(mutating: baseAddress),
                    width: targetWidth,
                    height: targetHeight,
                    bitsPerComponent: 8,
                    bytesPerRow: targetWidth * 4,
                    space: CGColorSpace(name: CGColorSpace.sRGB)!,
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
                )
                
                if let cgImage = context?.makeImage() {
                    return Image(cgImage, scale: 1.0, label: Text("Debug Hash Image"))
                } else {
                    return Image(systemName: "xmark")
                }
            }
            callback(debugImage, pixelAll)
        }
        return computeFinalHash(core: pixelCore, inner: pixelInner, outer: pixelOuter)
    }
    
    private static func makeColorValue(_ r: UInt8, _ g: UInt8, _ b: UInt8) -> UInt8 {
        let r3 = r >> 5
        let g3 = g >> 5
        let b2 = b >> 6
        return (r3 << 5) | (g3 << 2) | b2
    }
    
//    private static func makeColorValue(_ r: UInt8, _ g: UInt8, _ b: UInt8) -> UInt8 {
//        let rd = Double(r) / 255.0
//        let gd = Double(g) / 255.0
//        let bd = Double(b) / 255.0
//        
//        let maxC = max(rd, gd, bd)
//        let minC = min(rd, gd, bd)
//        let delta = maxC - minC
//        
//        let brightnessVal = UInt8(sqrt(maxC) * 7.0 + 0.5)
//        
//        let saturationVal = (maxC == 0) ? 0.0 : (delta / maxC)
//        let isGrayscale = saturationVal < 0.15
//        
//        if isGrayscale {
//            return brightnessVal << 1
//        } else {
//            var hue: Double = 0.0
//            if delta > 0 {
//                if maxC == rd {
//                    hue = (gd - bd) / delta + (gd < bd ? 6.0 : 0.0)
//                } else if maxC == gd {
//                    hue = (bd - rd) / delta + 2.0
//                } else {
//                    hue = (rd - gd) / delta + 4.0
//                }
//                hue /= 6.0
//            }
//            let hueVal = UInt8(hue * 15.0 + 0.5) & 0x0F
//            
//            return (hueVal << 4) | (brightnessVal << 1) | 1
//        }
//    }
    
    private static func computeFinalHash(core: Data, inner: Data, outer: Data) -> String {
        let hash1 = SHA512.hash(data: core)
        let hash2 = SHA512.hash(data: inner).prefix(62)
        let hash3 = SHA512.hash(data: outer).prefix(60)
        
        var combinedData = Data()
        combinedData.append(contentsOf: hash1)
        combinedData.append(contentsOf: hash2)
        combinedData.append(contentsOf: hash3)
        
        return combinedData.base64EncodedString()
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "=", with: "")
    }
}

