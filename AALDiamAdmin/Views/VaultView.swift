import SwiftUI

public struct VaultView: View {
    @ObservedObject var localDb: LocalVaultDatabase
    var onAddNewClick: () -> Void

    @State private var searchQuery: String = ""
    @State private var selectedShape: String = "All"
    @State private var isLoading: Bool = false
    @State private var editingDiamond: Diamond? = nil
    @State private var diamondToDelete: Diamond? = nil
    @State private var stats: VaultStats = VaultStats()

    private let apiClient = AALDiamAPIClient.shared

    private var filteredDiamonds: [Diamond] {
        localDb.cachedDiamonds.filter { d in
            let matchesShape = selectedShape == "All" || d.shape.caseInsensitiveCompare(selectedShape) == .orderedSame
            let matchesSearch = searchQuery.isEmpty ||
                d.stockNumber.localizedCaseInsensitiveContains(searchQuery) ||
                d.certificateNumber.localizedCaseInsensitiveContains(searchQuery)
            return matchesShape && matchesSearch
        }
    }

    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹ "
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    public var body: some View {
        ZStack {
            Color.obsidianBlack.ignoresSafeArea()

            VStack(spacing: 12) {
                // Top Header
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "diamond.fill")
                            .font(.headline)
                            .foregroundColor(.goldPrimary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("AALDIAM VAULT")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.goldPrimary)
                            Text("Certified Loose Diamonds Repository")
                                .font(.caption2)
                                .foregroundColor(.textMuted)
                        }
                    }
                    Spacer()
                    Button(action: refreshRemoteVault) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .goldPrimary))
                                .frame(width: 36, height: 36)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.subheadline)
                                .foregroundColor(.goldPrimary)
                                .frame(width: 36, height: 36)
                                .background(Color.surfaceDark)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.borderDark, lineWidth: 1))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Stats Ribbon
                HStack(spacing: 8) {
                    statCard(label: "TOTAL", count: stats.total, color: .goldPrimary)
                    statCard(label: "AVAILABLE", count: stats.available, color: .statusAvailable)
                    statCard(label: "RESERVED", count: stats.reserved, color: .statusReserved)
                    statCard(label: "SOLD", count: stats.sold, color: .statusSold)
                }
                .padding(.horizontal, 16)

                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.goldPrimary)
                    TextField("Search by Stock # or Cert #", text: $searchQuery)
                        .font(.subheadline)
                        .foregroundColor(.textWhite)
                    if !searchQuery.isEmpty {
                        Button(action: { searchQuery = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.textDim)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.surfaceDark)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.borderDark, lineWidth: 1))
                .padding(.horizontal, 16)

                // Shape Filter Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(["All"] + DiamondConstants.shapes, id: \.self) { sh in
                            let isSel = selectedShape == sh
                            Button(action: { selectedShape = sh }) {
                                Text(sh)
                                    .font(.caption)
                                    .fontWeight(isSel ? .bold : .medium)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(isSel ? Color.goldPrimary : Color.surfaceDark)
                                    .foregroundColor(isSel ? Color.obsidianBlack : Color.textWhite)
                                    .cornerRadius(8)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(isSel ? Color.goldPrimary : Color.borderDark, lineWidth: 1))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // Diamonds List
                if filteredDiamonds.isEmpty && !isLoading {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "diamond")
                            .font(.system(size: 44))
                            .foregroundColor(.textDim)
                        Text("Vault is Currently Empty")
                            .font(.headline)
                            .foregroundColor(.textWhite)
                        Text("No diamonds match your filters. Tap below to draft a stone.")
                            .font(.caption)
                            .foregroundColor(.textDim)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        Button(action: onAddNewClick) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Loose Diamond")
                            }
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.obsidianBlack)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.goldPrimary)
                            .cornerRadius(8)
                        }
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(filteredDiamonds) { d in
                                diamondCard(d)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 80)
                    }
                }
            }
        }
        .onAppear {
            updateStats()
            refreshRemoteVault()
        }
        .sheet(item: $editingDiamond) { item in
            EditDiamondSheet(diamond: item, onDismiss: { editingDiamond = nil }) { origStock, updated, photoData in
                // Optimistically update local cache
                localDb.updateCachedDiamond(originalStock: origStock, updated: updated)
                updateStats()

                Task {
                    var finalDiamond = updated
                    if let photoData = photoData {
                        if let uploaded = try? await apiClient.uploadImage(imageData: photoData, stockNumber: updated.stockNumber) {
                            finalDiamond.imageUrl = uploaded
                            localDb.updateCachedDiamond(originalStock: updated.stockNumber, updated: finalDiamond)
                        }
                    }
                    _ = try? await apiClient.updateDiamond(originalStockNumber: origStock, diamond: finalDiamond)
                    refreshRemoteVault()
                }
            }
        }
        .alert(item: $diamondToDelete) { item in
            Alert(
                title: Text("Delete Diamond?"),
                message: Text("Are you sure you want to permanently delete stock #\(item.stockNumber) from the vault database?"),
                primaryButton: .destructive(Text("Delete Permanently")) {
                    localDb.deleteCached(stockNumber: item.stockNumber)
                    updateStats()
                    Task {
                        _ = try? await apiClient.deleteDiamond(stockNumber: item.stockNumber)
                        refreshRemoteVault()
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }

    private func diamondCard(_ diamond: Diamond) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header: Stock # + Status Badge
            HStack {
                HStack(spacing: 6) {
                    Circle().fill(Color.goldPrimary).frame(width: 8, height: 8)
                    Text(diamond.stockNumber)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.textWhite)
                }
                Spacer()
                Menu {
                    Button("AVAILABLE") { updateStatus(diamond, "AVAILABLE") }
                    Button("RESERVED") { updateStatus(diamond, "RESERVED") }
                    Button("SOLD") { updateStatus(diamond, "SOLD") }
                } label: {
                    HStack(spacing: 4) {
                        Text(diamond.status.uppercased())
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(statusColor(diamond.status))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 8))
                            .foregroundColor(statusColor(diamond.status))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor(diamond.status).opacity(0.15))
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(statusColor(diamond.status).opacity(0.5), lineWidth: 1))
                }
            }

            // Body: Thumbnail + 4Cs
            HStack(spacing: 12) {
                if let urlStr = diamond.imageUrl, let url = URL(string: urlStr) {
                    AsyncImage(url: url) { phase in
                        if let img = phase.image {
                            img.resizable().scaledToFill().frame(width: 60, height: 60).clipped().cornerRadius(8)
                        } else {
                            Color.surfaceDark.frame(width: 60, height: 60).cornerRadius(8)
                        }
                    }
                } else {
                    ZStack {
                        Color.surfaceDark.frame(width: 60, height: 60).cornerRadius(8)
                        Image(systemName: "diamond.fill").foregroundColor(.goldPrimary.opacity(0.5))
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(String(format: "%.2f", diamond.carat)) Ct • \(diamond.shape)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.textWhite)
                    Text("Color: \(diamond.color) | Clarity: \(diamond.clarity) | Cut: \(diamond.cut ?? "EX")")
                        .font(.caption)
                        .foregroundColor(.textMuted)
                    Text("Lab: \(diamond.certificateLab) #\(diamond.certificateNumber)")
                        .font(.caption2)
                        .foregroundColor(.textDim)
                }
            }

            // Footer: Valuation + Edit/Delete Actions
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text("VALUATION (INR)")
                        .font(.system(size: 9))
                        .fontWeight(.semibold)
                        .foregroundColor(.textDim)
                    Text(currencyFormatter.string(from: NSNumber(value: diamond.price)) ?? "₹ 0")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.goldPrimary)
                }
                Spacer()
                HStack(spacing: 8) {
                    Button(action: { editingDiamond = diamond }) {
                        Image(systemName: "pencil")
                            .font(.caption)
                            .foregroundColor(.goldPrimary)
                            .frame(width: 32, height: 32)
                            .background(Color.surfaceDark)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.borderDark, lineWidth: 1))
                    }

                    Button(action: { diamondToDelete = diamond }) {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundColor(.statusFailed)
                            .frame(width: 32, height: 32)
                            .background(Color.surfaceDark)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.borderDark, lineWidth: 1))
                    }
                }
            }
        }
        .padding(14)
        .background(Color.cardDark)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.borderDark, lineWidth: 1))
    }

    private func statCard(label: String, count: Int, color: Color) -> some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 9))
                .fontWeight(.semibold)
                .foregroundColor(.textDim)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.surfaceDark)
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.borderDark, lineWidth: 1))
    }

    private func statusColor(_ status: String) -> Color {
        switch status.uppercased() {
        case "AVAILABLE": return .statusAvailable
        case "RESERVED": return .statusReserved
        case "SOLD": return .statusSold
        default: return .textMuted
        }
    }

    private func updateStatus(_ diamond: Diamond, _ newStatus: String) {
        localDb.updateCachedStatus(stockNumber: diamond.stockNumber, status: newStatus)
        updateStats()
        Task {
            _ = try? await apiClient.updateDiamond(originalStockNumber: diamond.stockNumber, diamond: diamond)
            refreshRemoteVault()
        }
    }

    private func updateStats() {
        let total = localDb.cachedDiamonds.count
        let avail = localDb.cachedDiamonds.count { $0.status.caseInsensitiveCompare("AVAILABLE") == .orderedSame }
        let res = localDb.cachedDiamonds.count { $0.status.caseInsensitiveCompare("RESERVED") == .orderedSame }
        let sold = localDb.cachedDiamonds.count { $0.status.caseInsensitiveCompare("SOLD") == .orderedSame }
        stats = VaultStats(total: total, available: avail, reserved: res, sold: sold)
    }

    private func refreshRemoteVault() {
        isLoading = true
        Task {
            if let result = try? await apiClient.fetchDiamonds() {
                DispatchQueue.main.async {
                    localDb.saveDiamonds(result.0)
                    self.stats = result.1
                    self.isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
}
