//
//  GeometricBackground.swift
//  tBag
//
//  Created by Manabu Tonosaki on 2026-02-16.
//

import SwiftUI

@available(macOS 12.0, iOS 15.0, *)
public struct BackgroundScatteredTriangles: View {
    public init() {
        
    }

    public var body: some View {
        Canvas { context, size in
            drawTriangles(context: context, size: size)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private func drawTriangles(context: GraphicsContext, size: CGSize) {
        let symbolsCount = 1200
        let symbolSizeBase: CGFloat = 8.0
        let halfSqrt3 = sqrt(3.0) / 2.0
        var random = SystemRandomNumberGenerator()
        
        for _ in 0..<symbolsCount {
            let xpos = CGFloat.random(in: 0...size.width, using: &random)
            let ypos = CGFloat.random(in: 0...size.height, using: &random)
            let angle = Angle.degrees(Double.random(in: 0..<360, using: &random))
            let symbolSize: CGFloat = Double.random(in: 0.5...1.0, using: &random) * symbolSizeBase
            let randomOpacity = Double.random(in: 0.05...0.15, using: &random)
            let randomColor = Color(hue: Double.random(in: 0...1, using: &random), saturation: 0.9, brightness: 0.9)
            let radius = symbolSize
            let bottomY = radius / 2.0
            let bottomXOffset = radius * halfSqrt3

            context.drawLayer { subContext in
                subContext.opacity = randomOpacity
                subContext.translateBy(x: xpos, y: ypos)
                subContext.rotate(by: angle)
                var path = Path()
                path.move(to: CGPoint(x: 0, y: -radius))
                path.addLine(to: CGPoint(x: -bottomXOffset, y: bottomY))
                path.addLine(to: CGPoint(x: bottomXOffset, y: bottomY))
                path.closeSubpath()
                subContext.stroke(path, with: .color(randomColor), lineWidth: 1.0)
            }
        }
    }
}
