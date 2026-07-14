import SwiftUI
import SwiftData
import Charts

struct ProfileView: View {
    @Bindable var profile: StudentProfile
    @Query(sort: \StudySession.date) private var sessions: [StudySession]
    @Query(sort: \QuizResult.date) private var quizzes: [QuizResult]
    @Query private var decks: [Deck]

    var body: some View {
        Group {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        header
                        statsRow
                        studyTimeChart
                        masterySection
                        preferences
                    }
                    .padding(20)
                }
                .studyBackground()
                .navigationTitle("Profile")
            }
        }
        .__tenxTrackView("ProfileView")
    }

    private var header: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(Theme.accent.opacity(0.2)).frame(width: 64, height: 64)
                Text(initials).font(.title2.weight(.bold)).foregroundStyle(Theme.accent)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(profile.name).font(.title2.weight(.bold)).foregroundStyle(Theme.text)
                Text("Grade \(profile.gradeLevel) · \(profile.learningStyle)")
                    .font(.subheadline).foregroundStyle(Theme.textSecondary)
            }
            Spacer()
        }
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard("Streak", "\(profile.currentStreak)", "flame.fill")
            statCard("Points", "\(profile.points)", "star.fill")
            statCard("Cards", "\(totalCards)", "rectangle.stack.fill")
        }
    }

    private func statCard(_ label: String, _ value: String, _ icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon).foregroundStyle(Theme.accent)
            Text(value).font(.title3.weight(.bold)).foregroundStyle(Theme.text)
            Text(label).font(.caption).foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .card(padding: 14)
    }

    private var studyTimeChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader("Study time", subtitle: "Last sessions, in minutes")
            if sessions.isEmpty {
                Text("Log a study session to see your trends here.")
                    .font(.subheadline).foregroundStyle(Theme.textSecondary).card()
            } else {
                Chart(sessions) { session in
                    BarMark(
                        x: .value("Day", session.date, unit: .day),
                        y: .value("Minutes", session.minutes)
                    )
                    .foregroundStyle(Theme.accent)
                    .cornerRadius(4)
                }
                .frame(height: 160)
                .card()
            }
        }
    }

    private var masterySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader("Deck mastery")
            if decks.isEmpty {
                Text("No decks yet.").font(.subheadline).foregroundStyle(Theme.textSecondary).card()
            } else {
                ForEach(decks) { deck in
                    HStack {
                        Text(deck.name).font(.subheadline.weight(.medium)).foregroundStyle(Theme.text)
                        Spacer()
                        ProgressRing(progress: deck.mastery, size: 40, lineWidth: 5, color: Theme.subjectColor(deck.subject))
                    }
                    .card(padding: 14)
                }
            }
        }
    }

    private var preferences: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader("Daily goal")
            VStack(alignment: .leading, spacing: 8) {
                Text("\(profile.dailyStudyMinutes) min / day")
                    .font(.headline).foregroundStyle(Theme.accent)
                Slider(value: Binding(get: { Double(profile.dailyStudyMinutes) }, set: { profile.dailyStudyMinutes = Int($0) }), in: 10...90, step: 5)
                    .tint(Theme.accent)
            }
            .card()
        }
    }

    private var initials: String {
        let parts = profile.name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }

    private var totalCards: Int { decks.reduce(0) { $0 + $1.cards.count } }
}
