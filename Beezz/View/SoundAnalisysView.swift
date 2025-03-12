//
//  SoundAnalysisView.swift
//  Beezz
//
//  Created on 06/03/25.
//

import SwiftUI
import AVFoundation
import Accelerate

struct SoundAnalysisView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isListening = false
    @State private var soundWaves: [CGFloat] = Array(repeating: 0, count: 30)
    @State private var frequency: Double = 0
    @State private var detectedHives: [Beehive] = []
    @State private var analysisComplete = false
    
    // Stati per l'analisi audio
    @State private var audioEngine: AVAudioEngine?
    @State private var analysisNode: AVAudioNode?
    @State private var inputNode: AVAudioInputNode?
    @State private var frequencyBands: [String: Double] = [:]
    @State private var problemDetected: Bool = false
    @State private var problemDescription: String = ""
    
    // Definizione delle bande di frequenza e problemi correlati
    let frequencyProblems: [(range: ClosedRange<Double>, problem: String)] = [
        (150...200, "Possibile regina assente"),
        (250...300, "Possibile infestazione di varroa"),
        (300...350, "Possibile sciamatura imminente"),
        (350...450, "Possibile stress nella colonia")
    ]
    
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
                                    // Mostra i risultati delle bande di frequenza
                                    ForEach(Array(frequencyBands.keys.sorted()), id: \.self) { band in
                                        HStack {
                                            Text(band)
                                                .font(.subheadline.bold())
                                            
                                            Spacer()
                                            
                                            Text("\(frequencyBands[band]!, specifier: "%.1f") dB")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding()
                                        .background(Color(UIColor.secondarySystemBackground))
                                        .cornerRadius(10)
                                        .padding(.horizontal)
                                    }
                                    
                                    // Mostra eventuali problemi rilevati
                                    if problemDetected {
                                        HStack {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .foregroundColor(.orange)
                                            
                                            Text(problemDescription)
                                                .font(.subheadline.bold())
                                                .foregroundColor(.orange)
                                            
                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color(UIColor.secondarySystemBackground))
                                        .cornerRadius(10)
                                        .padding(.horizontal)
                                    }
                                    
                                    // Arnie simili
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
                            .frame(height: 200)
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
            .onAppear {
                setupAudioSession()
            }
            .onDisappear {
                if isListening {
                    stopListening()
                }
                resetAudioSession()
            }
        }
    }
    
    // Configurazione della sessione audio
    func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    // Reset della sessione audio
    func resetAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }
    
    // Avvia l'analisi del suono
    func startListening() {
        isListening = true
        analysisComplete = false
        
        // Inizializza l'audio engine
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else { return }
        
        inputNode = audioEngine.inputNode
        
        // Usa l'unwrap condizionale per gestire il caso in cui il formato sia nil
        if let format = inputNode?.inputFormat(forBus: 0) {
            // Configura il nodo di analisi audio
            let analysisFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: format.sampleRate, channels: 1, interleaved: false)
            
            // Installa un tap sull'input node per raccogliere i dati audio
            inputNode?.installTap(onBus: 0, bufferSize: 1024, format: analysisFormat) { buffer, time in
                self.analyzeAudioBuffer(buffer: buffer)
            }
            
            // Avvia l'audio engine
            do {
                try audioEngine.start()
                
                // Anima le onde sonore
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                    if self.isListening {
                        for i in 0..<self.soundWaves.count {
                            self.soundWaves[i] = CGFloat.random(in: 5...60)
                        }
                    } else {
                        timer.invalidate()
                    }
                }
                
                // Termina automaticamente l'analisi dopo 5 secondi
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    if self.isListening {
                        self.stopListening()
                    }
                }
                
            } catch {
                print("Failed to start audio engine: \(error.localizedDescription)")
                isListening = false
            }
        } else {
            print("Failed to get input format")
            isListening = false
        }
    }
    
    // Analizza il buffer audio per calcolare le frequenze
    func analyzeAudioBuffer(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0]else { return }
        
              let format = buffer.format
        
        let frameCount = Int(buffer.frameLength)
        
        // Windowing dei dati (Hann window)
        var window = [Float](repeating: 0, count: frameCount)
        vDSP_hann_window(&window, vDSP_Length(frameCount), Int32(vDSP_HANN_NORM))
        
        // Applica la finestra ai dati
        var windowed = [Float](repeating: 0.0, count: frameCount)
        vDSP_vmul(channelData, 1, window, 1, &windowed, 1, vDSP_Length(frameCount))
        
        // Configura FFT
        let log2n = vDSP_Length(ceil(log2f(Float(frameCount))))
        let fftSize = Int(1 << log2n)
        
        // Crea un setup FFT
        let fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))
        defer {
            if fftSetup != nil {
                vDSP_destroy_fftsetup(fftSetup)
            }
        }
        
        // Prepara i dati per la FFT
        var realInput = [Float](repeating: 0.0, count: fftSize)
        var imaginaryInput = [Float](repeating: 0.0, count: fftSize)
        
        // Copia i dati windowed nell'input reale
        for i in 0..<frameCount {
            realInput[i] = windowed[i]
        }
        
        // Crea la struttura per i dati complessi
        var complexInput = DSPSplitComplex(realp: &realInput, imagp: &imaginaryInput)
        
        // CORREZIONE 2: Passa un puntatore valido invece di nil
        var dummy: Float = 0.0
        // Esegui la FFT forward
        vDSP_fft_zrip(fftSetup!, &complexInput, 1, log2n, FFTDirection(FFT_FORWARD))
        
        // Calcola la magnitudo
        var magnitudes = [Float](repeating: 0.0, count: fftSize / 2)
        vDSP_zvmags(&complexInput, 1, &magnitudes, 1, vDSP_Length(fftSize / 2))
        
        // Normalizza i risultati
        var normalizedMagnitudes = [Float](repeating: 0.0, count: fftSize / 2)
        var normalizationFactor = Float(1.0 / Float(fftSize))
        vDSP_vsmul(magnitudes, 1, &normalizationFactor, &normalizedMagnitudes, 1, vDSP_Length(fftSize / 2))
        
        // Converti in decibel
        var decibels = [Float](repeating: 0.0, count: fftSize / 2)
        for i in 0..<fftSize / 2 {
            decibels[i] = 10.0 * log10f(normalizedMagnitudes[i])
        }
        
        // Trova frequenza dominante
        var maxMagnitudeIndex: vDSP_Length = 0
        // CORREZIONE 2: Passa un puntatore valido invece di nil
        var maxValue: Float = 0.0
        vDSP_maxvi(decibels, 1, &maxValue, &maxMagnitudeIndex, vDSP_Length(fftSize / 2))
        
        // Calcola la frequenza dominante
        let sampleRate = Float(format.sampleRate)
        let dominantFrequency = Float(maxMagnitudeIndex) * sampleRate / Float(fftSize / 2)

        
        // Aggiorna la frequenza dominante
        DispatchQueue.main.async {
            self.frequency = Double(dominantFrequency)
        }
        
        // Analizza diverse bande di frequenza
        let bandRanges: [String: (low: Int, high: Int)] = [
            "Bassa (150-200 Hz)": (150, 200),
            "Media (200-300 Hz)": (200, 300),
            "Alta (300-400 Hz)": (300, 400),
            "Molto alta (400-500 Hz)": (400, 500)
        ]
        
        var bandValues = [String: Double]()
        
        for (band, range) in bandRanges {
            let lowIndex = Int(Float(range.low) / sampleRate * Float(fftSize))
            let highIndex = min(Int(Float(range.high) / sampleRate * Float(fftSize)), decibels.count - 1)
            
            if lowIndex < highIndex && lowIndex >= 0 && highIndex < decibels.count {
                var sum: Float = 0
                for i in lowIndex...highIndex {
                    sum += decibels[i]
                }
                let average = Double(sum / Float(highIndex - lowIndex + 1))
                bandValues[band] = average
            }
        }
        
        // Aggiorna i valori delle bande di frequenza
        DispatchQueue.main.async {
            self.frequencyBands = bandValues
        }
    }
    
    // Ferma l'ascolto e completa l'analisi
    func stopListening() {
        isListening = false
        analysisComplete = true
        
        // Ferma l'audio engine e rimuovi il tap
        if let audioEngine = audioEngine, let inputNode = inputNode {
            audioEngine.stop()
            inputNode.removeTap(onBus: 0)
            self.audioEngine = nil
        }
        
        // Analizza i risultati per rilevare eventuali problemi
        analyzeResults()
        
       
    }
    
    // Analizza i risultati per identificare potenziali problemi nell'arnia
    func analyzeResults() {
        problemDetected = false
        
        // Controlla se la frequenza dominante indica un problema
        for (range, problem) in frequencyProblems {
            if range.contains(frequency) {
                problemDetected = true
                problemDescription = problem
                break
            }
        }
        
        // Verifica anche i livelli delle bande di frequenza
        if !problemDetected {
            // Esempi di criteri per identificare problemi basati sulle bande
            if let bassLevel = frequencyBands["Bassa (150-200 Hz)"],
               let midLevel = frequencyBands["Media (200-300 Hz)"] {
                if bassLevel > -30 && midLevel < -50 {
                    problemDetected = true
                    problemDescription = "Possibile problema di ventilazione nell'arnia"
                }
            }
            
            if let highLevel = frequencyBands["Alta (300-400 Hz)"] {
                if highLevel > -35 {
                    problemDetected = true
                    problemDescription = "Possibile agitazione nella colonia"
                }
            }
        }
    }
}

struct SoundAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Preview dello stato iniziale
            SoundAnalysisView()
                .previewDisplayName("Initial State")
            
            // Preview dello stato di ascolto
            SoundAnalysisView(
                isListening: true,
                soundWaves: (0..<30).map { _ in CGFloat.random(in: 5...60) }
            )
            .previewDisplayName("Listening State")
            
            // Preview dello stato dopo l'analisi
            SoundAnalysisView(
                isListening: false,
                soundWaves: Array(repeating: 5, count: 30),
                frequency: 215.7,
                detectedHives: [
                    Beehive(id: 101, name: "Hive 7", status: .normal, soundFrequency: 240.5, site: "Mountain Field"),
                    Beehive(id: 102, name: "Hive 12", status: .normal, soundFrequency: 210.8, site: "Hill Field"),
                    Beehive(id: 103, name: "Hive 5", status: .normal, soundFrequency: 200.3, site: "Laboratory")
                ],
                analysisComplete: true,
                frequencyBands: [
                    "Bassa (150-200 Hz)": -45.7,
                    "Media (200-300 Hz)": -38.2,
                    "Alta (300-400 Hz)": -52.9,
                    "Molto alta (400-500 Hz)": -60.3
                ]
            )
            .previewDisplayName("Analysis Complete")
            
            // Preview in dark mode
            SoundAnalysisView(
                frequency: 305.2,
                detectedHives: [
                    Beehive(id: 101, name: "Hive 7", status: .normal, soundFrequency: 240.5, site: "Mountain Field")
                ],
                analysisComplete: true,
                frequencyBands: [
                    "Bassa (150-200 Hz)": -42.3,
                    "Media (200-300 Hz)": -35.9,
                    "Alta (300-400 Hz)": -29.8,
                    "Molto alta (400-500 Hz)": -58.1
                ],
                problemDetected: true,
                problemDescription: "Possibile sciamatura imminente"
            )
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}

// Estensione per supportare l'inizializzazione con valori predefiniti nella preview
extension SoundAnalysisView {
    init(
        isListening: Bool = false,
        soundWaves: [CGFloat] = Array(repeating: 0, count: 30),
        frequency: Double = 0,
        detectedHives: [Beehive] = [],
        analysisComplete: Bool = false,
        frequencyBands: [String: Double] = [:],
        problemDetected: Bool = false,
        problemDescription: String = ""
    ) {
        self._isListening = State(initialValue: isListening)
        self._soundWaves = State(initialValue: soundWaves)
        self._frequency = State(initialValue: frequency)
        self._detectedHives = State(initialValue: detectedHives)
        self._analysisComplete = State(initialValue: analysisComplete)
        self._frequencyBands = State(initialValue: frequencyBands)
        self._problemDetected = State(initialValue: problemDetected)
        self._problemDescription = State(initialValue: problemDescription)
    }
}
