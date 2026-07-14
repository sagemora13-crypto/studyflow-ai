import Foundation

/// Recall grade the student gives after seeing a card's answer.
enum RecallGrade: Int, CaseIterable, Identifiable {
  case forgot = 0
  case hard = 1
  case good = 2
  case easy = 3

  var id: Int { rawValue }

  var label: String {
    switch self {
    case .forgot: return "Forgot"
    case .hard: return "Hard"
    case .good: return "Good"
    case .easy: return "Easy"
    }
  }

  var icon: String {
    switch self {
    case .forgot: return "xmark"
    case .hard: return "tortoise"
    case .good: return "checkmark"
    case .easy: return "hare"
    }
  }

  /// SM-2 quality value (0...5).
  var quality: Int {
    switch self {
    case .forgot: return 1
    case .hard: return 3
    case .good: return 4
    case .easy: return 5
    }
  }
}

/// On-device SM-2 style spaced-repetition engine.
/// Structured as pure functions so it is easy to test and swap later.
enum SpacedRepetitionScheduler {

  /// Applies a recall grade to a flashcard, updating its SM-2 state in place.
  static func apply(grade: RecallGrade, to card: Flashcard, now: Date = .now) {
    card.timesSeen += 1
    card.lastReviewed = now
    card.difficulty = grade.rawValue

    let quality = grade.quality

    if quality < 3 {
      // Failed recall: reset repetitions, resurface soon.
      card.repetitions = 0
      card.intervalDays = 0
      card.timesMissed += 1
      card.dueDate = minutesFromNow(10, now: now)
    } else {
      // Successful recall: advance the schedule.
      let newEase = updatedEaseFactor(current: card.easeFactor, quality: quality)
      card.easeFactor = newEase

      switch card.repetitions {
      case 0: card.intervalDays = 1
      case 1: card.intervalDays = 6
      default: card.intervalDays = Int((Double(card.intervalDays) * newEase).rounded())
      }
      card.repetitions += 1
      card.dueDate = daysFromNow(card.intervalDays, now: now)
    }
  }

  /// SM-2 ease-factor update, floored at 1.3.
  static func updatedEaseFactor(current: Double, quality: Int) -> Double {
    let q = Double(quality)
    let updated = current + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
    return max(1.3, updated)
  }

  /// Returns the due cards from a deck, most overdue first.
  static func dueCards(in cards: [Flashcard], now: Date = .now) -> [Flashcard] {
    cards
      .filter { $0.dueDate <= now }
      .sorted { $0.dueDate < $1.dueDate }
  }

  private static func daysFromNow(_ days: Int, now: Date) -> Date {
    Calendar.current.date(byAdding: .day, value: max(days, 0), to: now) ?? now
  }

  private static func minutesFromNow(_ minutes: Int, now: Date) -> Date {
    Calendar.current.date(byAdding: .minute, value: minutes, to: now) ?? now
  }
}
