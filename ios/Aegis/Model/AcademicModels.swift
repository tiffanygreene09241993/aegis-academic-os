import Foundation

/// One student's degree program. Everything the app shows comes from this single Codable value,
/// so any student can use the app by supplying their own `Program` (bundled default or setup flow).
struct Program: Codable, Equatable {
    var schemaVersion: Int = 1
    var student: StudentProfile
    var degree: String
    var cognate: String?
    var minor: String?
    var requiredCredits: Int
    /// Credits already earned that are not itemized as individual courses (transfer, earlier terms, etc.).
    var unitemizedEarnedCredits: Int
    /// Earned credits the degree audit does not apply to any requirement (e.g. excess transfer electives).
    var nonApplicableCredits: Int?
    var cumulativeGPA: Double
    var gpaScale: Double = 4.0
    var latinHonors: [LatinHonorThreshold]
    var commencement: Date
    var commencementTimeZoneID: String
    var categories: [RequirementCategory]
    var courses: [Course]
    var honors: [Honor]
    var milestones: [Milestone]
    var regalia: [RegaliaItem]
    /// School-wide checks from the audit (minimum hours, upper-level credits, residency, GPA...).
    var graduationRequirements: [GraduationRequirement]?
    /// Shown in Settings > About, e.g. "Student-maintained; not an official transcript."
    var dataNote: String?
}

struct StudentProfile: Codable, Equatable {
    var name: String
    var institution: String
    var school: String?
}

struct RequirementCategory: Codable, Equatable, Identifiable, Hashable {
    var id: String
    var name: String
    var summary: String?
    /// nil when the program has not set a credit target for this requirement.
    var requiredCredits: Int?
    var symbol: String
    /// Other categories whose courses also count here (e.g. a cognate inside the major).
    var includes: [String]?
}

struct GraduationRequirement: Codable, Equatable, Identifiable, Hashable {
    var id: String
    var name: String
    /// e.g. "94 credits"; nil when the requirement is a task rather than a number.
    var current: String?
    var required: String
    var isMet: Bool?
}

enum CourseSource: String, Codable, CaseIterable {
    case institutional, transfer
}

enum CourseStatus: String, Codable, CaseIterable, Identifiable {
    case completed, inProgress, planned
    var id: String { rawValue }
    var label: String {
        switch self {
        case .completed: return "Completed"
        case .inProgress: return "In progress"
        case .planned: return "Still needed"
        }
    }
}

struct Course: Codable, Equatable, Identifiable, Hashable {
    var id: UUID = UUID()
    var code: String
    var title: String
    /// Double so quarter-hour and transfer credits like 4.5 are exact.
    var credits: Double
    var status: CourseStatus
    var term: String
    var grade: String?
    var categoryID: String
    var source: CourseSource?
}

struct Honor: Codable, Equatable, Identifiable, Hashable {
    var id: String
    var name: String
    var chapter: String?
    var discipline: String?
    var status: String
    var inducted: String?
    var requirement: String?
    var summary: String?
    var regaliaCords: String?
}

struct LatinHonorThreshold: Codable, Equatable, Identifiable, Hashable {
    var name: String
    var minimumGPA: Double
    var id: String { name }
}

struct Milestone: Codable, Equatable, Identifiable, Hashable {
    var id: String
    var title: String
    var detail: String?
    var date: Date?
    var isComplete: Bool
    var symbol: String
}

struct RegaliaItem: Codable, Equatable, Identifiable, Hashable {
    var id: String
    var item: String
    var distinction: String
    var status: String
    var detail: String?
}
