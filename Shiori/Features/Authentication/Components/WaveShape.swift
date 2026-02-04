//
//  WaveShape.swift
//  Shiori
//
//  Created by Henrique Hida on 17/11/25.
//

import SwiftUI

struct WaveStarting: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addCurve(to: CGPoint(x: rect.minX, y: rect.maxY),
                      control1: CGPoint(x: rect.maxX * 0.75, y: rect.maxY * 0.75),
                      control2: CGPoint(x: rect.maxX * 0.25, y: rect.maxY * 1.25))
        path.closeSubpath()
        
        return path
    }
}

struct WaveSignIn: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.8))
        path.addCurve(to: CGPoint(x: rect.minX, y: rect.maxY),
                      control1: CGPoint(x: rect.maxX * 0.75, y: rect.maxY * 0.65),
                      control2: CGPoint(x: rect.maxX * 0.5, y: rect.maxY * 1.25))
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    WaveSignIn()
        .stroke(Color.red, lineWidth: 5)
        .frame(height: 250)
}
