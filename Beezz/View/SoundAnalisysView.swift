//
//  SoundAnalysisView.swift
//  Beezz
//
//  Created on 06/03/25.
//

import SwiftUI
import AVFoundation

// Struttura di base per SoundAnalysisView
struct SoundAnalysisView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isListening = false
    @State private var soundWaves: [CGFloat] = Array(repeating: 0, count: 30)
    @State private var frequency: Double = 0
    @State private var detectedHives: [Beehive] = []
    @State private var analysisComplete = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Honey hexagon animation area
                    ZStack {
                        Circle()
                            .fill(Color.yellow.opacity(0.2))
                            .frame(width: 250, height: 250)
                        
                        Circle()
                            .strokeBorder(Color.yellow, lineWidth: 3)
                            .frame(width: 250, height: 250)
                        
                        // Sound wave visualization
                        HStack(spacing: 4) {
                            ForEach(0..<soundWaves.count, id: \.self) { index in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.yellow)
                                    .frame(width: 4, height: isListening ? soundWaves[index] : 5)
                                    .animation(.easeInOut(duration: 0.2), value: soundWaves[index])
                            }
                        }
                        .frame(height: 100)
                        
                        if analysisComplete {
                            Text("\(frequency, specifier: "%.1f") Hz")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                                .padding(.top, 120)
                        }
                    }
                    
                    // Instruction text
                    Text(isListening ? "Listening to hive sounds..." : "Tap to analyze hive sounds")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    // Action button
                    Button(action: {
                        if isListening {
                            stopListening()
                        } else {
                            startListening()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(isListening ? Color.red : Color.yellow)
                                .frame(width: 80, height: 80)
                                .shadow(radius: 5)
                            
                            Image(systemName: isListening ? "stop.fill" : "mic.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Results section
                    if analysisComplete {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Analysis Results")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView {
                                VStack(spacing: 12) {
                                    ForEach(detectedHives) { hive in
                                        HStack {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                            
                                            Text(hive.name)
                                                .font(.subheadline.bold())
                                            
                                            Spacer()
                                            
                                            Text("Match: \(Int.random(in: 85...99))%")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding()
                                        .background(Color(UIColor.secondarySystemBackground))
                                        .cornerRadius(10)
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            .frame(height: 150)
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Sound Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    // Simulate starting sound analysis
    func startListening() {
        isListening = true
        
        // Animate sound waves
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if isListening {
                for i in 0..<soundWaves.count {
                    soundWaves[i] = CGFloat.random(in: 5...60)
                }
            } else {
                timer.invalidate()
            }
        }
        
        // Simulate analysis completion after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            if isListening {
                stopListening()
            }
        }
    }
    
    // Simulate stopping sound analysis
    func stopListening() {
        isListening = false
        analysisComplete = true
        frequency = Double.random(in: 180...420)
        
        // Simulate finding similar hives
        detectedHives = [
            Beehive(id: 101, name: "Hive 7", status: .normal, soundFrequency: 240.5, site: "Mountain Field"),
            Beehive(id: 102, name: "Hive 12", status: .normal, soundFrequency: 210.8, site: "Hill Field"),
            Beehive(id: 103, name: "Hive 5", status: .normal, soundFrequency: 200.3, site: "Laboratory")
        ]
    }
}
