//
//  AddBeehiveCardView.swift
//  Beezz
//
//  Created on 06/03/25.
//

import SwiftUI

struct AddBeehiveCardView: View {
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color(UIColor.tertiarySystemBackground))
                    .frame(width: 60, height: 60)
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color.honeyAmber)
            }
            
            Spacer()
            
            Text("Add New")
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundColor(Color.primary)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("Add a Hive")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .frame(height: 180)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                )
        )
    }
}

struct AddBeehiveCardView_Previews: PreviewProvider {
    static var previews: some View {
        AddBeehiveCardView()
            .previewLayout(.sizeThatFits)
            .frame(width: 180)
            .padding()
    }
}
