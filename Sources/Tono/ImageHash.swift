//
//  ImageHash.swift
//  Tono
//
//  Created by Manabu Tonosaki on 2026-01-26.
//

import SwiftUI
import CryptoKit

#if canImport(UIKit)
import UIKit
public typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias PlatformImage = NSImage
#endif

typealias ImageHashString = String

@available(macOS 10.15, iOS 13.0, *)
public struct ImageHash {
    public static func getImageHash(image: UIImage, callback: ((Image, Data) -> Void)? = nil) -> Base64String {
        let defaultHash = "00000000"
        let targetWidth: CGFloat = 32
        let canvasSize = CGSize(width: targetWidth, height: CGFloat(ceil(targetWidth / image.size.width * image.size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, image.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        let alphaFill = ImageHash.createSolidColorImage(size: canvasSize, color: UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0))
        alphaFill.draw(in: CGRect(origin: .zero, size: canvasSize))
        image.draw(in: CGRect(origin: .zero, size: canvasSize))
        guard let image2 = UIGraphicsGetImageFromCurrentImageContext() else {
            return defaultHash
        }
        guard let cgImage = image2.cgImage else {
            return defaultHash
        }
        guard let cfdata = cgImage.dataProvider.unsafelyUnwrapped.data else {
            return defaultHash
        }
        guard let data = CFDataGetBytePtr(cfdata) else {
            return defaultHash
        }
        let W = Int(cgImage.width)
        let H = Int(cgImage.height)

        var hashStr = ""
        let bitPerPixel = cgImage.bitsPerPixel
        var hashBase = Data()
        
        for y in 0..<H {
            for x in 0..<W {
                let pos = cgImage.bytesPerRow * y + x * (bitPerPixel / 8)
                let rgb8 = make16ColorDepth(data[pos + 0], data[pos + 1], data[pos + 2])
                hashBase.append(rgb8)
            }
        }
        callback?(Image(cgImage, scale: 1.0, label: Text("(\(W),\(H)) bitPerPixel=\(bitPerPixel)")), hashBase)
        
        let oneThird = hashBase.count / 3
        let hash1 = SHA512.hash(data: hashBase.subdata(in: 0..<oneThird)).prefix(61)
        let hash2 = SHA512.hash(data: hashBase.subdata(in: oneThird..<(oneThird * 2)))
        let hash3 = SHA512.hash(data: hashBase.subdata(in: (oneThird * 2)..<(hashBase.count))).prefix(61)
        var combinedData = Data()
        combinedData.append(contentsOf: hash1)
        combinedData.append(contentsOf: hash2)
        combinedData.append(contentsOf: hash3)
        return StrUtil.makeUrlSafeBase64(data: combinedData)
    }
    
    static func make16ColorDepth(_ r: UInt8, _ g: UInt8, _ b: UInt8) -> UInt8 {
        let rgbAve = UInt8((UInt(r)+UInt(g)+UInt(b)) / 3)
        return (rgbAve / 64) << 6 | (r / 64) << 4 | (g / 64) << 2 | (b / 64)
    }
    
    static func createSolidColorImage(size: CGSize, color: UIColor = .gray) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let color = UIColor(red:0.5, green: 0.5, blue: 0.5, alpha: 1.0)
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}


