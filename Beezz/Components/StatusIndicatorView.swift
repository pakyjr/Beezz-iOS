//
//  StatusIndicatorView.swift
//  Beezz
//
//  Created on 06/03/25.
//

import SwiftUI

struct StatusIndicatorView: View {
    let status: BeehiveStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(status.color)
                .frame(width: 8, height: 8)
            
            Text(status.rawValue)
                .font(.caption)
                .lineLimit(1)
                .foregroundColor(.gray)
                .minimumScaleFactor(0.8)
                .truncationMode(.tail)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
