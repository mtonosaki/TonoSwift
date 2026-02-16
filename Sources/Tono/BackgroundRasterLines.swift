//
//  RasterLinesBackground.swift
//  tBag
//
//  Created by Manabu Tonosaki on 2026-02-16.
//

import SwiftUI

@available(macOS 12.0, iOS 15.0, *)
public struct BackgroundRasterLines: View {
    public init() {
        
    }

    public var body: some View {
        Canvas { context, size in
            context.opacity = 0.1
            drawRasterLines(context: context, size: size)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private func drawRasterLines(context: GraphicsContext, size: CGSize) {
        let step: CGFloat = 8
        let width = size.width
        let height = size.height
        var path = Path()
        
        for xpos in stride(from: -height, to: width + height, by: step) {
            path.move(to: CGPoint(x: xpos, y: 0))
            path.addLine(to: CGPoint(x: xpos + height, y: height))
        }
        
        context.stroke(path, with: .color(.gray), lineWidth: 1)
    }
}
