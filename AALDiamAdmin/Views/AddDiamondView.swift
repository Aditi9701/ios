import SwiftUI

public struct AddDiamondView: View {
    @ObservedObject var localDb: LocalVaultDatabase
    var onComplete: () -> Void

    @State private var stockNumber: String = "DIA-\(String(Int(Date().timeIntervalSince1970)).suffix(6))"
    @State private var shape: String = "Round"
    @State private var carat: String = "1.00"
    @State private var color: String = "F"
    @State private var clarity: String = "VS1"
    @State private var cut: String = "Excellent"
    @State private var priceInr: String = "150000"
    @State private var lab: String = "GIA"
    @State private var certNumber: String = ""
    @State private var measurements: String = ""

    @State private var selectedImage: UIImage? = nil
    @State private var showCamera: Bool = false
    @State private var showPhotoLibrary: Bool = false
    @State private var isPublishing: Bool = false

    private let apiClient = AALDiamAPIClient.shared

    public var body: some View {
        ZStack {
            Color.obsidianBlack.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 2) {
                        Text("DRAFT LOOSE DIAMOND")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.goldPrimary)
                        Text("Certified Ingestion • Offline-Ready")
                            .font(.caption2)
                            .foregroundColor(.textMuted)
                    }
                    .padding(.top, 8)

                    // 1. Identification & Shape
                    sectionHeader("1. IDENTIFICATION & SHAPE")
                    customTextField(title: "Stock Number / SKU", text: $stockNumber)

                    Text("Select Shape:")
                        .font(.caption)
                        .foregroundColor(.textMuted)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(DiamondConstants.shapes, id: \.self) { s in
                                chipButton(title: s, isSelected: shape == s) { shape = s }
                            }
                        }
                    }

                    // 2. The 4Cs
                    sectionHeader("2. THE 4Cs SPECIFICATIONS")
                    HStack(spacing: 12) {
                        customTextField(title: "Carat Weight", text: $carat, keyboardType: .decimalPad)
                        customTextField(title: "Price (INR ₹)", text: $priceInr, keyboardType: .numberPad)
                    }

                    Text("Color Grade:")
                        .font(.caption)
                        .foregroundColor(.textMuted)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(DiamondConstants.colors, id: \.self) { c in
                                chipButton(title: c, isSelected: color == c) { color = c }
                            }
                        }
                    }

                    Text("Clarity Grade:")
                        .font(.caption)
                        .foregroundColor(.textMuted)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(DiamondConstants.clarities, id: \.self) { cl in
                                chipButton(title: cl, isSelected: clarity == cl) { clarity = cl }
                            }
                        }
                    }

                    Text("Cut Grade:")
                        .font(.caption)
                        .foregroundColor(.textMuted)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(DiamondConstants.cuts, id: \.self) { ct in
                                chipButton(title: ct, isSelected: cut == ct) { cut = ct }
                            }
                        }
                    }

                    // 3. Laboratory Certificate
                    sectionHeader("3. LABORATORY CERTIFICATE")
                    HStack(spacing: 8) {
                        ForEach(DiamondConstants.labs, id: \.self) { l in
                            chipButton(title: l, isSelected: lab == l) { lab = l }
                        }
                    }
                    HStack(spacing: 12) {
                        customTextField(title: "Report / Cert #", text: $certNumber)
                        customTextField(title: "Measurements (mm)", text: $measurements)
                    }

                    // 4. Photo Capture
                    sectionHeader("4. CERTIFICATE & PARCEL PHOTO")
                    VStack(spacing: 10) {
                        if let img = selectedImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 160)
                                .clipped()
                                .cornerRadius(10)
                                .overlay(
                                    Button(action: { selectedImage = nil }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                            .padding(8)
                                    }, alignment: .topTrailing
                                )
                        } else {
                            HStack(spacing: 12) {
                                Button(action: { showCamera = true }) {
                                    HStack {
                                        Image(systemName: "camera")
                                        Text("Capture Camera")
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.goldPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.surfaceDark)
                                    .cornerRadius(8)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.goldPrimary, lineWidth: 1))
                                }

                                Button(action: { showPhotoLibrary = true }) {
                                    HStack {
                                        Image(systemName: "photo")
                                        Text("Photo Gallery")
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.textWhite)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.surfaceDark)
                                    .cornerRadius(8)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.borderDark, lineWidth: 1))
                                }
                            }
                        }
                    }

                    // 5. Actions
                    HStack(spacing: 12) {
                        Button(action: saveAsDraft) {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                Text("Save Draft")
                            }
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.goldPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.surfaceDark)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.goldPrimary, lineWidth: 1))
                        }

                        Button(action: publishLive) {
                            HStack {
                                if isPublishing {
                                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .obsidianBlack))
                                } else {
                                    Image(systemName: "icloud.and.arrow.up")
                                    Text("Publish Live")
                                }
                            }
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.obsidianBlack)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.goldPrimary)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 60)
                }
                .padding(.horizontal, 20)
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraCaptureView(selectedImage: $selectedImage, sourceType: .camera)
        }
        .sheet(isPresented: $showPhotoLibrary) {
            CameraCaptureView(selectedImage: $selectedImage, sourceType: .photoLibrary)
        }
    }

    private func createDraft(syncStatus: String) -> DiamondDraft {
        let caratDouble = Double(carat) ?? 1.0
        let priceDouble = Double(priceInr) ?? 0.0
        let autoMeasurements = measurements.isEmpty ? "\(String(format: "%.2f", sqrt(caratDouble / 0.00366) / 2)) mm" : measurements
        let autoCert = certNumber.isEmpty ? "\(Int.random(in: 100000000...999999999))" : certNumber

        return DiamondDraft(
            stockNumber: stockNumber.trimmingCharacters(in: .whitespacesAndNewlines),
            shape: shape,
            carat: caratDouble,
            color: color,
            clarity: clarity,
            cut: cut,
            polish: "Excellent",
            symmetry: "Excellent",
            fluorescence: "None",
            measurements: autoMeasurements,
            certificateLab: lab,
            certificateNumber: autoCert,
            price: priceDouble,
            status: "AVAILABLE",
            syncStatus: syncStatus
        )
    }

    private func saveAsDraft() {
        let draft = createDraft(syncStatus: "DRAFT")
        localDb.saveDraft(draft)
        onComplete()
    }

    private func publishLive() {
        isPublishing = true
        var draft = createDraft(syncStatus: "PENDING")
        localDb.saveDraft(draft)

        Task {
            if let img = selectedImage, let data = img.jpegData(compressionQuality: 0.8) {
                if let url = try? await apiClient.uploadImage(imageData: data, stockNumber: draft.stockNumber) {
                    draft.remoteImageUrl = url
                }
            }

            if let success = try? await apiClient.syncDiamond(draft: draft), success {
                DispatchQueue.main.async {
                    localDb.markDraftSynced(stockNumber: draft.stockNumber, remoteUrl: draft.remoteImageUrl)
                    self.isPublishing = false
                    onComplete()
                }
            } else {
                DispatchQueue.main.async {
                    self.isPublishing = false
                    onComplete()
                }
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundColor(.goldPrimary)
            .padding(.top, 4)
    }

    private func customTextField(title: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption2).foregroundColor(.textDim)
            TextField(title, text: text)
                .keyboardType(keyboardType)
                .font(.subheadline)
                .foregroundColor(.textWhite)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.surfaceDark)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.borderDark, lineWidth: 1))
        }
    }

    private func chipButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .bold : .medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(isSelected ? Color.goldPrimary : Color.surfaceDark)
                .foregroundColor(isSelected ? Color.obsidianBlack : Color.textWhite)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(isSelected ? Color.goldPrimary : Color.borderDark, lineWidth: 1))
        }
    }
}
