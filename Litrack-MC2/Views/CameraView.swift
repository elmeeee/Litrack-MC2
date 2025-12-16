//
//  CameraView.swift
//  Litrack-MC2
//
//  Camera View with CoreML Integration
//  Copyright © 2024 Litrack Team. All rights reserved.
//

import SwiftUI
import AVFoundation
import Vision

struct CameraView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var cameraManager = CameraManager()
    @State private var showClassification = false
    @State private var classificationResult: ClassificationResult?
    
    var body: some View {
        ZStack {
            // Camera Preview
            CameraPreviewView(session: cameraManager.session)
                .ignoresSafeArea()
            
            // Overlay UI
            VStack {
                // Top Bar
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                            )
                    }
                    
                    Spacer()
                    
                    Text("Scan Waste")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Placeholder for symmetry
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                Spacer()
                
                // Classification Result
                if let result = classificationResult {
                    ClassificationResultView(result: result)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.horizontal, 20)
                }
                
                // Capture Button
                Button {
                    cameraManager.capturePhoto { image in
                        classifyImage(image)
                    }
                } label: {
                    ZStack {
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "11998e"), Color(hex: "38ef7d")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 68, height: 68)
                        
                        if cameraManager.isProcessing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .disabled(cameraManager.isProcessing)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            cameraManager.checkPermissions()
        }
        .sheet(isPresented: $showClassification) {
            if let result = classificationResult {
                SaveClassificationView(result: result)
            }
        }
    }
    
    private func classifyImage(_ image: UIImage) {
        cameraManager.classifyImage(image) { result in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                classificationResult = result
            }
            
            // Auto-show save sheet after 1 second
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showClassification = true
            }
        }
    }
}

// MARK: - Camera Preview View
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.main.async {
            previewLayer.frame = view.bounds
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            DispatchQueue.main.async {
                previewLayer.frame = uiView.bounds
            }
        }
    }
}

// MARK: - Classification Result View
struct ClassificationResultView: View {
    let result: ClassificationResult
    
    var iconName: String {
        switch result.type {
        case "Plastic": return "drop.fill"
        case "Can": return "cylinder.fill"
        case "Glass": return "wineglass.fill"
        default: return "cube.fill"
        }
    }
    
    var iconColor: [Color] {
        switch result.type {
        case "Plastic": return [Color(hex: "667eea"), Color(hex: "764ba2")]
        case "Can": return [Color(hex: "f093fb"), Color(hex: "f5576c")]
        case "Glass": return [Color(hex: "4facfe"), Color(hex: "00f2fe")]
        default: return [Color(hex: "11998e"), Color(hex: "38ef7d")]
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: iconColor,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: iconName)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(result.type)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("\(Int(result.confidence * 100))% Confidence")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color(hex: "38ef7d"))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: iconColor.map { $0.opacity(0.5) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
        )
        .shadow(color: iconColor[0].opacity(0.4), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Save Classification View
struct SaveClassificationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    let result: ClassificationResult
    @State private var saved = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "0F2027"), Color(hex: "203A43"), Color(hex: "2C5364")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Success Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "11998e"), Color(hex: "38ef7d")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .blur(radius: 30)
                    
                    Image(systemName: saved ? "checkmark.circle.fill" : "cube.fill")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 12) {
                    Text(saved ? "Saved!" : result.type)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(saved ? "Added to your tracking history" : "\(Int(result.confidence * 100))% Confidence")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    if !saved {
                        Button {
                            saveClassification()
                        } label: {
                            Text("Save to History")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: "11998e"), Color(hex: "38ef7d")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                        }
                    }
                    
                    Button {
                        dismiss()
                    } label: {
                        Text(saved ? "Done" : "Cancel")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            )
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func saveClassification() {
        let entry = WasteEntry(context: viewContext)
        entry.id = UUID()
        entry.type = result.type
        entry.confidence = result.confidence
        entry.timestamp = Date()
        
        do {
            try viewContext.save()
            withAnimation {
                saved = true
            }
            
            // Auto-dismiss after saving
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        } catch {
            print("Failed to save: \(error.localizedDescription)")
        }
    }
}

// MARK: - Classification Result Model
struct ClassificationResult {
    let type: String
    let confidence: Double
    let image: UIImage?
}

// MARK: - Camera Manager
@MainActor
class CameraManager: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var isProcessing = false
    @Published var permissionGranted = false
    
    private var photoOutput = AVCapturePhotoOutput()
    private var captureCompletion: ((UIImage) -> Void)?
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionGranted = true
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.permissionGranted = granted
                    if granted {
                        self?.setupCamera()
                    }
                }
            }
        default:
            permissionGranted = false
        }
    }
    
    private func setupCamera() {
        session.beginConfiguration()
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            session.commitConfiguration()
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        
        session.commitConfiguration()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }
    
    func capturePhoto(completion: @escaping (UIImage) -> Void) {
        captureCompletion = completion
        isProcessing = true
        
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func classifyImage(_ image: UIImage, completion: @escaping (ClassificationResult) -> Void) {
        // Simulate ML classification (replace with actual CoreML model)
        DispatchQueue.global(qos: .userInitiated).async {
            // Simulate processing delay
            Thread.sleep(forTimeInterval: 0.5)
            
            let types = ["Plastic", "Can", "Glass"]
            let randomType = types.randomElement() ?? "Plastic"
            let confidence = Double.random(in: 0.85...0.98)
            
            let result = ClassificationResult(
                type: randomType,
                confidence: confidence,
                image: image
            )
            
            DispatchQueue.main.async {
                self.isProcessing = false
                completion(result)
            }
        }
    }
}

// MARK: - Photo Capture Delegate
extension CameraManager: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            return
        }
        
        Task { @MainActor in
            captureCompletion?(image)
        }
    }
}

#Preview {
    CameraView()
        .environment(\.managedObjectContext, DataController.shared.container.viewContext)
}
