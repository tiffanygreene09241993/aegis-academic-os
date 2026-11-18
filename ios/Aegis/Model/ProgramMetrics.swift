import Foundation

/// Derived numbers. Kept free of UI frameworks so it is unit-testable.
///
/// Terms follow the degree audit's credit tracker:
/// - earned: every completed credit on the transcript (institutional + transfer)
/// - applied: credits the audit counts toward requirements = applied earned + in progress
/// - still needed: requirement credits not yet taken (status `.planned`)
extension Program {
    /// All completed credits (transcript "Earned Hours").
    var earnedCredits: Double {
        Double(unitemizedEarnedCredits) + credits(for: .completed)
    }

    /// Completed credits the audit applies to requirements.
    var appliedEarnedCredits: Double {
        max(0, earnedCredits - Double(nonApplicableCredits ?? 0))
    }

    var activeCredits: Double { credits(for: .inProgress) }
    var remainingPlannedCredits: Double { credits(for: .planned) }

    /// The audit tracker's numerator (completed-and-applied + in progress).
    var appliedCredits: Double { appliedEarnedCredits + activeCredits }

    /// Credits still needed that no course covers yet (0 when the plan is complete).
    var unplannedCredits: Double {
        max(0, Double(requiredCredits) - appliedCredits - remainingPlannedCredits)
    }

    /// Credits left after everything in progress is finished.
    var creditsRemainingAfterInProgress: Double {
        max(0, Double(requiredCredits) - appliedCredits)
    }

    var appliedEarnedFraction: Double {
        guard requiredCredits > 0 else { return 0 }
        return min(1, appliedEarnedCredits / Double(requiredCredits))
    }

    var appliedFraction: Double {
        guard requiredCredits > 0 else { return 0 }
        return min(1, appliedCredits / Double(requiredCredits))
    }

    func credits(for status: CourseStatus) -> Double {
        courses.filter { $0.status == status }.reduce(0) { $0 + $1.credits }
    }

    func credits(for source: CourseSource, status: CourseStatus = .completed) -> Double {
        courses.filter { $0.source == source && $0.status == status }.reduce(0) { $0 + $1.credits }
    }

    /// In-progress terms in the order they first appear (e.g. ["Fall 2026", "Spring 2027"]).
    var inProgressTerms: [String] {
        var seen: [String] = []
        for c in courses where c.status == .inProgress && !seen.contains(c.term) { seen.append(c.term) }
        return seen
    }

    /// Courses in a category, including categories it contains (e.g. the cognate inside the major).
    func courses(in category: RequirementCategory) -> [Course] {
        let ids = Set([category.id] + (category.includes ?? []))
        return courses.filter { ids.contains($0.categoryID) }
    }

    func listedCredits(in category: RequirementCategory, statuses: Set<CourseStatus> = Set(CourseStatus.allCases)) -> Double {
        courses(in: category).filter { statuses.contains($0.status) }.reduce(0) { $0 + $1.credits }
    }

    /// Credits the audit would show as applied for a category (completed + in progress).
    func appliedCredits(in category: RequirementCategory) -> Double {
        listedCredits(in: category, statuses: [.completed, .inProgress])
    }

    /// Highest Latin honor whose threshold the current GPA meets.
    var projectedLatinHonor: LatinHonorThreshold? {
        latinHonors.sorted { $0.minimumGPA > $1.minimumGPA }.first { cumulativeGPA >= $0.minimumGPA }
    }

    var nextMilestone: Milestone? {
        milestones.first { !$0.isComplete }
    }

    var commencementTimeZone: TimeZone {
        TimeZone(identifier: commencementTimeZoneID) ?? .current
    }
}

/// "94", "4.5", "38.5" — whole numbers without a decimal point.
enum CreditFormat {
    static func string(_ value: Double) -> String {
        if value.rounded() == value { return String(Int(value)) }
        return String(format: "%.1f", value)
    }
}

/// Time left until a date, split for display.
struct CountdownParts: Equatable {
    let days: Int
    let hours: Int
    let minutes: Int
    let seconds: Int
    var isComplete: Bool { days == 0 && hours == 0 && minutes == 0 && seconds == 0 }

    init(from now: Date, to target: Date) {
        let total = max(0, Int(target.timeIntervalSince(now)))
        days = total / 86_400
        hours = (total % 86_400) / 3_600
        minutes = (total % 3_600) / 60
        seconds = total % 60
    }
}

enum CourseValidation {
    struct Errors: Equatable {
        var code: String?
        var title: String?
        var credits: String?
        var isEmpty: Bool { code == nil && title == nil && credits == nil }
    }

    /// Parses "3", "4.5" or "4,5". Returns nil when not a number.
    static func parseCredits(_ text: String) -> Double? {
        Double(text.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: ",", with: "."))
    }

    static func validate(code: String, title: String, creditsText: String) -> Errors {
        var e = Errors()
        let trimmedCode = code.trimmingCharacters(in: .whitespaces)
        if trimmedCode.isEmpty {
            e.code = "Enter a course code, like CJUS 300."
        } else if trimmedCode.count > 12 {
            e.code = "Keep the code to 12 characters or fewer."
        }
        if title.trimmingCharacters(in: .whitespaces).isEmpty {
            e.title = "Enter the course title."
        }
        if let credits = parseCredits(creditsText) {
            if !(0.5...12).contains(credits) { e.credits = "Credits must be between 0.5 and 12." }
        } else {
            e.credits = "Enter credits as a number, like 3 or 4.5."
        }
        return e
    }
}

extension Program {
    /// Starting point for a student who sets up their own program.
    static func blank(name: String, institution: String, degree: String, requiredCredits: Int,
                      earnedCredits: Int, gpa: Double, commencement: Date) -> Program {
        Program(
            student: StudentProfile(name: name, institution: institution, school: nil),
            degree: degree, cognate: nil, minor: nil,
            requiredCredits: requiredCredits,
            unitemizedEarnedCredits: earnedCredits,
            nonApplicableCredits: nil,
            cumulativeGPA: gpa,
            latinHonors: [
                LatinHonorThreshold(name: "Summa Cum Laude", minimumGPA: 3.90),
                LatinHonorThreshold(name: "Magna Cum Laude", minimumGPA: 3.70),
                LatinHonorThreshold(name: "Cum Laude", minimumGPA: 3.50)
            ],
            commencement: commencement,
            commencementTimeZoneID: TimeZone.current.identifier,
            categories: [
                RequirementCategory(id: "gen-ed", name: "General Education", summary: nil, requiredCredits: nil, symbol: "books.vertical"),
                RequirementCategory(id: "major", name: "Major Courses", summary: nil, requiredCredits: nil, symbol: "building.columns"),
                RequirementCategory(id: "electives", name: "Electives", summary: nil, requiredCredits: nil, symbol: "square.grid.2x2")
            ],
            courses: [], honors: [],
            milestones: [
                Milestone(id: "commencement", title: "Commencement", detail: nil, date: commencement, isComplete: false, symbol: "graduationcap")
            ],
            regalia: [],
            graduationRequirements: nil,
            dataNote: "Student-maintained; not an official transcript."
        )
    }
}
