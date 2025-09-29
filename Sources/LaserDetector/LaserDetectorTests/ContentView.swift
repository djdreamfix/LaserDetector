import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var detector = LaserDetector()
    @State private var isRunning = true
    @State private var detectedDuration: TimeInterval = 0
    @State private var laserColor: LaserColor = .red
    @State private var sensitivity: Double = 92
    @State private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            CameraView(session: detector.session)
                .ignoresSafeArea()
                .opacity(isRunning ? 1 : 0.25)
            
            VStack(spacing: 16) {
                Text(detector.isLaserDetected ? "✅ ЛАЗЕР ВИЯВЛЕНО" : "🚫 Очікування…")
                    .font(.largeTitle)
                    .foregroundColor(detector.isLaserDetected ? .green : .red)
                    .padding()
                    .scaleEffect(detector.isLaserDetected ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.4), value: detector.isLaserDetected)
                
                HStack(spacing: 20) {
                    Button(isRunning ? "Стоп" : "Старт") {
                        isRunning.toggle()
                        if isRunning { detector.start(color: laserColor, sensitivity: sensitivity) }
                        else { detector.stop() }
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(12)
                    
                    Button("Скинути") {
                        detector.resetPeaks()
                        detectedDuration = 0
                    }
                    .padding()
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(12)
                }
                
                VStack {
                    Text("Колір лазера")
                    Picker("", selection: $laserColor) {
                        Text("🔴 Червоний").tag(LaserColor.red)
                        Text("🟢 Зелений").tag(LaserColor.green)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Text("Чутливість: \(Int(sensitivity))%")
                    Slider(value: $sensitivity, in: 50...100, step: 1) { _ in
                        detector.updateSensitivity(color: laserColor, sensitivity: sensitivity)
                    }
                }
                .padding()
            }
        }
        .onAppear { detector.start(color: laserColor, sensitivity: sensitivity) }
        .onReceive(timer) { _ in
            if isRunning && detector.isLaserDetected { detectedDuration += 0.1 }
        }
    }
}

enum LaserColor: String, CaseIterable, Identifiable {
    case red, green
    var id: String { rawValue }
}