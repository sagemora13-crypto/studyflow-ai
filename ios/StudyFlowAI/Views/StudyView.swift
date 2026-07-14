import SwiftData
import SwiftUI

struct StudyView: View {
  let profile: StudentProfile
  @Environment(\.modelContext) private var context
  @Query(sort: \Deck.createdAt, order: .reverse) private var decks: [Deck]

  @State private var showingNewDeck = false
  @State private var newDeckName = ""

  var body: some View {
    Group {
      NavigationStack {
        ScrollView {
          VStack(alignment: .leading, spacing: 16) {
            if decks.isEmpty {
              EmptyStateView(
                icon: "rectangle.stack",
                title: "No decks yet",
                message: "Create a deck of flashcards and StudyFlow will schedule reviews for you.",
                actionTitle: "New deck"
              ) { showingNewDeck = true }
            } else {
              ForEach(decks) { deck in
                NavigationLink {
                  DeckReviewView(deck: deck)
                } label: {
                  deckRow(deck)
                }
                .buttonStyle(.plain)
              }
            }
          }
          .padding(20)
        }
        .studyBackground()
        .navigationTitle("Study")
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) {
            Button {
              showingNewDeck = true
            } label: {
              Image(systemName: "plus")
            }
          }
        }
        .alert("New deck", isPresented: $showingNewDeck) {
          TextField("Deck name", text: $newDeckName)
          Button("Create", action: createDeck)
          Button("Cancel", role: .cancel) { newDeckName = "" }
        }
      }
    }
    .__tenxTrackView("StudyView")
  }

  private func deckRow(_ deck: Deck) -> some View {
    HStack(spacing: 14) {
      ProgressRing(progress: deck.mastery, size: 50, color: Theme.subjectColor(deck.subject))
      VStack(alignment: .leading, spacing: 4) {
        Text(deck.name).font(.headline).foregroundStyle(Theme.text)
        Text("\(deck.cards.count) cards · \(deck.subject)")
          .font(.caption).foregroundStyle(Theme.textSecondary)
      }
      Spacer()
      if deck.dueCount > 0 {
        TagPill(text: "\(deck.dueCount) due", color: Theme.accent)
      } else {
        Image(systemName: "checkmark.circle.fill").foregroundStyle(Theme.success)
      }
    }
    .card(padding: 14)
  }

  private func createDeck() {
    let name = newDeckName.trimmingCharacters(in: .whitespaces)
    guard !name.isEmpty else { return }
    context.insert(Deck(name: name, subject: profile.subjects.first ?? "Math"))
    newDeckName = ""
  }
}

/// Spaced-repetition review session for one deck.
struct DeckReviewView: View {
  @Bindable var deck: Deck
  @Environment(\.modelContext) private var context
  @Environment(\.dismiss) private var dismiss

  @State private var queue: [Flashcard] = []
  @State private var index = 0
  @State private var showingBack = false
  @State private var completed = false
  @State private var reviewed = 0

  @State private var showingAddCard = false
  @State private var front = ""
  @State private var back = ""

  var body: some View {
    VStack {
      if queue.isEmpty || completed {
        sessionSummary
      } else {
        reviewCard
      }
    }
    .studyBackground()
    .navigationTitle(deck.name)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          showingAddCard = true
        } label: {
          Image(systemName: "plus")
        }
      }
    }
    .onAppear(perform: startSession)
    .sheet(isPresented: $showingAddCard) { addCardSheet }
  }

  private var reviewCard: some View {
    let card = queue[index]
    return VStack(spacing: 20) {
      ProgressView(value: Double(index), total: Double(queue.count))
        .tint(Theme.accent)

      Spacer()

      VStack(spacing: 16) {
        Text(showingBack ? "Answer" : "Question")
          .font(.caption.weight(.semibold))
          .foregroundStyle(Theme.textTertiary)
        Text(showingBack ? card.back : card.front)
          .font(.title2.weight(.semibold))
          .multilineTextAlignment(.center)
          .foregroundStyle(Theme.text)
      }
      .frame(maxWidth: .infinity, minHeight: 220)
      .card()
      .onTapGesture { withAnimation { showingBack.toggle() } }

      Spacer()

      if showingBack {
        gradeButtons(for: card)
      } else {
        Button("Show answer") { withAnimation { showingBack = true } }
          .buttonStyle(PrimaryButtonStyle())
      }
    }
    .padding(20)
  }

  private func gradeButtons(for card: Flashcard) -> some View {
    HStack(spacing: 10) {
      ForEach(RecallGrade.allCases) { grade in
        Button {
          SpacedRepetitionScheduler.apply(grade: grade, to: card)
          advance()
        } label: {
          VStack(spacing: 4) {
            Image(systemName: grade.icon)
            Text(grade.label).font(.caption2)
          }
          .frame(maxWidth: .infinity)
          .padding(.vertical, 12)
          .background(
            gradeColor(grade).opacity(0.18),
            in: RoundedRectangle(cornerRadius: Theme.radiusMedium, style: .continuous)
          )
          .foregroundStyle(gradeColor(grade))
        }
      }
    }
  }

  private func gradeColor(_ grade: RecallGrade) -> Color {
    switch grade {
    case .forgot: return Theme.danger
    case .hard: return Theme.warning
    case .good: return Theme.accent
    case .easy: return Theme.success
    }
  }

  private var sessionSummary: some View {
    VStack(spacing: 16) {
      Spacer()
      if deck.cards.isEmpty {
        EmptyStateView(
          icon: "rectangle.stack.badge.plus",
          title: "Empty deck",
          message: "Add a few flashcards to start a spaced-repetition session.",
          actionTitle: "Add a card"
        ) { showingAddCard = true }
      } else {
        Image(systemName: "checkmark.seal.fill")
          .font(.system(size: 54)).foregroundStyle(Theme.success)
        Text(reviewed > 0 ? "Reviewed \(reviewed) cards" : "Nothing due right now")
          .font(.title3.weight(.bold)).foregroundStyle(Theme.text)
        Text(
          reviewed > 0
            ? "They'll come back exactly when you're about to forget them."
            : "Come back later — your next reviews are scheduled."
        )
        .font(.subheadline).foregroundStyle(Theme.textSecondary)
        .multilineTextAlignment(.center).padding(.horizontal, 30)
        Button("Done") { dismiss() }
          .buttonStyle(PrimaryButtonStyle())
          .frame(maxWidth: 240)
      }
      Spacer()
    }
    .padding(20)
  }

  private var addCardSheet: some View {
    NavigationStack {
      Form {
        Section("Front") { TextField("Question", text: $front, axis: .vertical) }
        Section("Back") { TextField("Answer", text: $back, axis: .vertical) }
      }
      .navigationTitle("New card")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) { Button("Cancel") { resetCardFields() } }
        ToolbarItem(placement: .confirmationAction) {
          Button("Add") { addCard() }
            .disabled(front.trimmingCharacters(in: .whitespaces).isEmpty)
        }
      }
    }
    .presentationDetents([.medium])
  }

  private func startSession() {
    queue = SpacedRepetitionScheduler.dueCards(in: deck.cards)
    index = 0
    showingBack = false
    completed = false
    reviewed = 0
  }

  private func advance() {
    reviewed += 1
    showingBack = false
    if index + 1 < queue.count {
      withAnimation { index += 1 }
    } else {
      withAnimation { completed = true }
    }
  }

  private func addCard() {
    deck.cards.append(Flashcard(front: front, back: back))
    resetCardFields()
    startSession()
  }

  private func resetCardFields() {
    front = ""
    back = ""
    showingAddCard = false
  }
}
