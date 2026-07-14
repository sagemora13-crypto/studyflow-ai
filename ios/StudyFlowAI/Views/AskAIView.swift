import SwiftData
import SwiftUI

struct AskAIView: View {
  let profile: StudentProfile
  @Environment(\.modelContext) private var context
  @Query private var decks: [Deck]

  @State private var prompt = ""
  @State private var replies: [TutorReply] = []

  private var tutor: MockAITutor { MockAITutor(gradeLevel: profile.gradeLevel) }

  var body: some View {
    Group {
      NavigationStack {
        ScrollView {
          VStack(alignment: .leading, spacing: 18) {
            inputCard
            modeGrid
            ForEach(replies) { reply in
              replyCard(reply)
            }
            if replies.isEmpty { hint }
          }
          .padding(20)
        }
        .studyBackground()
        .navigationTitle("Ask AI")
      }
    }
    .__tenxTrackView("AskAIView")
  }

  private var inputCard: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("What are you working on?")
        .font(.headline).foregroundStyle(Theme.text)
      TextField("Type or paste a problem or question…", text: $prompt, axis: .vertical)
        .lineLimit(2...5)
        .foregroundStyle(Theme.text)
        .padding(12)
        .background(
          Theme.surfaceRaised,
          in: RoundedRectangle(cornerRadius: Theme.radiusSmall, style: .continuous))
      Text("StudyFlow explains and guides — it won't just hand you answers.")
        .font(.caption).foregroundStyle(Theme.textTertiary)
    }
    .card()
  }

  private var modeGrid: some View {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
      ForEach(TutorMode.allCases) { mode in
        Button {
          let reply = tutor.respond(to: prompt, mode: mode)
          withAnimation { replies.insert(reply, at: 0) }
        } label: {
          HStack(spacing: 8) {
            Image(systemName: mode.icon).foregroundStyle(Theme.accent)
            Text(mode.rawValue)
              .font(.subheadline.weight(.medium))
              .foregroundStyle(Theme.text)
            Spacer(minLength: 0)
          }
          .padding(.vertical, 12).padding(.horizontal, 12)
          .frame(maxWidth: .infinity)
          .background(
            Theme.surface,
            in: RoundedRectangle(cornerRadius: Theme.radiusMedium, style: .continuous)
          )
          .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusMedium, style: .continuous).strokeBorder(
              Theme.hairline))
        }
        .buttonStyle(.plain)
        .disabled(prompt.trimmingCharacters(in: .whitespaces).isEmpty && mode != .explain)
      }
    }
  }

  private func replyCard(_ reply: TutorReply) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Image(systemName: reply.mode.icon).foregroundStyle(Theme.accent)
        Text(reply.mode.rawValue).font(.headline).foregroundStyle(Theme.text)
      }
      Text(reply.body)
        .font(.subheadline)
        .foregroundStyle(Theme.text)
        .fixedSize(horizontal: false, vertical: true)
      if !reply.generatedCards.isEmpty {
        Button {
          addCards(reply.generatedCards)
        } label: {
          Label(
            "Add \(reply.generatedCards.count) cards to a deck",
            systemImage: "plus.rectangle.on.rectangle"
          )
          .font(.subheadline.weight(.semibold))
        }
        .buttonStyle(SecondaryButtonStyle())
      }
    }
    .card()
  }

  private var hint: some View {
    EmptyStateView(
      icon: "sparkles",
      title: "Understand, don't copy",
      message:
        "Type a question, then pick how you want help — a hint, a full walkthrough, or a check of your own answer."
    )
  }

  private func addCards(_ cards: [(front: String, back: String)]) {
    let deck: Deck
    if let existing = decks.first(where: { $0.name == "From Ask AI" }) {
      deck = existing
    } else {
      deck = Deck(name: "From Ask AI", subject: profile.subjects.first ?? "Math")
      context.insert(deck)
    }
    for c in cards {
      deck.cards.append(Flashcard(front: c.front, back: c.back))
    }
  }
}
