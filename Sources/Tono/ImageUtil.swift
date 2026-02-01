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
}
