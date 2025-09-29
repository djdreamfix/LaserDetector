import Foundation
import AVFoundation
import UIKit

final class LaserDetector: NSObject, ObservableObject {
    @Published var isLaserDetected: Bool = false
    
    let session = AVCaptureSession()
    private let output = AVCaptureVideoDataOutput()
    private let queue = DispatchQueue(label: "LaserDetector.CameraQueue")
    
    private var lastTriggerAt: CFTimeInterval = 0
    private let debounce: CFTimeInterval = 0.25
    private var audioPlayer: AVAudioPlayer?
    
    private var currentColor: ContentView.LaserColor = .red
    private var sensitivityThreshold: Float = 0.92
    
    override init() {
        super.init()
        configureSession()
        prepareSound()
    }
    
    func start(color: ContentView.LaserColor, sensitivity: Double) {
        currentColor = color
        sensitivityThreshold = Float(sensitivity / 100)
        if !session.isRunning { session.startRunning() }
    }
    
    func stop() { if session.isRunning { session.stopRunning(); stopSound() } }
    func resetPeaks() { }
    func updateSensitivity(color: ContentView.LaserColor, sensitivity: Double) {
        currentColor = color
        sensitivityThreshold = Float(sensitivity / 100)
    }
    
    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .high
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { return }
        session.addInput(input)
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        output.setSampleBufferDelegate(self, queue: queue)
        if session.canAddOutput(output) { session.addOutput(output) }
        session.commitConfiguration()
    }
    
    private func prepareSound() {
        if let url = Bundle.main.url(forResource: "alert", withExtension: "mp3") {
            audioPlayer = try? AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.prepareToPlay()
        }
    }
    
    private func playSound() { audioPlayer?.play() }
    private func stopSound() { audioPlayer?.stop() }
}

extension LaserDetector: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        guard let base = CVPixelBufferGetBaseAddress(pixelBuffer) else { return }
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let buffer = base.assumingMemoryBound(to: UInt8.self)
        
        var maxLuma: Float = 0
        let centerRect = CGRect(x: Int(Double(width)*0.3), y: Int(Double(height)*0.3), width: Int(Double(width)*0.4), height: Int(Double(height)*0.4))
        var centerSum: Float = 0
        var centerCount = 0
        
        for y in 0..<height {
            let row = buffer.advanced(by: y*bytesPerRow)
            for x in 0..<width {
                let px = row.advanced(by: x*4)
                let r = Float(px[2])/255, g = Float(px[1])/255, b = Float(px[0])/255
                let luma = 0.2126*r + 0.7152*g + 0.0722*b
                maxLuma = max(maxLuma, luma)
                if centerRect.contains(CGPoint(x: x, y: y)) { centerSum += luma; centerCount += 1 }
            }
        }
        let centerAvg = centerCount > 0 ? centerSum/Float(centerCount) : 0
        let score = 0.6*centerAvg + 0.4*maxLuma
        let now = CACurrentMediaTime()
        var triggered = false
        if score > sensitivityThreshold && (now - lastTriggerAt) > debounce { lastTriggerAt = now; triggered = true }
        
        DispatchQueue.main.async {
            self.isLaserDetected = triggered
            if triggered { self.playSound() } else { self.stopSound() }
        }
    }
}