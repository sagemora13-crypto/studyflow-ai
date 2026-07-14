import SwiftData
import SwiftUI

struct ContentView: View {
  @Query private var profiles: [StudentProfile]

  var body: some View {
    Group {
      Group {
        if let profile = profiles.first, !profile.name.isEmpty {
          MainTabView(profile: profile)
        } else {
          OnboardingView()
        }
      }
    }
    .__tenxTrackView("ContentView")
  }
}

struct MainTabView: View {
  let profile: StudentProfile

  var body: some View {
    TabView {
      HomeView(profile: profile)
        .tabItem { Label("Home", systemImage: "house") }
      AskAIView(profile: profile)
        .tabItem { Label("Ask AI", systemImage: "sparkles") }
      StudyView(profile: profile)
        .tabItem { Label("Study", systemImage: "rectangle.stack") }
      PlannerView()
        .tabItem { Label("Planner", systemImage: "calendar") }
      ProfileView(profile: profile)
        .tabItem { Label("Profile", systemImage: "person") }
    }
  }
}

#Preview {
  ContentView()
    .modelContainer(
      for: [
        StudentProfile.self, Assignment.self, AssignmentStep.self, TestDate.self, Deck.self,
        Flashcard.self, QuizResult.self, StudySession.self, StudyGuide.self, EarnedBadge.self,
      ], inMemory: true
    )
    .preferredColorScheme(.dark)
}
