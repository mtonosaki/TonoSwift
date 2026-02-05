import SwiftUI
import CryptoKit

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

@available(macOS 13.0, iOS 16.0, *)
public struct ImageHash {
    public static let defaultHash = "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
    
    @MainActor
    public static func computeHashCode(_ image: Image) -> String {
        let renderer = ImageRenderer(content: image)
        renderer.scale = 1.0
        
#if os(iOS)
        guard let platformImage = renderer.uiImage else { return defaultHash }
        guard let sourceImage = platformImage.cgImage else { return defaultHash }
#else
        guard let platformImage = renderer.nsImage else { return defaultHash }
        guard let sourceImage = platformImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return defaultHash }
#endif
        
        let sourceWidth = max(sourceImage.width, sourceImage.height)
        let sourceHeight = sourceWidth
        
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(
                data: nil,
                width: sourceWidth,
                height: sourceHeight,
                bitsPerComponent: 8,
                bytesPerRow: 0, // zero for auto calc
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue // to assign R|G|B|A bytes
              )
        else { return defaultHash }
        
        context.setShouldAntialias(false)
        context.setAllowsAntialiasing(false)
        context.interpolationQuality = .none
        context.setBlendMode(.copy)
        context.clear(CGRect(x: 0, y: 0, width: sourceWidth, height: sourceHeight))
        context
            .draw(
                sourceImage,
                in: CGRect(
                    x: (sourceWidth - sourceImage.width) / 2,
                    y: (sourceHeight - sourceImage.height) / 2,
                    width: sourceImage.width,
                    height: sourceImage.height
                )
            )
        
        guard let sourceDataRaw = context.data else { return defaultHash }
        
        let sourceBytes = sourceDataRaw.bindMemory(to: UInt8.self, capacity: sourceWidth * sourceHeight * 4)
        let sourceBytesPerRow = context.bytesPerRow
        let bytesPerPixel = 4 // 1byte x 4channel(RGBA)

        return computeImageHashCode(from: sourceBytes, sourceWidth: sourceWidth, sourceHeight: sourceHeight, sourceBytesPerRow: sourceBytesPerRow, bytesPerPixel: bytesPerPixel)
    }
    
    private static func computeImageHashCode(from sourceBytes: UnsafeMutablePointer<UInt8>, sourceWidth: Int, sourceHeight: Int, sourceBytesPerRow: Int, bytesPerPixel: Int) -> String {
        
        let targetWidth = 32
        let targetHeight = 32
        
        var pixelCore = Data()
        var pixelInner = Data()
        var pixelOuter = Data()
        var pixelAll = Data()
        pixelAll.reserveCapacity(targetWidth * targetHeight)
        
        let marginW = targetWidth / 8
        let marginH = targetHeight / 8
        let coreRangeW = (marginW * 2)..<(targetWidth - marginW * 2)
        let coreRangeH = (marginH * 2)..<(targetHeight - marginH * 2)
        let SQRT2 = sqrt(2.0)
        
        let zoomX = Double(sourceWidth) / Double(targetWidth)
        let zoomY = Double(sourceHeight) / Double(targetHeight)
        let occupancy = ImageUtil.calculatePixelOccupancy(size: UInt(max(zoomX, zoomY).rounded(.up)), subdivisions: 8)
        if occupancy.isEmpty { return defaultHash }
        if occupancy[0].count == 0 { return defaultHash }
        
        func getPixelRgba(_ x: Double, _ y: Double) -> SIMD4<Double> {
            let rowOffset = Int(round(y)) * sourceBytesPerRow
            let offset = rowOffset + Int(round(x)) * bytesPerPixel
            let r = Double(sourceBytes[offset + 0]) / 255.0
            let g = Double(sourceBytes[offset + 1]) / 255.0
            let b = Double(sourceBytes[offset + 2]) / 255.0
            let a = Double(sourceBytes[offset + 3]) / 255.0
            return SIMD4(r, g, b, a)
        }
        
        for targetY in 0..<targetHeight {
            let sourceY0 = round(Double(targetY) * zoomY + (zoomY - SQRT2 * zoomY) / 2.0)
            
            for targetX in 0..<targetWidth {
                let sourceX0 = round(Double(targetX) * zoomX + (zoomX - SQRT2 * zoomX) / 2.0)

                var colors = SIMD4<Double>(0.0)
                var counts = SIMD4<Double>(0.0)
                
                for occupancyY in 0..<occupancy.count {
                    let sourceY = max(0, min(sourceY0 + Double(occupancyY), Double(sourceHeight - 1)))
                    
                    for occupancyX in 0..<occupancy[occupancyY].count {
                        let sourceX = max(0, min(sourceX0 + Double(occupancyX), Double(sourceWidth - 1)))
                        
                        let pixelRgba = getPixelRgba(sourceX, sourceY)
                        let pixelVolume = SIMD4<Double>(occupancy[occupancyY][occupancyX])
                        
                        colors = colors + pixelRgba * pixelVolume
                        counts = counts + pixelVolume
                    }
                }
                colors = colors / counts
                let pixelValue = makeColorValue(colors)
                pixelAll.append(pixelValue)
                
                // save color to each ring
                let isCore = coreRangeW.contains(targetX) && coreRangeH.contains(targetY)
                let isOuter = targetX < marginW || targetX >= (targetWidth - marginW) || targetY < marginH || targetY >= (targetHeight - marginH)
                if isCore {
                    pixelCore.append(pixelValue)
                } else if isOuter {
                    pixelOuter.append(pixelValue)
                } else {
                    pixelInner.append(pixelValue)
                }
            }
        }
        return computeFinalHash(core: pixelCore, inner: pixelInner, outer: pixelOuter)
    }
    
    private static func makeColorValue(_ colors: SIMD4<Double>) -> UInt8 {
        let (r, g, b, a) = (colors.x, colors.y, colors.z, colors.w)
        let safeColor = colors.clamped(lowerBound: SIMD4(0.0), upperBound: SIMD4(1.0))
        let safeAlpha = SIMD4(a).clamped(lowerBound: SIMD4(0.0), upperBound: SIMD4(1.0))
        let bgColor = SIMD4<Double>(0.5)
        let blendedColor = safeColor * safeAlpha + bgColor * (SIMD4(1.0) - safeAlpha)

        // RGB Version
        // let r8 = UInt8(min(255, max(0, blendedColor.x * 255)))
        // let g8 = UInt8(min(255, max(0, blendedColor.y * 255)))
        // let b8 = UInt8(min(255, max(0, blendedColor.z * 255)))
        // let r3 = r8 >> 5  // 3bit
        // let g3 = g8 >> 5  // 3bit
        // let b2 = b8 >> 6  // 2bit
        // return (r3 << 5) | (g3 << 2) | b2
        
        // HSB Version
        let maxC = blendedColor.max()
        let minC = blendedColor.min()
        let delta = maxC - minC
        
        let brightnessVal = UInt8(sqrt(maxC) * 7.0 + 0.5)
        let saturationVal = (maxC == 0) ? 0.0 : (delta / maxC)
        let isGrayscale = saturationVal < 0.15
        
        if isGrayscale {
            return brightnessVal << 1
        }
        var hue: Double = 0.0
        if delta > 0 {
            let (blendedR, blendedG, blendedB) = (blendedColor.x, blendedColor.y, blendedColor.z)
            if maxC == blendedR {
                hue = (blendedG - blendedB) / delta + (blendedG < blendedB ? 6.0 : 0.0)
                
            } else if maxC == blendedG {
                hue = (blendedB - blendedR) / delta + 2.0
                
            } else {
                hue = (blendedR - blendedG) / delta + 4.0
            }
            hue /= 6.0
        }
        let hueVal = UInt8(hue * 15.0 + 0.5) & 0x0F
        
        return (hueVal << 4) | (brightnessVal << 1) | 1
    
    }
    
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
