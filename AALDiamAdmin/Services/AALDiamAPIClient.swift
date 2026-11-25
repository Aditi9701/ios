import Foundation

public class AALDiamAPIClient {
    public static let shared = AALDiamAPIClient()

    private let session: URLSession

    public init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20
        config.timeoutIntervalForResource = 35
        self.session = URLSession(configuration: config)
    }

    // MARK: - Fetch Diamonds & Stats
    public func fetchDiamonds(search: String? = nil, status: String? = nil) async throws -> ([Diamond], VaultStats) {
        var urlString = "\(DiamondConstants.baseURL)/api/admin/diamonds?"
        if let search = search, !search.isEmpty {
            urlString += "search=\(search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&"
        }
        if let status = status, !status.isEmpty && status != "ALL" {
            urlString += "status=\(status.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&"
        }

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(DiamondConstants.masterSuperadminKey, forHTTPHeaderField: "X-Super-Admin-Key")

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        struct ResponseWrapper: Codable {
            let success: Bool
            let stats: VaultStats?
            let diamonds: [Diamond]
        }

        let decoded = try JSONDecoder().decode(ResponseWrapper.self, from: data)
        return (decoded.diamonds, decoded.stats ?? VaultStats())
    }

    // MARK: - Upload Certificate / Parcel Image
    public func uploadImage(imageData: Data, stockNumber: String, filename: String = "cert.jpg") async throws -> String? {
        guard let url = URL(string: "\(DiamondConstants.baseURL)/api/admin/upload-image") else {
            throw URLError(.badURL)
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue(DiamondConstants.masterSuperadminKey, forHTTPHeaderField: "X-Super-Admin-Key")

        var body = Data()

        // Stock Number part
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"stockNumber\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(stockNumber)\r\n".data(using: .utf8)!)

        // File part
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return nil
        }

        struct UploadResponse: Codable {
            let success: Bool
            let url: String?
        }

        let decoded = try JSONDecoder().decode(UploadResponse.self, from: data)
        return decoded.url
    }

    // MARK: - Upsert / Sync Single Diamond
    public func syncDiamond(draft: DiamondDraft) async throws -> Bool {
        return try await syncDiamondsBatch(drafts: [draft])
    }

    // MARK: - Batch Upsert Diamonds
    public func syncDiamondsBatch(drafts: [DiamondDraft]) async throws -> Bool {
        guard !drafts.isEmpty else { return true }
        guard let url = URL(string: "\(DiamondConstants.baseURL)/api/admin/diamonds") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(DiamondConstants.masterSuperadminKey, forHTTPHeaderField: "X-Super-Admin-Key")

        var items: [[String: Any]] = []
        for d in drafts {
            var dict: [String: Any] = [
                "stockNumber": d.stockNumber,
                "shape": d.shape,
                "carat": d.carat,
                "color": d.color,
                "clarity": d.clarity,
                "cut": d.cut,
                "polish": d.polish,
                "symmetry": d.symmetry,
                "fluorescence": d.fluorescence,
                "measurements": d.measurements,
                "certificateLab": d.certificateLab,
                "certificateNumber": d.certificateNumber,
                "price": d.price,
                "status": d.status
            ]
            if let img = d.remoteImageUrl { dict["imageUrl"] = img }
            items.append(dict)
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: items)

        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return false
        }
        return true
    }

    // MARK: - Update Full Diamond Details
    public func updateDiamond(originalStockNumber: String, diamond: Diamond) async throws -> Bool {
        guard let url = URL(string: "\(DiamondConstants.baseURL)/api/admin/diamonds") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(DiamondConstants.masterSuperadminKey, forHTTPHeaderField: "X-Super-Admin-Key")

        var dict: [String: Any] = [
            "originalStockNumber": originalStockNumber,
            "stockNumber": diamond.stockNumber,
            "shape": diamond.shape,
            "carat": diamond.carat,
            "color": diamond.color,
            "clarity": diamond.clarity,
            "cut": diamond.cut ?? "Excellent",
            "polish": diamond.polish,
            "symmetry": diamond.symmetry,
            "fluorescence": diamond.fluorescence,
            "measurements": diamond.measurements,
            "certificateLab": diamond.certificateLab,
            "certificateNumber": diamond.certificateNumber,
            "price": diamond.price,
            "status": diamond.status
        ]
        if let img = diamond.imageUrl { dict["imageUrl"] = img }
        if let vid = diamond.videoUrl { dict["videoUrl"] = vid }

        request.httpBody = try JSONSerialization.data(withJSONObject: dict)

        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return false
        }
        return true
    }

    // MARK: - Delete Diamond
    public func deleteDiamond(stockNumber: String) async throws -> Bool {
        guard let encoded = stockNumber.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(DiamondConstants.baseURL)/api/admin/diamonds?stockNumber=\(encoded)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue(DiamondConstants.masterSuperadminKey, forHTTPHeaderField: "X-Super-Admin-Key")

        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return false
        }
        return true
    }
}
