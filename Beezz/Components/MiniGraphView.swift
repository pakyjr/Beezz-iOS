//
//  MiniGraphView.swift
//  Beezz
//
//  Created by Antonio Navarra on 06/03/25.
//


//
//  MiniGraphView.swift
//  Beezz
//
//  Created on 06/03/25.
//

import SwiftUI

struct MiniGraphView: View {
    let values: [Double]
    let color: Color
    let accentColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Graph background area
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let stepX = width / CGFloat(values.count - 1)
                    
                    let startPoint = CGPoint(x: 0, y: height * (1 - CGFloat(values[0])))
                    path.move(to: CGPoint(x: 0, y: height))
                    path.addLine(to: startPoint)
                    
                    for index in 1..<values.count {
                        let point = CGPoint(
                            x: stepX * CGFloat(index),
                            y: height * (1 - CGFloat(values[index]))
                        )
                        path.addLine(to: point)
                    }
                    
                    path.addLine(to: CGPoint(x: width, y: height))
                    path.closeSubpath()
                }
                .fill(color.opacity(0.1))
                
                // Main graph line
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let stepX = width / CGFloat(values.count - 1)
                    
                    let startPoint = CGPoint(x: 0, y: height * (1 - CGFloat(values[0])))
                    path.move(to: startPoint)
                    
                    for index in 1..<values.count {
                        let point = CGPoint(
                            x: stepX * CGFloat(index),
                            y: height * (1 - CGFloat(values[index]))
                        )
                        path.addLine(to: point)
                    }
                }
                .stroke(color, lineWidth: 2)
                
                // Data points as small hexagons
                ForEach(0..<values.count, id: \.self) { index in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let stepX = width / CGFloat(values.count - 1)
                    let x = stepX * CGFloat(index)
                    let y = height * (1 - CGFloat(values[index]))
                    
                    Image(systemName: "hexagon.fill")
                        .font(.system(size: 8))
                        .foregroundColor(accentColor)
                        .position(x: x, y: y)
                }
            }
        }
    }
}