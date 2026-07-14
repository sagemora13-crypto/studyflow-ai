import SwiftData
import SwiftUI

/// Personalization quiz that creates the single StudentProfile.
struct OnboardingView: View {
  @Environment(\.modelContext) private var context

  @State private var step = 0
  @State private var name = ""
  @State private var grade = 9
  @State private var subjects: Set<String> = []
  @State private var struggles = ""
  @State private var goal = ""
  @State private var style: LearningStyle = .balanced
  @State private var minutes = 30

  private let totalSteps = 5

  var body: some View {
    Group {
      VStack(spacing: 0) {
        ProgressView(value: Double(step + 1), total: Double(totalSteps))
          .tint(Theme.accent)
          .padding(.horizontal, 20)
          .padding(.top, 12)

        TabView(selection: $step) {
          nameStep.tag(0)
          gradeStep.tag(1)
          subjectsStep.tag(2)
          styleStep.tag(3)
          goalStep.tag(4)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut, value: step)

        footer
      }
      .studyBackground()
    }
    .__tenxTrackView("OnboardingView")
  }

  // MARK: Steps

  private var nameStep: some View {
    stepContainer(
      title: "What should we call you?",
      subtitle: "Your study companion keeps everything on this device."
    ) {
      TextField("First name or nickname", text: $name)
        .textFieldStyle(.plain)
        .font(.title3)
        .foregroundStyle(Theme.text)
        .padding()
        .background(
          Theme.surface, in: RoundedRectangle(cornerRadius: Theme.radiusMedium, style: .continuous)
        )
        .overlay(
          RoundedRectangle(cornerRadius: Theme.radiusMedium, style: .continuous).strokeBorder(
            Theme.hairline))
    }
  }

  private var gradeStep: some View {
    stepContainer(title: "What grade are you in?", subtitle: "We tune explanations to your level.")
    {
      VStack(spacing: 10) {
        ForEach([6, 7, 8, 9, 10, 11, 12], id: \.self) { g in
          selectRow(title: "Grade \(g)", selected: grade == g) { grade = g }
        }
      }
    }
  }

  private var subjectsStep: some View {
    stepContainer(title: "Which subjects?", subtitle: "Pick the ones you want help with first.") {
      VStack(spacing: 10) {
        ForEach(Subject.allCases) { subject in
          selectRow(
            title: subject.rawValue, icon: subject.icon,
            selected: subjects.contains(subject.rawValue)
          ) {
            if subjects.contains(subject.rawValue) {
              subjects.remove(subject.rawValue)
            } else {
              subjects.insert(subject.rawValue)
            }
          }
        }
      }
    }
  }

  private var styleStep: some View {
    stepContainer(
      title: "How do you learn best?", subtitle: "This shapes how the AI explains things."
    ) {
      VStack(spacing: 10) {
        ForEach(LearningStyle.allCases) { s in
          selectRow(title: s.rawValue, icon: s.icon, selected: style == s) { style = s }
        }
      }
    }
  }

  private var goalStep: some View {
    stepContainer(
      title: "Set your daily goal", subtitle: "Small, consistent sessions build streaks."
    ) {
      VStack(alignment: .leading, spacing: 18) {
        VStack(alignment: .leading, spacing: 8) {
          Text("\(minutes) min / day")
            .font(.title2.weight(.bold))
            .foregroundStyle(Theme.accent)
          Slider(
            value: Binding(get: { Double(minutes) }, set: { minutes = Int($0) }), in: 10...90,
            step: 5
          )
          .tint(Theme.accent)
        }
        TextField("What's your goal? (optional)", text: $goal)
          .textFieldStyle(.plain)
          .foregroundStyle(Theme.text)
          .padding()
          .background(
            Theme.surface,
            in: RoundedRectangle(cornerRadius: Theme.radiusMedium, style: .continuous)
          )
          .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusMedium, style: .continuous).strokeBorder(
              Theme.hairline))
      }
    }
  }

  // MARK: Footer / navigation

  private var footer: some View {
    HStack(spacing: 12) {
      if step > 0 {
        Button("Back") { withAnimation { step -= 1 } }
          .buttonStyle(SecondaryButtonStyle())
      }
      Button(step == totalSteps - 1 ? "Start studying" : "Continue") {
        if step == totalSteps - 1 { finish() } else { withAnimation { step += 1 } }
      }
      .buttonStyle(PrimaryButtonStyle(enabled: canContinue))
      .disabled(!canContinue)
    }
    .padding(20)
  }

  private var canContinue: Bool {
    switch step {
    case 0: return !name.trimmingCharacters(in: .whitespaces).isEmpty
    case 2: return !subjects.isEmpty
    default: return true
    }
  }

  private func finish() {
    let profile = StudentProfile(
      name: name.trimmingCharacters(in: .whitespaces),
      gradeLevel: grade,
      subjects: Array(subjects).sorted(),
      struggleAreas: struggles.isEmpty ? [] : [struggles],
      goal: goal,
      learningStyle: style.rawValue,
      dailyStudyMinutes: minutes
    )
    context.insert(profile)
    SampleData.seed(into: context, subjects: profile.subjects)
  }

  // MARK: Building blocks

  private func stepContainer<Content: View>(
    title: String, subtitle: String, @ViewBuilder content: () -> Content
  ) -> some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        VStack(alignment: .leading, spacing: 8) {
          Text(title)
            .font(.largeTitle.weight(.bold))
            .foregroundStyle(Theme.text)
          Text(subtitle)
            .font(.body)
            .foregroundStyle(Theme.textSecondary)
        }
        content()
      }
      .padding(24)
    }
  }

  private func selectRow(
    title: String, icon: String? = nil, selected: Bool, action: @escaping () -> Void
  ) -> some View {
    Button(action: action) {
      HStack(spacing: 12) {
        if let icon {
          Image(systemName: icon)
            .foregroundStyle(selected ? Theme.accent : Theme.textSecondary)
            .frame(width: 24)
        }
        Text(title)
          .font(.headline)
          .foregroundStyle(Theme.text)
        Spacer()
        Image(systemName: selected ? "checkmark.circle.fill" : "circle")
          .foregroundStyle(selected ? Theme.accent : Theme.textTertiary)
      }
      .padding()
      .background(
        Theme.surface, in: RoundedRectangle(cornerRadius: Theme.radiusMedium, style: .continuous)
      )
      .overlay(
        RoundedRectangle(cornerRadius: Theme.radiusMedium, style: .continuous)
          .strokeBorder(selected ? Theme.accent : Theme.hairline, lineWidth: selected ? 1.5 : 1)
      )
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  OnboardingView()
    .modelContainer(
      for: [
        StudentProfile.self, Assignment.self, AssignmentStep.self, TestDate.self, Deck.self,
        Flashcard.self, QuizResult.self, StudySession.self, StudyGuide.self, EarnedBadge.self,
      ], inMemory: true
    )
    .preferredColorScheme(.dark)
}
