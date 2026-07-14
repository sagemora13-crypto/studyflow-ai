import Foundation
import SwiftData

/// Seeds realistic starter content the first time a profile is created,
/// so the app is useful offline immediately.
enum SampleData {
    static func seed(into context: ModelContext, subjects: [String]) {
        let primary = subjects.first ?? "Math"

        // Decks + cards
        let algebra = Deck(name: "Algebra Basics", subject: "Math")
        algebra.cards = [
            Flashcard(front: "What is a variable?", back: "A symbol (like x) that stands for an unknown number."),
            Flashcard(front: "Solve: x + 5 = 12", back: "x = 7"),
            Flashcard(front: "What does 'slope' measure?", back: "How steep a line is — rise over run."),
            Flashcard(front: "Distributive property", back: "a(b + c) = ab + ac"),
        ]

        let bio = Deck(name: "Cell Biology", subject: "Science")
        bio.cards = [
            Flashcard(front: "Powerhouse of the cell?", back: "The mitochondria."),
            Flashcard(front: "What does the nucleus do?", back: "Stores DNA and controls the cell's activities."),
            Flashcard(front: "Photosynthesis converts...", back: "Light energy into chemical energy (glucose)."),
        ]
        context.insert(algebra)
        context.insert(bio)

        // Assignments
        let a1 = Assignment(title: "Chapter 4 problem set", subject: "Math", dueDate: daysFromNow(1), difficulty: 2, estimatedMinutes: 40, priority: 3)
        a1.steps = [
            AssignmentStep(detail: "Review examples 4.1–4.3", dayOffset: 0),
            AssignmentStep(detail: "Do odd problems 1–15", dayOffset: 0),
        ]
        let a2 = Assignment(title: "Lab report: osmosis", subject: "Science", dueDate: daysFromNow(3), difficulty: 3, estimatedMinutes: 60, priority: 2)
        context.insert(a1)
        context.insert(a2)

        // Upcoming test
        context.insert(TestDate(subject: primary, title: "\(primary) unit test", date: daysFromNow(5)))

        // A little history so analytics isn't empty
        context.insert(StudySession(subject: "Math", activity: "Flashcards", minutes: 20, focusRating: 3))
        context.insert(QuizResult(topic: "Fractions", subject: "Math", scorePercent: 80, totalQuestions: 5, correctCount: 4, weakTopics: ["Mixed numbers"]))
    }

    private static func daysFromNow(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: .now) ?? .now
    }
}
