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
        
#if os(iOS)
        guard let platformImage = renderer.uiImage else { return "00000000" }
#else
        guard let platformImage = renderer.nsImage else { return "00000000" }
#endif
        return self.getImageHash(from: platformImage, callback: callback)
    }
    
    private static func getImageHash(from image: PlatformImage, callback: ((Image, Data) -> Void)? = nil) -> String {
        let defaultHash = "00000000"
        let targetWidth: CGFloat = 32
        
#if os(iOS)
        let originalSize = image.size
        let scale = image.scale
#else
        let originalSize = image.size
        let scale: CGFloat = 1.0
#endif
        
        let targetHeight = CGFloat(ceil(targetWidth / originalSize.width * originalSize.height))
        let canvasSize = CGSize(width: targetWidth, height: targetHeight)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let context = CGContext(
            data: nil,
            width: Int(canvasSize.width),
            height: Int(canvasSize.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return defaultHash
        }
        
        context.setFillColor(gray: 0.5, alpha: 1.0)
        context.fill(CGRect(origin: .zero, size: canvasSize))
#if os(iOS)
        let cgImageRef = image.cgImage
#else
        let cgImageRef = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
#endif
        guard let cgImage = cgImageRef else { return defaultHash }
        context.interpolationQuality = .high
        context.draw(cgImage, in: CGRect(origin: .zero, size: canvasSize))
        
        guard let processedCGImage = context.makeImage() else { return defaultHash }
        guard let dataProvider = processedCGImage.dataProvider,
              let cfData = dataProvider.data,
              let dataPtr = CFDataGetBytePtr(cfData) else {
            return defaultHash
        }
        
        let W = processedCGImage.width
        let H = processedCGImage.height
        let bytesPerRow = processedCGImage.bytesPerRow
        let bytesPerPixel = processedCGImage.bitsPerPixel / 8
        
        let marginW = W / 8
        let marginH = H / 8
        let coreRangeW = (marginW * 2)..<(W - marginW * 2)
        let coreRangeH = (marginH * 2)..<(H - marginH * 2)
        let leftEdge = 0..<marginW
        let rightEdge = (W-marginW)..<W
        let topEdge = 0..<marginH
        let bottomEdge = (H-marginH)..<H

        var pixelCore = Data()
        var pixelInner = Data()
        var pixelOuter = Data()
        var pixelAll = Data()
        pixelAll.reserveCapacity(W * H)
        
        for y in 0..<H {
            for x in 0..<W {
                let pos = y * bytesPerRow + x * bytesPerPixel
                guard pos + 2 < CFDataGetLength(cfData) else { continue }
                
                let pixelValue = make16ColorDepth(dataPtr[pos + 0], dataPtr[pos + 1], dataPtr[pos + 2])
                pixelAll.append(pixelValue)

                switch (x, y) {
                case (coreRangeW, coreRangeH):
                    pixelCore.append(pixelValue)
                case (leftEdge, _), (rightEdge, _), (_, topEdge), (_, bottomEdge):
                    pixelOuter.append(pixelValue)
                default:
                    pixelInner.append(pixelValue)
                }
            }
        }
        callback?(Image(processedCGImage, scale: scale, label: Text("image for hash calculation")), pixelAll)
        return computeFinalHash(core: pixelCore, inner: pixelInner, outer: pixelOuter)
    }
    
    private static func make16ColorDepth(_ r: UInt8, _ g: UInt8, _ b: UInt8) -> UInt8 {
        let rgbAve = UInt8((UInt(r) + UInt(g) + UInt(b)) / 3)
        return (rgbAve / 64) << 6 | (r / 64) << 4 | (g / 64) << 2 | (b / 64)
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

