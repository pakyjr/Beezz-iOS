//
//  ContentView.swift
//  Beezzz
//
//  Created by Antonio Navarra on 05/03/25.
//

import SwiftUI
import AVFoundation

struct SoundAnalysisView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isAnalyzing = false
    @State private var analysisResult: AnalysisResult?
    @State private var progress: CGFloat = 1.0
    @State private var audioRecorder = AudioRecorder()
    @State private var timer: Timer?
    @State private var waveformData: [CGFloat] = []
    @State private var frequencyData: [CGFloat] = []
    
    // Colori tema
    let honeycombYellow = Color(red: 0.98, green: 0.8, blue: 0.0)
    let honeyAmber = Color(red: 0.85, green: 0.6, blue: 0.0)
    let beeBlack = Color(red: 0.15, green: 0.15, blue: 0.15)

    var body: some View {
        ZStack {
            // Sfondo gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(UIColor.systemGroupedBackground),
                    Color(UIColor.secondarySystemGroupedBackground)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(honeyAmber)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(honeyAmber.opacity(0.1))
                            )
                    }
                    
                    Spacer()
                    
                    Text("Analisi Sonora")
                        .font(.title2)
                        .bold()
                        .foregroundColor(beeBlack)
                    
                    Spacer()
                    
                    Image(systemName: "hexagon")
                        .foregroundColor(honeyAmber)
                        .font(.title3)
                }
                .padding(.horizontal)
                
                // Contenuto principale
                VStack(spacing: 25) {
                    if isAnalyzing {
                        VStack(spacing: 15) {
                            // Visualizzazione dati
                            WaveformView(data: waveformData)
                                .frame(height: 150)
                                .padding(.horizontal)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(honeyAmber.opacity(0.3), lineWidth: 1)
                                        .background(Color(.systemBackground))
                                )
                            
                            FrequencySpectrumView(data: frequencyData)
                                .frame(height: 100)
                                .padding(.horizontal)
                            
                            ProgressBar(progress: progress)
                                .frame(height: 8)
                                .padding(.horizontal, 40)
                        }
                        .transition(.opacity)
                    }
                    
                    // Risultati
                    if let result = analysisResult {
                        AnalysisResultView(resultType: result.resultType) {
                            resetAnalysis()
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                    }
                }
                
                Spacer()
                
                // Pulsante controllo
                if analysisResult == nil {
                    AnalysisControlButton(
                        isAnalyzing: $isAnalyzing,
                        startAction: startAnalysis,
                        stopAction: stopAnalysis
                    )
                    .shadow(color: honeyAmber.opacity(isAnalyzing ? 0.3 : 0), radius: 15, y: 10)
                }
            }
            .padding()
        }
        .onAppear(perform: setupAudio)
        .onDisappear(perform: stopAnalysis)
    }

    // MARK: - Funzioni
    private func setupAudio() {
        AVAudioApplication.requestRecordPermission { granted in
            if !granted { print("Autorizzazione microfono negata") }
        }
    }
    
    private func startAnalysis() {
        withAnimation(.easeInOut) {
            isAnalyzing = true
            analysisResult = nil
            progress = 1.0
        }
        
        audioRecorder.startRecording { buffer in
            updateWaveform(buffer: buffer)
            updateFrequencyData(buffer: buffer)
        }
        
        startTimer()
    }
    
    private func stopAnalysis() {
        withAnimation(.spring()) {
            isAnalyzing = false
            audioRecorder.stopRecording()
            timer?.invalidate()
            
            // Simulazione risultato
            let randomResult = Int.random(in: 0...2)
            analysisResult = AnalysisResult(
                resultType: AnalysisResultType.allCases[randomResult],
                timestamp: Date(),
                hiveId: nil
            )
        }
    }
    
    private func resetAnalysis() {
        withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7)) {
            analysisResult = nil
            progress = 1.0
            waveformData.removeAll()
            frequencyData.removeAll()
        }
    }
    
    private func startTimer() {
        let totalTime: CGFloat = 15
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation(.linear) {
                progress = max(0, progress - (0.1 / totalTime))
            }
            
            if progress <= 0 {
                stopAnalysis()
            }
        }
    }
    
    // Mock data functions
    private func updateWaveform(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData else { return }
        let frames = Int(buffer.frameLength)
        waveformData = (0..<frames).map { CGFloat(channelData[0][$0]) }.suffix(100)
    }
    
    private func updateFrequencyData(buffer: AVAudioPCMBuffer) {
        frequencyData = (0..<10).map { _ in CGFloat.random(in: 0...1) }
    }
}

// MARK: - Componenti UI
struct ProgressBar: View {
    var progress: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .foregroundColor(Color(.systemGray5))
                
                Capsule()
                    .frame(width: min(progress * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 0.98, green: 0.8, blue: 0.0), Color(red: 0.85, green: 0.6, blue: 0.0)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
        }
        .overlay(
            Capsule()
                .stroke(Color(red: 0.85, green: 0.6, blue: 0.0).opacity(0.3), lineWidth: 1)
        )
    }
}

struct WaveformView: View {
    let data: [CGFloat]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Linea centrale
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geometry.size.height/2))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height/2))
                }
                .stroke(Color(red: 0.85, green: 0.6, blue: 0.0).opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [5]))
                
                // Onda sonora
                Path { path in
                    let step = geometry.size.width / CGFloat(data.count)
                    for (i, value) in data.enumerated() {
                        let x = step * CGFloat(i)
                        let y = geometry.size.height/2 + (value * geometry.size.height/2)
                        
                        if i == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(
                    LinearGradient(
                        colors: [Color(red: 0.98, green: 0.8, blue: 0.0), Color(red: 0.85, green: 0.6, blue: 0.0)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                )
            }
        }
    }
}

struct FrequencySpectrumView: View {
    let data: [CGFloat]
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 3) {
            ForEach(data.indices, id: \.self) { index in
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(red: 0.85, green: 0.6, blue: 0.0))
                    .frame(
                        width: 10,
                        height: CGFloat(data[index]) * 60 + 20
                    )
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.1),
                        value: data[index]
                    )
            }
        }
    }
}

struct AnalysisControlButton: View {
    @Binding var isAnalyzing: Bool
    let startAction: () -> Void
    let stopAction: () -> Void
    
    var body: some View {
        Button(action: {
            isAnalyzing ? stopAction() : startAction()
        }) {
            ZStack {
                Circle()
                    .fill(isAnalyzing ? Color(red: 0.85, green: 0.6, blue: 0.0) : Color(red: 0.98, green: 0.8, blue: 0.0))
                    .frame(width: 80, height: 80)
                
                Image(systemName: isAnalyzing ? "stop.fill" : "waveform")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .symbolEffect(.bounce, options: .speed(2), value: isAnalyzing)
            }
            .overlay(
                Circle()
                    .stroke(Color(red: 0.85, green: 0.6, blue: 0.0), lineWidth: 2)
                    .blur(radius: 2)
            )
        }
    }
}

struct AnalysisResultView: View {
    let resultType: AnalysisResultType
    let onRepeat: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            VStack(spacing: 10) {
                Image(systemName: resultType.icon)
                    .font(.system(size: 45))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(resultType.color)
                    .padding(15)
                    .background(
                        Circle()
                            .fill(resultType.color.opacity(0.1))
                    )
                
                Text(resultType.title)
                    .font(.title3.bold())
                    .foregroundColor(resultType.color)
                
                Text(resultType.description)
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            
            HStack(spacing: 15) {
                Button(action: saveAnalysis) {
                    Label("Salva", systemImage: "square.and.arrow.down")
                        .font(.subheadline.bold())
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 0.85, green: 0.6, blue: 0.0).opacity(0.1))
                        .cornerRadius(10)
                }
                
                Button(action: associateToHive) {
                    Label("Associa", systemImage: "tag")
                        .font(.subheadline.bold())
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 0.85, green: 0.6, blue: 0.0).opacity(0.1))
                        .cornerRadius(10)
                }
            }
            .foregroundColor(Color(red: 0.85, green: 0.6, blue: 0.0))
            .padding(.horizontal)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: resultType.color.opacity(0.1), radius: 15, y: 5)
        )
        .padding(.horizontal)
    }
    
    private func saveAnalysis() {
        print("Analisi salvata")
    }
    
    private func associateToHive() {
        print("Associazione effettuata")
    }
}

// Resto del codice (modelli, AudioRecorder, Preview) rimane invariato come nella risposta precedente// MARK: - Data Models
struct AnalysisResult: Identifiable {
    let id = UUID()
    let resultType: AnalysisResultType
    let timestamp: Date
    var hiveId: String?
}

enum AnalysisResultType: String, CaseIterable {
    case normal, warning, critical
    
    var title: String {
        switch self {
        case .normal: return "Stato Normale 🟢"
        case .warning: return "Attività Anomala 🟡"
        case .critical: return "Minaccia rilevata 🔴"
        }
    }
    
    var description: String {
        switch self {
        case .normal: return "Non rilevate anomalie, attività regolare"
        case .warning: return "Possibile segnale di stress nella colonia"
        case .critical: return "Cambiare in base all'analisi"
        }
    }
    
    var color: Color {
        switch self {
        case .normal: return .green
        case .warning: return .yellow
        case .critical: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .normal: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .critical: return "flame.fill"
        }
    }
}

// MARK: - Audio Handler
class AudioRecorder {
    private var engine = AVAudioEngine()
    
    func startRecording(bufferHandler: @escaping (AVAudioPCMBuffer) -> Void) {
        let inputNode = engine.inputNode
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputNode.outputFormat(forBus: 0)) { buffer, _ in
            bufferHandler(buffer)
        }
        do {
            try engine.start()
        } catch {
            print("Errore registrazione: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        engine.stop()
        engine.inputNode.removeTap(onBus: 0)
    }
}


// MARK: - Preview
#Preview {
    SoundAnalysisView()
}


