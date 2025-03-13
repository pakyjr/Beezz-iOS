//
//  HoneycombGauge.swift
//  Beezz
//
//  Created by Lorenzo Pizzuto on 07/03/25.
//


import SwiftUI

struct HoneycombGauge: View {
    let value: Double
    
    var body: some View {
        ZStack {
            HexagonShape()
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.orange, location: 0),
                            .init(color: Color.mediumOrange, location: 0.5),
                            .init(color: .honeyYellow, location: 1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    HexagonShape()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.white.opacity(0.5), .clear]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: Color.orange.opacity(0.3), radius: 15, x: 0, y: 5)
                .frame(width: 200, height: 200)
            
            VStack(spacing: 8) {
                Text("\(value, specifier: "%.1f")%")
                    .font(.system(size: 42, weight: .heavy))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                
                Text("Stato Normale")
                    .font(.headline)
                    .foregroundColor(.white)
                    .opacity(0.9)
            }
        }
    }
    struct HexagonShape: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let side = min(rect.width, rect.height) / 2
            let center = CGPoint(x: rect.midX, y: rect.midY)
            
            for i in 0..<6 {
                let angle = Double(i) * 60 - 30
                let point = CGPoint(
                    x: center.x + side * Darwin.cos(angle.degreesToRadians()),
                    y: center.y + side * Darwin.sin(angle.degreesToRadians())
                )
                
                if i == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
            path.closeSubpath()
            return path
        }
    }
}
