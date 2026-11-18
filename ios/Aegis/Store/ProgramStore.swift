import Foundation
import Observation
#if canImport(WidgetKit)
import WidgetKit
#endif

/// Single source of truth for the app. Views read `program` and call intent methods; the store persists.
@MainActor
@Observable
final class ProgramStore {
    enum Phase: Equatable {
        case loading
        case onboarding
        case ready
        case failed(String)
    }

    private(set) var phase: Phase = .loading
    private(set) var program: Program?
    /// Non-nil when the last save failed; screens show a banner with Retry.
    private(set) var saveError: String?
    /// Last deleted course, kept briefly so the user can undo a swipe-delete.
    private(set) var recentlyDeleted: (course: Course, index: Int)?

    private let repository: ProgramRepository

    init(repository: ProgramRepository = ProgramRepository()) {
        self.repository = repository
    }

    // MARK: Loading

    func load() async {
        phase = .loading
        do {
            if let saved = try repository.loadSaved() {
                program = saved
                phase = .ready
                publishWidgetSnapshot()
            } else {
                phase = .onboarding
            }
        } catch {
            phase = .failed("Your saved data couldn't be read. \(error.localizedDescription)")
        }
    }

    func useBundledDefault() {
        do {
            let p = try repository.bundledDefault()
            program = p
            phase = .ready
            persist()
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }

    func startCustom(_ p: Program) {
        program = p
        phase = .ready
        persist()
    }

    /// Clears saved data and returns to the first-launch choice.
    func resetAll() {
        try? repository.deleteSaved()
        program = nil
        recentlyDeleted = nil
        saveError = nil
        phase = .onboarding
    }

    // MARK: Editing

    func update(_ transform: (inout Program) -> Void) {
        guard var p = program else { return }
        transform(&p)
        program = p
        persist()
    }

    func replaceProgram(_ p: Program) {
        program = p
        persist()
    }

    func upsert(_ course: Course) {
        update { p in
            if let i = p.courses.firstIndex(where: { $0.id == course.id }) {
                p.courses[i] = course
            } else {
                p.courses.append(course)
            }
        }
    }

    func delete(_ course: Course) {
        guard let index = program?.courses.firstIndex(where: { $0.id == course.id }) else { return }
        recentlyDeleted = (course, index)
        update { $0.courses.remove(at: index) }
    }

    func undoDelete() {
        guard let deleted = recentlyDeleted else { return }
        update { p in
            p.courses.insert(deleted.course, at: min(deleted.index, p.courses.count))
        }
        recentlyDeleted = nil
    }

    func clearUndo() { recentlyDeleted = nil }

    func toggleMilestone(_ milestone: Milestone) {
        update { p in
            if let i = p.milestones.firstIndex(where: { $0.id == milestone.id }) {
                p.milestones[i].isComplete.toggle()
            }
        }
    }

    // MARK: Persistence

    func retrySave() { persist() }

    private func persist() {
        guard let program else { return }
        do {
            try repository.save(program)
            saveError = nil
            publishWidgetSnapshot()
        } catch {
            saveError = "Changes couldn't be saved. \(error.localizedDescription)"
        }
    }

    private func publishWidgetSnapshot() {
        guard let p = program else { return }
        WidgetSnapshot(commencement: p.commencement, earnedCredits: Int(p.appliedCredits),
                       requiredCredits: p.requiredCredits, programTitle: p.degree).save()
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
}

extension ProgramStore {
    /// Store pre-loaded with the bundled data, for SwiftUI previews.
    static func preview(_ phase: Phase = .ready, emptyCourses: Bool = false) -> ProgramStore {
        let store = ProgramStore(repository: ProgramRepository(
            fileURL: FileManager.default.temporaryDirectory.appendingPathComponent("aegis-preview.json")))
        if phase == .ready, var p = try? store.repository.bundledDefault() {
            if emptyCourses { p.courses = [] }
            store.program = p
        }
        store.phase = phase
        return store
    }
}
