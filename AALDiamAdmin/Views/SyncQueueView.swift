import SwiftUI

public struct SyncQueueView: View {
    @ObservedObject var localDb: LocalVaultDatabase
    @State private var isSyncing: Bool = false

    private let apiClient = AALDiamAPIClient.shared

    private var pendingCount: Int {
        localDb.drafts.count { $0.syncStatus != "SYNCED" }
    }

    public var body: some View {
        ZStack {
            Color.obsidianBlack.ignoresSafeArea()

            VStack(spacing: 16) {
                // Header
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.headline)
                            .foregroundColor(.goldPrimary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("OFFLINE SYNC QUEUE")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.goldPrimary)
                            Text("Automatic background synchronization")
                                .font(.caption2)
                                .foregroundColor(.textMuted)
                        }
                    }
                    Spacer()
                    Button(action: syncAll) {
                        if isSyncing {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .obsidianBlack))
                                .frame(height: 32)
                                .padding(.horizontal, 14)
                                .background(Color.goldPrimary)
                                .cornerRadius(8)
                        } else {
                            HStack(spacing: 4) {
                                Image(systemName: "icloud.and.arrow.up")
                                Text("Sync All")
                            }
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(pendingCount > 0 ? .obsidianBlack : .textDim)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(pendingCount > 0 ? Color.goldPrimary : Color.surfaceDark)
                            .cornerRadius(8)
                        }
                    }
                    .disabled(isSyncing || pendingCount == 0)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Stats Card
                HStack {
                    metric(label: "Total Ingested", value: "\(localDb.drafts.count)", color: .textWhite)
                    Divider().frame(height: 30).background(Color.borderDark)
                    metric(label: "Pending Sync", value: "\(pendingCount)", color: .statusReserved)
                    Divider().frame(height: 30).background(Color.borderDark)
                    metric(label: "Vault Synced", value: "\(localDb.drafts.count { $0.syncStatus == "SYNCED" })", color: .statusAvailable)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color.cardDark)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.borderDark, lineWidth: 1))
                .padding(.horizontal, 16)

                // Drafts List
                if localDb.drafts.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "icloud.slash")
                            .font(.system(size: 44))
                            .foregroundColor(.textDim)
                        Text("All Drafts Up-to-Date")
                            .font(.headline)
                            .foregroundColor(.textWhite)
                        Text("Any diamonds drafted without internet connection will queue here automatically.")
                            .font(.caption)
                            .foregroundColor(.textDim)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(localDb.drafts) { d in
                                draftRow(d)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 80)
                    }
                }
            }
        }
    }

    private func metric(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(.textDim)
        }
        .frame(maxWidth: .infinity)
    }

    private func draftRow(_ draft: DiamondDraft) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Text(draft.stockNumber)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.textWhite)

                    Text(draft.syncStatus)
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(statusColor(draft.syncStatus).opacity(0.15))
                        .foregroundColor(statusColor(draft.syncStatus))
                        .cornerRadius(4)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(statusColor(draft.syncStatus).opacity(0.5), lineWidth: 1))
                }

                Text("\(String(format: "%.2f", draft.carat)) Ct \(draft.shape) • \(draft.color)/\(draft.clarity) • ₹ \(Int(draft.price))")
                    .font(.caption)
                    .foregroundColor(.textMuted)

                if let err = draft.errorMessage, draft.syncStatus == "FAILED" {
                    Text(err)
                        .font(.caption2)
                        .foregroundColor(.statusFailed)
                }
            }
            Spacer()

            Button(action: { localDb.deleteDraft(stockNumber: draft.stockNumber) }) {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundColor(.textDim)
                    .frame(width: 32, height: 32)
                    .background(Color.surfaceDark)
                    .clipShape(Circle())
            }
        }
        .padding(12)
        .background(Color.cardDark)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.borderDark, lineWidth: 1))
    }

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "SYNCED": return .statusAvailable
        case "PENDING": return .statusReserved
        case "FAILED": return .statusFailed
        default: return .textMuted
        }
    }

    private func syncAll() {
        isSyncing = true
        let pending = localDb.drafts.filter { $0.syncStatus != "SYNCED" }

        Task {
            if let success = try? await apiClient.syncDiamondsBatch(drafts: pending), success {
                DispatchQueue.main.async {
                    for d in pending {
                        localDb.markDraftSynced(stockNumber: d.stockNumber)
                    }
                    self.isSyncing = false
                }
            } else {
                DispatchQueue.main.async {
                    self.isSyncing = false
                }
            }
        }
    }
}
