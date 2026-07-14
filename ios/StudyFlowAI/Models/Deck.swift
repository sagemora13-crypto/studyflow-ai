import Foundation
import SwiftData

@Model
final class Deck {
  var name: String
  var subject: String
  var createdAt: Date
  @Relationship(deleteRule: .cascade) var cards: [Flashcard]

  init(name: String, subject: String, cards: [Flashcard] = []) {
    self.name = name
    self.subject = subject
    self.createdAt = .now
    self.cards = cards
  }

  var mastery: Double {
    guard !cards.isEmpty else { return 0 }
    let total = cards.reduce(0.0) { $0 + $1.masteryFraction }
    return total / Double(cards.count)
  }

  var dueCount: Int {
    cards.filter { $0.isDue }.count
  }
}

/// Flashcard with SM-2 spaced-repetition state.
@Model
final class Flashcard {
  var front: String
  var back: String
  var difficulty: Int  // last self-rated difficulty 0...3

  // SM-2 scheduler state
  var repetitions: Int
  var easeFactor: Double
  var intervalDays: Int
  var dueDate: Date
  var lastReviewed: Date?
  var timesMissed: Int
  var timesSeen: Int

  init(front: String, back: String) {
    self.front = front
    self.back = back
    self.difficulty = 1
    self.repetitions = 0
    self.easeFactor = 2.5
    self.intervalDays = 0
    self.dueDate = .now
    self.lastReviewed = nil
    self.timesMissed = 0
    self.timesSeen = 0
  }

  var isDue: Bool { dueDate <= .now }

  /// Mastery estimate 0...1 based on repetitions and interval strength.
  var masteryFraction: Double {
    let repScore = min(Double(repetitions) / 5.0, 1.0)
    let intervalScore = min(Double(intervalDays) / 21.0, 1.0)
    return (repScore * 0.6) + (intervalScore * 0.4)
  }
}
