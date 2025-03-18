import SwiftUI
import AVFoundation
import Accelerate

// Enumeration per lo stato dell'arnia
enum Result: String {
    case normal = "NORMAL"
    case warning = "WARNING"
    case critical = "CRITICAL"
    
    // Colore associato allo stato
    var color: Color {
        switch self {
        case .normal: return .green
        case .warning: return .yellow
        case .critical: return .red
        }
    }
    
    // Icona associata allo stato
    var icon: String {
        switch self {
        case .normal: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .critical: return "xmark.octagon.fill"
        }
    }
    
    // Determinazione dello stato basato sulla frequenza
    static func fromFrequency(_ frequency: Double) -> Result {
        switch frequency {
        case 0..<200: return .normal  // Assumiamo che frequenze molto basse siano normali
        case 200..<500: return .normal
        case 500..<700: return .warning
        case 700...3600: return .critical
        default: return .normal
        }
    }
}


struct SoundAnalysisView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isListening = false
    @State private var soundWaves: [CGFloat] = Array(repeating: 0, count: 30)
    @State private var frequency: Double = 0
    @State private var analysisComplete = false
    @State private var showHiveSelectionSheet = false
    @State private var showNewHiveSheet = false
    
    // Audio analysis states
    @State private var audioEngine: AVAudioEngine?
    @State private var inputNode: AVAudioInputNode?
    @State private var frequencyBands: [String: Double] = [:]
    @State private var problemDetected: Bool = false
    @State private var problemDescription: String = ""
    
    // Calculate hive status based on current frequency
    var hiveStatus: Result {
        return Result.fromFrequency(frequency)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient using the app's color scheme
                LinearGradient(
                    gradient: Gradient(colors: [Color.white.opacity(0.95), Color.gray.opacity(0.1)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Simplified text
                    Text(isListening ? "Listening..." : "Tap to analyze")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .padding(.bottom, 40)
                    
                    // Microphone button matching the app's color scheme
                    Button(action: {
                        if isListening {
                            stopListening()
                        } else {
                            startListening()
                        }
                    }) {
                        ZStack {
                            // Outer circle
                            Circle()
                                .fill(Color.honeyAmber.opacity(0.2))
                                .frame(width: 160, height: 160)
                                .shadow(color: Color.orange.opacity(0.2), radius: 15)
                            
                            // Inner circle
                            Circle()
                                .fill(isListening ? Color.honeyAmber.opacity(0.8) : Color.honeyAmber)
                                .frame(width: 130, height: 130)
                                .shadow(radius: 5)
                            
                            // Icon
                            Image(systemName: isListening ? "stop.fill" : "mic.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                        }
                        .scaleEffect(isListening ? 0.9 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isListening)
                    }
                    
                    Spacer()
                    
                    if analysisComplete {
                        // Results panel
                        VStack(spacing: 20) {
                            // Frequency and status
                            VStack(spacing: 10) {
                                Text("\(frequency, specifier: "%.1f") Hz")
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundColor(.black)
                                
                                // Hive status
                                HStack {
                                    Image(systemName: hiveStatus.icon)
                                        .foregroundColor(hiveStatus.color)
                                    
                                    Text(hiveStatus.rawValue)
                                        .font(.system(size: 28, weight: .bold, design: .rounded))
                                        .foregroundColor(hiveStatus.color)
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(hiveStatus.color.opacity(0.2))
                                )
                            }
                            
                            // Parameter reference
                            HStack(spacing: 15) {
                                // Normal
                                statusLegendItem(status: .normal, range: "200-500 Hz")
                                
                                // Warning
                                statusLegendItem(status: .warning, range: "500-700 Hz")
                                
                                // Critical
                                statusLegendItem(status: .critical, range: "700-3600 Hz")
                            }
                            .padding(.horizontal)
                            
                            // Action buttons
                            VStack(spacing: 16) {
                                // Pair with existing hive button
                                Button(action: {
                                    showHiveSelectionSheet = true
                                }) {
                                    HStack {
                                        Image(systemName: "link")
                                            .font(.headline)
                                            .foregroundColor(.black)
                                        Text("Pair with existing hive")
                                            .font(.headline)
                                            .foregroundColor(.black)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white)
                                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                                    )
                                }
                                
                                // Create new hive button
                                Button(action: {
                                    showNewHiveSheet = true
                                }) {
                                    HStack {
                                        Image(systemName: "plus.circle")
                                            .font(.headline)
                                            .foregroundColor(.black)
                                        Text("Create new hive")
                                            .font(.headline)
                                            .foregroundColor(.black)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white)
                                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.1), radius: 10)
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 40)
            }
            .navigationTitle("Sound Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.black)
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
            .sheet(isPresented: $showHiveSelectionSheet) {
                HiveSelectionView(analysisResult: AnalysisResult(
                    frequency: frequency,
                    status: hiveStatus,
                    date: Date(),
                    bands: frequencyBands
                )) {
                    showHiveSelectionSheet = false
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .sheet(isPresented: $showNewHiveSheet) {
                NewHiveView(analysisResult: AnalysisResult(
                    frequency: frequency,
                    status: hiveStatus,
                    date: Date(),
                    bands: frequencyBands
                )) {
                    showNewHiveSheet = false
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    // Component to display status legend
    func statusLegendItem(status: Result, range: String) -> some View {
        HStack {
            Circle()
                .fill(status.color)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(status.rawValue)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text(range)
                    .font(.caption2)
                    .foregroundColor(.black.opacity(0.8))
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(status.color.opacity(0.2))
        )
    }
    
    // Audio session setup
    func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    // Reset audio session
    func resetAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }
    
    // Start sound analysis
    func startListening() {
        isListening = true
        analysisComplete = false
        
        // Initialize audio engine
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else { return }
        
        inputNode = audioEngine.inputNode
        
        // Conditional unwrap to handle nil format case
        if let format = inputNode?.inputFormat(forBus: 0) {
            // Configure audio analysis node
            let analysisFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: format.sampleRate, channels: 1, interleaved: false)
            
            // Install tap on input node to collect audio data
            inputNode?.installTap(onBus: 0, bufferSize: 1024, format: analysisFormat) { buffer, time in
                self.analyzeAudioBuffer(buffer: buffer)
            }
            
            // Start audio engine
            do {
                try audioEngine.start()
                
                // Animate sound waves
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                    if self.isListening {
                        for i in 0..<self.soundWaves.count {
                            self.soundWaves[i] = CGFloat.random(in: 5...60)
                        }
                    } else {
                        timer.invalidate()
                    }
                }
                
                // Automatically end analysis after 5 seconds
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
    
    // Analyze audio buffer to calculate frequencies
    func analyzeAudioBuffer(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        
        let format = buffer.format
        let frameCount = Int(buffer.frameLength)
        
        // Windowing data (Hann window)
        var window = [Float](repeating: 0, count: frameCount)
        vDSP_hann_window(&window, vDSP_Length(frameCount), Int32(vDSP_HANN_NORM))
        
        // Apply window to data
        var windowed = [Float](repeating: 0.0, count: frameCount)
        vDSP_vmul(channelData, 1, window, 1, &windowed, 1, vDSP_Length(frameCount))
        
        // Configure FFT
        let log2n = vDSP_Length(ceil(log2f(Float(frameCount))))
        let fftSize = Int(1 << log2n)
        
        // Create FFT setup
        let fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))
        defer {
            if fftSetup != nil {
                vDSP_destroy_fftsetup(fftSetup)
            }
        }
        
        // Prepare data for FFT
        var realInput = [Float](repeating: 0.0, count: fftSize)
        var imaginaryInput = [Float](repeating: 0.0, count: fftSize)
        
        // Copy windowed data to real input
        for i in 0..<frameCount {
            realInput[i] = windowed[i]
        }
        
        // Create structure for complex data
        var complexInput = DSPSplitComplex(realp: &realInput, imagp: &imaginaryInput)
        
        // Perform forward FFT
        vDSP_fft_zrip(fftSetup!, &complexInput, 1, log2n, FFTDirection(FFT_FORWARD))
        
        // Calculate magnitude
        var magnitudes = [Float](repeating: 0.0, count: fftSize / 2)
        vDSP_zvmags(&complexInput, 1, &magnitudes, 1, vDSP_Length(fftSize / 2))
        
        // Normalize results
        var normalizedMagnitudes = [Float](repeating: 0.0, count: fftSize / 2)
        var normalizationFactor = Float(1.0 / Float(fftSize))
        vDSP_vsmul(magnitudes, 1, &normalizationFactor, &normalizedMagnitudes, 1, vDSP_Length(fftSize / 2))
        
        // Convert to decibels
        var decibels = [Float](repeating: 0.0, count: fftSize / 2)
        for i in 0..<fftSize / 2 {
            decibels[i] = 10.0 * log10f(normalizedMagnitudes[i])
        }
        
        // Find dominant frequency
        var maxMagnitudeIndex: vDSP_Length = 0
        var maxValue: Float = 0.0
        vDSP_maxvi(decibels, 1, &maxValue, &maxMagnitudeIndex, vDSP_Length(fftSize / 2))
        
        // Calculate dominant frequency
        let sampleRate = Float(format.sampleRate)
        let dominantFrequency = Float(maxMagnitudeIndex) * sampleRate / Float(fftSize / 2)
        
        // Update dominant frequency
        DispatchQueue.main.async {
            self.frequency = Double(dominantFrequency)
        }
        
        // Analyze different frequency bands
        let bandRanges: [String: (low: Int, high: Int)] = [
            "Low (150-200 Hz)": (150, 200),
            "Medium (200-300 Hz)": (200, 300),
            "High (300-400 Hz)": (300, 400),
            "Very High (400-500 Hz)": (400, 500)
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
        
        // Update frequency band values
        DispatchQueue.main.async {
            self.frequencyBands = bandValues
        }
    }
    
    // Stop listening and complete analysis
    func stopListening() {
        isListening = false
        analysisComplete = true
        
        // Stop audio engine and remove tap
        if let audioEngine = audioEngine, let inputNode = inputNode {
            audioEngine.stop()
            inputNode.removeTap(onBus: 0)
            self.audioEngine = nil
        }
    }
}

// Struttura per memorizzare i risultati dell'analisi
struct AnalysisResult {
    let frequency: Double
    let status: Result
    let date: Date
    let bands: [String: Double]
}

// View per la selezione di un'arnia esistente
// Step 1: Create a new ConfirmationView
struct ConfirmationView: View {
    var hiveName: String
    var onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Success icon
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.green)
            
            // Confirmation message
            Text("Report Successfully Associated")
                .font(.system(size: 22, weight: .bold, design: .rounded))
            
            Text("The analysis report has been successfully associated with \"\(hiveName)\"")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            // Dismiss button
            Button(action: {
                onDismiss()
            }) {
                Text("Done")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green)
                    )
                    .padding(.horizontal)
            }
            .padding(.top)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
}

// Step 2: Modify the HiveSelectionView to use this confirmation view
struct HiveSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    var analysisResult: AnalysisResult
    var onCompletion: () -> Void
    
    // Example hive data (replace with real data)
    @State private var hives = [
        Hive(id: UUID(), name: "Hive 1", location: "Garden"),
        Hive(id: UUID(), name: "Hive 2", location: "Nord Camp"),
        Hive(id: UUID(), name: "Hive 3", location: "Sud Camp")
    ]
    
    // Add state for showing confirmation
    @State private var showingConfirmation = false
    @State private var selectedHive: Hive?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Main List View
                List {
                    ForEach(hives) { hive in
                        Button(action: {
                            // Store the selected hive and pair the analysis
                            selectedHive = hive
                            pairAnalysisWithHive(hive)
                            showingConfirmation = true
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(hive.name)
                                        .font(.headline)
                                    Text(hive.location)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .navigationTitle("Select a Hive")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Dismiss") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                
                // Overlay confirmation view when showing
                if showingConfirmation && selectedHive != nil {
                    ConfirmationView(hiveName: selectedHive!.name) {
                        onCompletion()
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
            .animation(.easeInOut, value: showingConfirmation)
        }
    }
    
    private func pairAnalysisWithHive(_ hive: Hive) {
        // Here you should implement the logic to save the analysis result
        // to the selected hive, e.g. using CoreData or another persistence system
        print("Paired result with hive: \(hive.name)")
        print("Frequency: \(analysisResult.frequency) Hz, Status: \(analysisResult.status.rawValue)")
        
        // The view will now show the confirmation instead of immediately dismissing
    }
}

// Vista per la creazione di una nuova arnia
struct NewHiveView: View {
    @Environment(\.presentationMode) var presentationMode
    var analysisResult: AnalysisResult
    var onCompletion: () -> Void
    
    @State private var hiveName: String = ""
    @State private var hiveLocation: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Hive Information")) {
                    TextField("Name", text: $hiveName)
                    TextField("Position", text: $hiveLocation)
                }
                
                Section(header: Text("Sound Analysis")) {
                    HStack {
                        Text("Frequency")
                        Spacer()
                        Text("\(analysisResult.frequency, specifier: "%.1f") Hz")
                    }
                    
                    HStack {
                        Text("State")
                        Spacer()
                        Text(analysisResult.status.rawValue)
                            .foregroundColor(analysisResult.status.color)
                    }
                    
                    HStack {
                        Text("Date")
                        Spacer()
                        Text(analysisResult.date, style: .date)
                    }
                }
                
                Button(action: {
                    createNewHive()
                }) {
                    Text("Create Hive")
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }
                .disabled(hiveName.isEmpty)
            }
            .navigationTitle("New Hive")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annulla") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func createNewHive() {
        // Qui dovresti implementare la logica per creare una nuova arnia
        // e associare il risultato dell'analisi
        let newHive = Hive(id: UUID(), name: hiveName, location: hiveLocation)
        
        print("New hive created: \(newHive.name) in \(newHive.location)")
        print("Analysis result: Frequency: \(analysisResult.frequency) Hz, State: \(analysisResult.status.rawValue)")
        
        // Chiudi la vista e torna alla vista principale
        onCompletion()
    }
}

// Modello di dati per un'arnia
struct Hive: Identifiable {
    let id: UUID
    let name: String
    let location: String
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
            
            // Preview dello stato normale
            SoundAnalysisView(
                isListening: false,
                soundWaves: Array(repeating: 5, count: 30),
                frequency: 350.0,
                analysisComplete: true,
                frequencyBands: [
                    "Low (150-200 Hz)": -45.7,
                    "Middle (200-300 Hz)": -38.2,
                    "High (300-400 Hz)": -52.9,
                    "Very high (400-500 Hz)": -60.3
                ]
            )
            .previewDisplayName("Stato Normale")
            
            // Preview dello stato warning
            SoundAnalysisView(
                isListening: false,
                soundWaves: Array(repeating: 5, count: 30),
                frequency: 620.0,
                analysisComplete: true,
                frequencyBands: [
                    "Bassa (150-200 Hz)": -45.7,
                    "Media (200-300 Hz)": -38.2,
                    "Alta (300-400 Hz)": -52.9,
                    "Molto alta (400-500 Hz)": -60.3
                ]
            )
            .previewDisplayName("Stato Warning")
            
            // Preview dello stato critico
            SoundAnalysisView(
                isListening: false,
                soundWaves: Array(repeating: 5, count: 30),
                frequency: 950.0,
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
            
            .previewDisplayName("Stato Critico ")
        }
    }
}

// Estensione per supportare l'inizializzazione con valori predefiniti nella preview
extension SoundAnalysisView {
    init(
        isListening: Bool = false,
        soundWaves: [CGFloat] = Array(repeating: 0, count: 30),
        frequency: Double = 0,
        analysisComplete: Bool = false,
        frequencyBands: [String: Double] = [:],
        problemDetected: Bool = false,
        problemDescription: String = ""
    ) {
        self._isListening = State(initialValue: isListening)
        self._soundWaves = State(initialValue: soundWaves)
        self._frequency = State(initialValue: frequency)
        
        self._analysisComplete = State(initialValue: analysisComplete)
        self._frequencyBands = State(initialValue: frequencyBands)
        self._problemDetected = State(initialValue: problemDetected)
        self._problemDescription = State(initialValue: problemDescription)
    }
}
