//
//  GeometricBackground.swift
//  tBag
//
//  Created by Manabu Tonosaki on 2026-02-16.
//

import SwiftUI

@available(macOS 12.0, iOS 15.0, *)
public struct BackgroundScatteredTrianglesSpin: View {
    @State private var startDate = Date()
    @State private var triangles: [TriangleItem] = []
    @State private var canvasSize: CGSize = .zero
    
    public var body: some View {
        GeometryReader { _ in
            TimelineView(.animation) { timelineContext in
                Canvas { context, size in
                    if triangles.isEmpty || canvasSize != size {
                        DispatchQueue.main.async {
                            canvasSize = size
                            initTriangles(size: size)
                        }
                    }
                    let elapsedTime = timelineContext.date.timeIntervalSince(startDate)
                    drawAnimatedTriangles(context: context, size: size, elapsedTime: elapsedTime)
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            startDate = Date()
        }
    }
    
    private func initTriangles(size: CGSize) {
        var newTriangles: [TriangleItem] = []
        var random = SystemRandomNumberGenerator()
        let symbolsCount = 1200
        let symbolSizeBase: CGFloat = 8.0
        
        for _ in 0..<symbolsCount {
            let xpos = CGFloat.random(in: 0...size.width, using: &random)
            let ypos = CGFloat.random(in: 0...size.height, using: &random)
            let velocityX = CGFloat.random(in: -10...10, using: &random)
            let velocityY = CGFloat.random(in: -10...10, using: &random)
            let baseRotation = Double.random(in: 0..<360, using: &random)
            let rotationSpeed = Double.random(in: -150...150, using: &random)
            let symbolSize: CGFloat = Double.random(in: 0.5...1.0, using: &random) * symbolSizeBase
            let randomOpacity = Double.random(in: 0.05...0.15, using: &random)
            let color = Color(hue: Double.random(in: 0...1, using: &random), saturation: 0.9, brightness: 0.9)
            
            newTriangles.append(TriangleItem(
                position: CGPoint(x: xpos, y: ypos),
                velocity: CGSize(width: velocityX, height: velocityY),
                baseRotation: baseRotation,
                rotationSpeed: rotationSpeed,
                size: symbolSize,
                opacity: randomOpacity,
                color: color
            ))
        }
        triangles = newTriangles
    }
    
    private func drawAnimatedTriangles(context: GraphicsContext, size: CGSize, elapsedTime: TimeInterval) {
        let halfSqrt3 = sqrt(3.0) / 2.0
        
        for triangle in triangles {
            let angle = Angle.degrees(triangle.baseRotation + triangle.rotationSpeed * elapsedTime)
            var xpos = triangle.position.x + triangle.velocity.width * CGFloat(elapsedTime)
            var ypos = triangle.position.y + triangle.velocity.height * CGFloat(elapsedTime)

            xpos = (xpos.truncatingRemainder(dividingBy: size.width + triangle.size * 2))
            if xpos < -triangle.size {
                xpos += size.width + triangle.size * 2
            }
            ypos = (ypos.truncatingRemainder(dividingBy: size.height + triangle.size * 2))
            if ypos < -triangle.size {
                ypos += size.height + triangle.size * 2
            }
            
            let radius = triangle.size
            let bottomY = radius / 2.0
            let bottomXOffset = radius * halfSqrt3

            context.drawLayer { layerContext in
                layerContext.opacity = triangle.opacity
                layerContext.translateBy(x: xpos, y: ypos)
                layerContext.rotate(by: angle)

                var path = Path()
                path.move(to: CGPoint(x: 0, y: -radius))
                path.addLine(to: CGPoint(x: -bottomXOffset, y: bottomY))
                path.addLine(to: CGPoint(x: bottomXOffset, y: bottomY))
                path.closeSubpath()
                layerContext.stroke(path, with: .color(triangle.color), lineWidth: 1.0)
            }
        }
    }
}

@available(macOS 12.0, iOS 15.0, *)
struct TriangleItem: Identifiable {
    let id = UUID()
    var position: CGPoint
    let velocity: CGSize
    let baseRotation: Double
    let rotationSpeed: Double
    let size: CGFloat
    let opacity: Double
    let color: Color
}
