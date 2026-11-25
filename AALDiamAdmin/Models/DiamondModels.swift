import Foundation

// MARK: - Core Diamond Model
public struct Diamond: Identifiable, Codable, Equatable, Hashable {
    public var id: String
    public var stockNumber: String
    public var shape: String
    public var carat: Double
    public var color: String
    public var clarity: String
    public var cut: String?
    public var polish: String
    public var symmetry: String
    public var fluorescence: String
    public var measurements: String
    public var certificateLab: String
    public var certificateNumber: String
    public var price: Double // In INR ₹
    public var status: String // AVAILABLE, RESERVED, SOLD
    public var imageUrl: String?
    public var videoUrl: String?
    public var createdAt: String?

    public init(
        id: String = UUID().uuidString,
        stockNumber: String = "",
        shape: String = "Round",
        carat: Double = 1.0,
        color: String = "F",
        clarity: String = "VS1",
        cut: String? = "Excellent",
        polish: String = "Excellent",
        symmetry: String = "Excellent",
        fluorescence: String = "None",
        measurements: String = "",
        certificateLab: String = "GIA",
        certificateNumber: String = "",
        price: Double = 0.0,
        status: String = "AVAILABLE",
        imageUrl: String? = null,
        videoUrl: String? = null,
        createdAt: String? = nil
    ) {
        self.id = id
        self.stockNumber = stockNumber
        self.shape = shape
        self.carat = carat
        self.color = color
        self.clarity = clarity
        self.cut = cut
        self.polish = polish
        self.symmetry = symmetry
        self.fluorescence = fluorescence
        self.measurements = measurements
        self.certificateLab = certificateLab
        self.certificateNumber = certificateNumber
        self.price = price
        self.status = status
        self.imageUrl = imageUrl
        self.videoUrl = videoUrl
        self.createdAt = createdAt
    }
}

// MARK: - Local Offline Draft Model
public struct DiamondDraft: Identifiable, Codable, Equatable {
    public var id: String
    public var stockNumber: String
    public var shape: String
    public var carat: Double
    public var color: String
    public var clarity: String
    public var cut: String
    public var polish: String
    public var symmetry: String
    public var fluorescence: String
    public var measurements: String
    public var certificateLab: String
    public var certificateNumber: String
    public var price: Double
    public var status: String
    public var localImagePath: String?
    public var remoteImageUrl: String?
    public var syncStatus: String // DRAFT, PENDING, SYNCED, FAILED
    public var errorMessage: String?
    public var updatedAt: Date

    public init(
        id: String = UUID().uuidString,
        stockNumber: String = "",
        shape: String = "Round",
        carat: Double = 1.0,
        color: String = "F",
        clarity: String = "VS1",
        cut: String = "Excellent",
        polish: String = "Excellent",
        symmetry: String = "Excellent",
        fluorescence: String = "None",
        measurements: String = "",
        certificateLab: String = "GIA",
        certificateNumber: String = "",
        price: Double = 0.0,
        status: String = "AVAILABLE",
        localImagePath: String? = nil,
        remoteImageUrl: String? = nil,
        syncStatus: String = "DRAFT",
        errorMessage: String? = nil,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.stockNumber = stockNumber
        self.shape = shape
        self.carat = carat
        self.color = color
        self.clarity = clarity
        self.cut = cut
        self.polish = polish
        self.symmetry = symmetry
        self.fluorescence = fluorescence
        self.measurements = measurements
        self.certificateLab = certificateLab
        self.certificateNumber = certificateNumber
        self.price = price
        self.status = status
        self.localImagePath = localImagePath
        self.remoteImageUrl = remoteImageUrl
        self.syncStatus = syncStatus
        self.errorMessage = errorMessage
        self.updatedAt = updatedAt
    }
}

// MARK: - Vault Statistics
public struct VaultStats: Codable, Equatable {
    public var total: Int
    public var available: Int
    public var reserved: Int
    public var sold: Int

    public init(total: Int = 0, available: Int = 0, reserved: Int = 0, sold: Int = 0) {
        self.total = total
        self.available = available
        self.reserved = reserved
        self.sold = sold
    }
}

// MARK: - Constants
public struct DiamondConstants {
    public static let shapes = [
        "Round", "Oval", "Emerald", "Cushion", "Radiant",
        "Princess", "Pear", "Marquise", "Heart", "Asscher"
    ]

    public static let colors = ["D", "E", "F", "G", "H", "I", "J", "K", "L", "M"]
    public static let clarities = ["FL", "IF", "VVS1", "VVS2", "VS1", "VS2", "SI1", "SI2", "I1"]
    public static let cuts = ["Ideal", "Excellent", "Very Good", "Good", "Fair"]
    public static let labs = ["GIA", "IGI", "HRD", "None"]
    public static let polishSymmetry = ["Excellent", "Very Good", "Good", "Fair"]
    public static let fluorescence = ["None", "Faint", "Medium", "Strong", "Very Strong"]
    public static let statuses = ["AVAILABLE", "RESERVED", "SOLD"]

    public static let masterSuperadminKey = "sk_live_diamond_superadmin_9f82a1c47e0b5d92"
    public static let baseURL = "https://aaldiam.com"
}
