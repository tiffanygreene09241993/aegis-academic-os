import XCTest
@testable import Aegis

final class ProgramTests: XCTestCase {
    private func bundled() throws -> Program {
        try ProgramRepository(bundle: Bundle(for: ProgramStore.self)).bundledDefault()
    }

    func testBundledDataMatchesDegreeAudit() throws {
        let p = try bundled()
        // Transcript totals
        XCTAssertEqual(p.earnedCredits, 94)
        XCTAssertEqual(p.credits(for: .institutional), 34)
        XCTAssertEqual(p.credits(for: .transfer), 60)
        // Audit credit tracker: 94/121 applied, 27 remaining, 8 in progress, 9 still needed
        XCTAssertEqual(p.requiredCredits, 121)
        XCTAssertEqual(p.appliedCredits, 94)
        XCTAssertEqual(p.activeCredits, 24)
        XCTAssertEqual(p.remainingPlannedCredits, 27)
        XCTAssertEqual(p.creditsRemainingAfterInProgress, 27)
        XCTAssertEqual(p.unplannedCredits, 0)
        XCTAssertEqual(p.courses.filter { $0.status == .inProgress }.count, 8)
        XCTAssertEqual(p.courses.filter { $0.status == .planned }.count, 9)
        XCTAssertEqual(p.inProgressTerms, ["Fall 2026", "Spring 2027"])
        XCTAssertEqual(p.courses.filter { $0.term == "Spring 2027" }.reduce(0) { $0 + $1.credits }, 18)
        // Requirement groups
        let byID = Dictionary(uniqueKeysWithValues: p.categories.map { ($0.id, $0) })
        XCTAssertEqual(p.appliedCredits(in: byID["major"]!), 30)
        XCTAssertEqual(byID["major"]?.requiredCredits, 54)
        XCTAssertEqual(p.appliedCredits(in: byID["cognate"]!), 6)
        XCTAssertEqual(byID["cognate"]?.requiredCredits, 15)
        XCTAssertEqual(p.appliedCredits(in: byID["minor"]!), 12)
        XCTAssertEqual(byID["minor"]?.requiredCredits, 15)
        XCTAssertEqual(p.projectedLatinHonor?.name, "Summa Cum Laude")
    }

    func testCreditFormat() {
        XCTAssertEqual(CreditFormat.string(94), "94")
        XCTAssertEqual(CreditFormat.string(4.5), "4.5")
    }

    func testCommencementIsMidnightEastern() throws {
        let p = try bundled()
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "America/New_York")!
        let c = cal.dateComponents([.year, .month, .day, .hour, .minute], from: p.commencement)
        XCTAssertEqual([c.year, c.month, c.day, c.hour, c.minute], [2027, 8, 20, 0, 0])
        XCTAssertEqual(p.commencement, WidgetSnapshot.fallback.commencement)
    }

    func testCountdownParts() {
        let now = Date(timeIntervalSince1970: 0)
        let interval: TimeInterval = 183_845 // 2 days, 3 hours, 4 minutes, 5 seconds
        let parts = CountdownParts(from: now, to: now.addingTimeInterval(interval))
        XCTAssertEqual(parts, CountdownParts(from: now, to: now.addingTimeInterval(183_845)))
        XCTAssertEqual([parts.days, parts.hours, parts.minutes, parts.seconds], [2, 3, 4, 5])
        XCTAssertTrue(CountdownParts(from: now, to: now.addingTimeInterval(-10)).isComplete)
    }

    func testCourseValidation() {
        XCTAssertTrue(CourseValidation.validate(code: "CJUS 300", title: "Justice", creditsText: "3").isEmpty)
        XCTAssertNotNil(CourseValidation.validate(code: "", title: "x", creditsText: "3").code)
        XCTAssertNotNil(CourseValidation.validate(code: "A", title: " ", creditsText: "3").title)
        XCTAssertNotNil(CourseValidation.validate(code: "A", title: "x", creditsText: "0").credits)
        XCTAssertTrue(CourseValidation.validate(code: "HLTH 1XX", title: "x", creditsText: "4.5").isEmpty)
        XCTAssertNotNil(CourseValidation.validate(code: "A", title: "x", creditsText: "three").credits)
    }

    func testRoundTripPersistence() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".json")
        let repo = ProgramRepository(fileURL: url, bundle: Bundle(for: ProgramStore.self))
        XCTAssertNil(try repo.loadSaved())
        var p = try bundled()
        p.cumulativeGPA = 3.95
        try repo.save(p)
        XCTAssertEqual(try repo.loadSaved(), p)
        try repo.deleteSaved()
    }
}
