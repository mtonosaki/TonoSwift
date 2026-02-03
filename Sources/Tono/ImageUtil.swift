//
//  ImageUtil.swift
//  Tono
//
//  Created by Manabu Tonosaki on 2026-02-01.
//

import SwiftUI

public struct ImageUtil {
    
    @available(macOS 13.0, iOS 16.0, *)
    @MainActor
    public static func resizeImage(_ image: Image, maxPixel: CGFloat) -> (image: Image, data: Data)? {
#if os(iOS)
        let renderer = ImageRenderer(content: image.resizable().frame(width: maxPixel, height: maxPixel))
        guard let uiImage = renderer.uiImage else { return nil }
        
        let size = uiImage.size
        let scale = min(maxPixel / size.width, maxPixel / size.height, 1.0)
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        let UIRenderer = UIGraphicsImageRenderer(size: newSize)
        let finalUIImage = UIRenderer.image { _ in
            uiImage.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        guard let data = finalUIImage.pngData() else { return nil }
        return (Image(uiImage: finalUIImage), data)
        
#elseif os(macOS)
        let renderer = ImageRenderer(content: image.resizable().frame(width: maxPixel, height: maxPixel))
        guard let nsImage = renderer.nsImage else { return nil }
        
        let size = nsImage.size
        let scale = min(maxPixel / size.width, maxPixel / size.height, 1.0)
        let newSize = NSSize(width: size.width * scale, height: size.height * scale)
        
        let finalNSImage = NSImage(size: newSize)
        finalNSImage.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        nsImage.draw(in: NSRect(origin: .zero, size: newSize), from: NSRect(origin: .zero, size: size), operation: .sourceOver, fraction: 1.0)
        finalNSImage.unlockFocus()
        
        guard let tiffData = finalNSImage.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData),
              let data = bitmapRep.representation(using: .png, properties: [:]) else { return nil }
        
        return (Image(nsImage: finalNSImage), data)
#endif
    }
    
    
    public static func calculatePixelOccupancy(size: UInt, subdivisions: UInt = 3) -> [[Double]] {
        if size == 0 {
            return []
        }
        if size == 1 {
            return [[1.0]]
        }
        let squareSize = Double(size)
        let canvasSizeFloat = ceil(squareSize * sqrt(2.0))
        let canvasSize = Int(canvasSizeFloat)
        let subDouble = Double(subdivisions)
        let halfCanvas = Double(canvasSize) / 2.0
        let radius = (squareSize * sqrt(2.0)) / 2.0
        let startOffset = -halfCanvas + 0.5

        var result = Array(repeating: Array(repeating: 0.0, count: canvasSize), count: canvasSize)
        
        for row in 0..<canvasSize {
            for col in 0..<canvasSize {
                let px = startOffset + Double(col)
                let py = startOffset + Double(row)
                
                var insideCount = 0.0
                let subStep = 1.0 / subDouble
                let subStart = -0.5 + (subStep / 2.0)
                
                for si in 0..<Int(subdivisions) {
                    for sj in 0..<Int(subdivisions) {
                        let sx = px + subStart + Double(sj) * subStep
                        let sy = py + subStart + Double(si) * subStep
                        
                        // 判定 (x^2 + y^2 <= R^2)
                        if (sx * sx + sy * sy) <= (radius * radius) {
                            insideCount += 1.0
                        }
                    }
                }
                result[row][col] = insideCount / (subDouble * subDouble)
            }
        }
        
        return result
    }
}
