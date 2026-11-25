import SwiftUI

public struct EditDiamondSheet: View {
    let diamond: Diamond
    var onDismiss: () -> Void
    var onSave: (_ originalStock: String, _ updated: Diamond, _ newPhotoData: Data?) -> Void

    @State private var stockNumber: String
    @State private var shape: String
    @State private var carat: String
    @State private var color: String
    @State private var clarity: String
    @State private var cut: String
    @State private var priceInr: String
    @State private var status: String
    @State private var lab: String
    @State private var certNumber: String
    @State private var measurements: String
    @State private var polish: String
    @State private var symmetry: String
    @State private var fluorescence: String

    @State private var selectedImage: UIImage? = nil
    @State private var showCamera: Bool = false
    @State private var showPhotoLibrary: Bool = false

    public init(diamond: Diamond, onDismiss: @escaping () -> Void, onSave: @escaping (String, Diamond, Data?) -> Void) {
        self.diamond = diamond
        self.onDismiss = onDismiss
        self.onSave = onSave

        _stockNumber = State(initialValue: diamond.stockNumber)
        _shape = State(initialValue: diamond.shape)
        _carat = State(initialValue: String(format: "%.2f", diamond.carat))
        _color = State(initialValue: diamond.color)
        _clarity = State(initialValue: diamond.clarity)
        _cut = State(initialValue: diamond.cut ?? "Excellent")
        _priceInr = State(initialValue: String(format: "%.0f", diamond.price))
        _status = State(initialValue: diamond.status)
        _lab = State(initialValue: diamond.certificateLab)
        _certNumber = State(initialValue: diamond.certificateNumber)
        _measurements = State(initialValue: diamond.measurements)
        _polish = State(initialValue: diamond.polish)
        _symmetry = State(initialValue: diamond.symmetry)
        _fluorescence = State(initialValue: diamond.fluorescence)
    }

    public var body: some View {
        NavigationView {
            ZStack {
                Color.obsidianBlack.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("EDIT DIAMOND DETAILS")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.goldPrimary)
                                Text("Original SKU: \(diamond.stockNumber)")
                                    .font(.caption)
                                    .foregroundColor(.textMuted)
                            }
                            Spacer()
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
                                    chipButton(title: s, isSelected: shape.caseInsensitiveCompare(s) == .orderedSame) {
                                        shape = s
                                    }
                                }
                            }
                        }

                        // 2. The 4Cs
                        sectionHeader("2. THE 4Cs SPECIFICATIONS")
                        HStack(spacing: 12) {
                            customTextField(title: "Carat Weight", text: $carat, keyboardType: .decimalPad)
                            customTextField(title: "Valuation (INR ₹)", text: $priceInr, keyboardType: .numberPad)
                        }

                        // Color
                        Text("Color Grade:")
                            .font(.caption)
                            .foregroundColor(.textMuted)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(DiamondConstants.colors, id: \.self) { c in
                                    chipButton(title: c, isSelected: color.caseInsensitiveCompare(c) == .orderedSame) {
                                        color = c
                                    }
                                }
                            }
                        }

                        // Clarity
                        Text("Clarity Grade:")
                            .font(.caption)
                            .foregroundColor(.textMuted)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(DiamondConstants.clarities, id: \.self) { cl in
                                    chipButton(title: cl, isSelected: clarity.caseInsensitiveCompare(cl) == .orderedSame) {
                                        clarity = cl
                                    }
                                }
                            }
                        }

                        // Cut
                        Text("Cut Grade:")
                            .font(.caption)
                            .foregroundColor(.textMuted)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(DiamondConstants.cuts, id: \.self) { ct in
                                    chipButton(title: ct, isSelected: cut.caseInsensitiveCompare(ct) == .orderedSame) {
                                        cut = ct
                                    }
                                }
                            }
                        }

                        // 3. Status
                        sectionHeader("3. INVENTORY STATUS")
                        HStack(spacing: 8) {
                            ForEach(DiamondConstants.statuses, id: \.self) { st in
                                let isSel = status.caseInsensitiveCompare(st) == .orderedSame
                                Button(action: { status = st }) {
                                    Text(st)
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(isSel ? Color.goldPrimary : Color.cardDark)
                                        .foregroundColor(isSel ? Color.obsidianBlack : Color.textWhite)
                                        .cornerRadius(8)
                                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.borderDark, lineWidth: 1))
                                }
                            }
                        }

                        // 4. Lab & Cert
                        sectionHeader("4. LABORATORY CERTIFICATE")
                        HStack(spacing: 8) {
                            ForEach(DiamondConstants.labs, id: \.self) { l in
                                chipButton(title: l, isSelected: lab.caseInsensitiveCompare(l) == .orderedSame) {
                                    lab = l
                                }
                            }
                        }
                        HStack(spacing: 12) {
                            customTextField(title: "Certificate #", text: $certNumber)
                            customTextField(title: "Measurements (mm)", text: $measurements)
                        }

                        // 5. Photo Replacement
                        sectionHeader("5. CERTIFICATE / PARCEL PHOTO")
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
                            } else if let urlStr = diamond.imageUrl, let url = URL(string: urlStr) {
                                AsyncImage(url: url) { phase in
                                    if let img = phase.image {
                                        img.resizable().scaledToFill().frame(height: 140).clipped().cornerRadius(10)
                                    } else {
                                        Color.surfaceDark.frame(height: 140).cornerRadius(10)
                                    }
                                }
                            }

                            HStack(spacing: 12) {
                                Button(action: { showCamera = true }) {
                                    HStack {
                                        Image(systemName: "camera")
                                        Text("Camera")
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.goldPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color.surfaceDark)
                                    .cornerRadius(8)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.goldPrimary, lineWidth: 1))
                                }

                                Button(action: { showPhotoLibrary = true }) {
                                    HStack {
                                        Image(systemName: "photo")
                                        Text("Gallery")
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.textWhite)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color.surfaceDark)
                                    .cornerRadius(8)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.borderDark, lineWidth: 1))
                                }
                            }
                        }

                        // 6. Action Buttons
                        HStack(spacing: 12) {
                            Button(action: onDismiss) {
                                Text("Cancel")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.textMuted)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.cardDark)
                                    .cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.borderDark, lineWidth: 1))
                            }

                            Button(action: saveChanges) {
                                HStack {
                                    Image(systemName: "checkmark")
                                    Text("Save All Changes")
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
                        .padding(.bottom, 30)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showCamera) {
                CameraCaptureView(selectedImage: $selectedImage, sourceType: .camera)
            }
            .sheet(isPresented: $showPhotoLibrary) {
                CameraCaptureView(selectedImage: $selectedImage, sourceType: .photoLibrary)
            }
        }
    }

    private func saveChanges() {
        var updated = diamond
        updated.stockNumber = stockNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.shape = shape
        updated.carat = Double(carat) ?? diamond.carat
        updated.color = color
        updated.clarity = clarity
        updated.cut = cut
        updated.price = Double(priceInr) ?? diamond.price
        updated.status = status
        updated.certificateLab = lab
        updated.certificateNumber = certNumber
        updated.measurements = measurements
        updated.polish = polish
        updated.symmetry = symmetry
        updated.fluorescence = fluorescence

        let photoData = selectedImage?.jpegData(compressionQuality: 0.8)
        onSave(diamond.stockNumber, updated, photoData)
        onDismiss()
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
            Text(title)
                .font(.caption2)
                .foregroundColor(.textDim)
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
