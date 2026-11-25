import Foundation

public class LocalVaultDatabase: ObservableObject {
    public static let shared = LocalVaultDatabase()

    @Published public var cachedDiamonds: [Diamond] = []
    @Published public var drafts: [DiamondDraft] = []

    private let diamondsFile: URL
    private let draftsFile: URL

    public init() {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.diamondsFile = dir.appendingPathComponent("cached_diamonds.json")
        self.draftsFile = dir.appendingPathComponent("diamond_drafts.json")
        loadLocalData()
    }

    public func loadLocalData() {
        if let data = try? Data(contentsOf: diamondsFile),
           let list = try? JSONDecoder().decode([Diamond].self, from: data) {
            self.cachedDiamonds = list
        }

        if let data = try? Data(contentsOf: draftsFile),
           let list = try? JSONDecoder().decode([DiamondDraft].self, from: data) {
            self.drafts = list
        }
    }

    public func saveDiamonds(_ diamonds: [Diamond]) {
        self.cachedDiamonds = diamonds
        if let data = try? JSONEncoder().encode(diamonds) {
            try? data.write(to: diamondsFile)
        }
    }

    public func saveDraft(_ draft: DiamondDraft) {
        if let idx = drafts.firstIndex(where: { $0.stockNumber == draft.stockNumber }) {
            drafts[idx] = draft
        } else {
            drafts.insert(draft, at: 0)
        }
        persistDrafts()
    }

    public func updateCachedDiamond(originalStock: String, updated: Diamond) {
        if let idx = cachedDiamonds.firstIndex(where: { $0.stockNumber == originalStock }) {
            cachedDiamonds[idx] = updated
            saveDiamonds(cachedDiamonds)
        }
    }

    public func updateCachedStatus(stockNumber: String, status: String) {
        if let idx = cachedDiamonds.firstIndex(where: { $0.stockNumber == stockNumber }) {
            cachedDiamonds[idx].status = status
            saveDiamonds(cachedDiamonds)
        }
    }

    public func deleteCached(stockNumber: String) {
        cachedDiamonds.removeAll { $0.stockNumber == stockNumber }
        saveDiamonds(cachedDiamonds)
    }

    public func deleteDraft(stockNumber: String) {
        drafts.removeAll { $0.stockNumber == stockNumber }
        persistDrafts()
    }

    public func markDraftSynced(stockNumber: String, remoteUrl: String? = nil) {
        if let idx = drafts.firstIndex(where: { $0.stockNumber == stockNumber }) {
            drafts[idx].syncStatus = "SYNCED"
            if let remoteUrl = remoteUrl {
                drafts[idx].remoteImageUrl = remoteUrl
            }
            persistDrafts()
        }
    }

    private func persistDrafts() {
        if let data = try? JSONEncoder().encode(drafts) {
            try? data.write(to: draftsFile)
        }
    }
}
