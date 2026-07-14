import SwiftUI
import SwiftData

@main
struct StudyFlowAIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .tint(Theme.accent)
        }
        .modelContainer(
            for: [
                StudentProfile.self,
                Assignment.self,
                AssignmentStep.self,
                TestDate.self,
                Deck.self,
                Flashcard.self,
                QuizResult.self,
                StudySession.self,
                StudyGuide.self,
                EarnedBadge.self,
            ]
        )
    }
}
