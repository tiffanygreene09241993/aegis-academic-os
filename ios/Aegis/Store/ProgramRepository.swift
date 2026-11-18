import Foundation

/// Reads and writes the student's Program as JSON in Application Support. No accounts, no network.
struct ProgramRepository {
    enum RepositoryError: LocalizedError {
        case missingDefault
        var errorDescription: String? {
            switch self {
            case .missingDefault: return "The built-in program data is missing from the app."
            }
        }
    }

    var fileURL: URL
    var bundle: Bundle

    init(fileURL: URL? = nil, bundle: Bundle = .main) {
        self.bundle = bundle
        if let fileURL {
            self.fileURL = fileURL
        } else {
            let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                ?? FileManager.default.temporaryDirectory
            self.fileURL = support.appendingPathComponent("Aegis", isDirectory: true)
                .appendingPathComponent("program.json")
        }
    }

    static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        e.outputFormatting = [.prettyPrinted, .sortedKeys]
        return e
    }()

    /// Returns nil on first launch (nothing saved yet).
    func loadSaved() throws -> Program? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        let data = try Data(contentsOf: fileURL)
        return try Self.decoder.decode(Program.self, from: data)
    }

    func save(_ program: Program) throws {
        let dir = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let data = try Self.encoder.encode(program)
        try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
    }

    func deleteSaved() throws {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
    }

    func bundledDefault() throws -> Program {
        guard let url = bundle.url(forResource: "DefaultProgram", withExtension: "json") else {
            throw RepositoryError.missingDefault
        }
        return try Self.decoder.decode(Program.self, from: Data(contentsOf: url))
    }
}
