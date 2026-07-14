import SwiftData
import SwiftUI

struct HomeView: View {
  let profile: StudentProfile
  @Query(sort: \Assignment.dueDate) private var assignments: [Assignment]
  @Query(sort: \TestDate.date) private var tests: [TestDate]
  @Query private var decks: [Deck]

  private var todayAssignments: [Assignment] {
    assignments.filter {
      !$0.isDone && Calendar.current.isDateInToday($0.dueDate) || (!$0.isDone && $0.dueDate < .now)
    }
  }

  private var upcomingTests: [TestDate] {
    tests.filter { $0.date >= Calendar.current.startOfDay(for: .now) }
  }

  private var dueCards: Int { decks.reduce(0) { $0 + $1.dueCount } }

  var body: some View {
    Group {
      NavigationStack {
        ScrollView {
          VStack(alignment: .leading, spacing: 24) {
            greeting
            streakCard
            recommendedSession
            if !upcomingTests.isEmpty { testsSection }
            todaySection
          }
          .padding(20)
        }
        .studyBackground()
        .navigationTitle("Today")
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) {
            Image(systemName: "flame.fill")
              .foregroundStyle(Theme.accent)
          }
        }
      }
    }
    .__tenxTrackView("HomeView")
  }

  private var greeting: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(greetingText)
        .font(.subheadline)
        .foregroundStyle(Theme.textSecondary)
      Text(profile.name)
        .font(.largeTitle.weight(.bold))
        .foregroundStyle(Theme.text)
    }
  }

  private var streakCard: some View {
    HStack(spacing: 18) {
      VStack(alignment: .leading, spacing: 4) {
        Text("\(profile.currentStreak) day streak")
          .font(.title3.weight(.bold))
          .foregroundStyle(Theme.text)
        Text("\(profile.points) points · Goal \(profile.dailyStudyMinutes) min")
          .font(.subheadline)
          .foregroundStyle(Theme.textSecondary)
      }
      Spacer()
      Image(systemName: "flame.fill")
        .font(.system(size: 34))
        .foregroundStyle(Theme.accent)
    }
    .card()
  }

  private var recommendedSession: some View {
    VStack(alignment: .leading, spacing: 12) {
      SectionHeader("Recommended session")
      NavigationLink {
        StudyView(profile: profile)
      } label: {
        HStack(spacing: 14) {
          ProgressRing(progress: overallMastery, size: 52)
          VStack(alignment: .leading, spacing: 4) {
            Text(dueCards > 0 ? "\(dueCards) cards due for review" : "You're all caught up")
              .font(.headline)
              .foregroundStyle(Theme.text)
            Text("Spaced repetition keeps it in long-term memory.")
              .font(.subheadline)
              .foregroundStyle(Theme.textSecondary)
          }
          Spacer()
          Image(systemName: "chevron.right").foregroundStyle(Theme.textTertiary)
        }
        .card()
      }
      .buttonStyle(.plain)
    }
  }

  private var testsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      SectionHeader("Upcoming tests")
      ForEach(upcomingTests) { test in
        HStack {
          TagPill(text: test.subject, color: Theme.subjectColor(test.subject))
          Text(test.title)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Theme.text)
          Spacer()
          Text(test.date, format: .dateTime.month().day())
            .font(.subheadline)
            .foregroundStyle(Theme.textSecondary)
        }
        .card(padding: 14)
      }
    }
  }

  private var todaySection: some View {
    VStack(alignment: .leading, spacing: 12) {
      SectionHeader("Due soon")
      if todayAssignments.isEmpty {
        Text("Nothing due right now — nice.")
          .font(.subheadline)
          .foregroundStyle(Theme.textSecondary)
          .card()
      } else {
        ForEach(todayAssignments) { item in
          HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 3)
              .fill(Theme.subjectColor(item.subject))
              .frame(width: 4, height: 38)
            VStack(alignment: .leading, spacing: 2) {
              Text(item.title).font(.headline).foregroundStyle(Theme.text)
              Text("\(item.subject) · \(item.estimatedMinutes) min")
                .font(.caption).foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            Text(item.dueDate, format: .dateTime.month().day())
              .font(.caption).foregroundStyle(Theme.textTertiary)
          }
          .card(padding: 14)
        }
      }
    }
  }

  private var overallMastery: Double {
    guard !decks.isEmpty else { return 0 }
    return decks.reduce(0.0) { $0 + $1.mastery } / Double(decks.count)
  }

  private var greetingText: String {
    let hour = Calendar.current.component(.hour, from: .now)
    switch hour {
    case 5..<12: return "Good morning"
    case 12..<17: return "Good afternoon"
    default: return "Good evening"
    }
  }
}
