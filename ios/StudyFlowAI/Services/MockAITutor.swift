import Foundation

/// A tutoring intent — the "explain, don't cheat" flow.
enum TutorMode: String, CaseIterable, Identifiable {
    case explain = "Explain"
    case hint = "Give a hint"
    case steps = "Walk me through"
    case check = "Check my answer"
    case similar = "Make a similar problem"
    case flashcards = "Make flashcards"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .explain: return "lightbulb"
        case .hint: return "sparkles"
        case .steps: return "list.number"
        case .check: return "checkmark.circle"
        case .similar: return "arrow.triangle.2.circlepath"
        case .flashcards: return "rectangle.stack"
        }
    }
}

struct TutorReply: Identifiable {
    let id = UUID()
    let mode: TutorMode
    let prompt: String
    let body: String
    let generatedCards: [(front: String, back: String)]
}

/// Deterministic mock tutor. Structured so a real AI backend can replace
/// `respond(to:mode:gradeLevel:)` later without touching the UI. The real
/// implementation would call a server-side endpoint; the API key never lives
/// in the app.
struct MockAITutor {
    var gradeLevel: Int = 9

    func respond(to prompt: String, mode: TutorMode) -> TutorReply {
        let trimmed = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        let topic = trimmed.isEmpty ? "this problem" : trimmed
        let tone = gradeLevel <= 7 ? "simple" : "deeper"

        var cards: [(front: String, back: String)] = []
        let body: String

        switch mode {
        case .explain:
            body = """
            Let's understand \(topic) rather than just get the answer.

            The big idea: break the problem into what you know and what you're being asked to find. \(tone == "simple" ? "Think of it like a recipe — one step at a time." : "Identify the underlying concept and the relationships between the given quantities.")

            Try restating the question in your own words first — that's usually where understanding starts.
            """
        case .hint:
            body = """
            Here's a nudge, not the answer 🙂

            Look for the one piece of information you haven't used yet. What relationship connects it to what you're solving for? Start there and take a single small step.
            """
        case .steps:
            body = """
            Walkthrough for \(topic):

            1. Write down everything you're given.
            2. Name what you're trying to find.
            3. Pick the rule or formula that links them.
            4. Substitute carefully, one value at a time.
            5. Check that your answer makes sense in context.

            Try each step yourself before peeking ahead.
            """
        case .check:
            body = """
            Nice work attempting it. Walk me through your reasoning:

            • Does each step follow from the one before?
            • Did the units / form of the answer stay consistent?
            • Would the answer still make sense if the numbers were bigger or smaller?

            If all three hold up, you're likely correct.
            """
        case .similar:
            body = """
            Here's a similar practice problem based on \(topic):

            Same idea, new numbers — solve it using the same steps you just learned, then compare your approach.
            """
        case .flashcards:
            body = "I turned \(topic) into a few flashcards you can add to a deck below."
            cards = [
                ("Key idea in \(topic)", "Restate the core concept in one sentence."),
                ("First step to solve", "List what you know and what you need to find."),
                ("Common mistake", "Skipping the check that the answer makes sense."),
            ]
        }

        return TutorReply(mode: mode, prompt: trimmed, body: body, generatedCards: cards)
    }
}
