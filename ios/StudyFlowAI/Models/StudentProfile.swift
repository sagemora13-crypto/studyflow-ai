import Foundation
import SwiftData

/// The single student profile for this device (local-first, offline).
@Model
final class StudentProfile {
  var name: String
  var gradeLevel: Int
  var subjects: [String]
  var struggleAreas: [String]
  var goal: String
  var learningStyle: String
  var dailyStudyMinutes: Int
  var isPremium: Bool
  var points: Int
  var currentStreak: Int
  var longestStreak: Int
  var lastStudyDay: Date?
  var createdAt: Date

  // Free-tier usage tracking
  var aiQuestionsUsedToday: Int
  var aiUsageDay: Date
  var scansUsedThisMonth: Int

  init(
    name: String = "",
    gradeLevel: Int = 9,
    subjects: [String] = [],
    struggleAreas: [String] = [],
    goal: String = "",
    learningStyle: String = "Balanced",
    dailyStudyMinutes: Int = 30
  ) {
    self.name = name
    self.gradeLevel = gradeLevel
    self.subjects = subjects
    self.struggleAreas = struggleAreas
    self.goal = goal
    self.learningStyle = learningStyle
    self.dailyStudyMinutes = dailyStudyMinutes
    self.isPremium = false
    self.points = 0
    self.currentStreak = 0
    self.longestStreak = 0
    self.lastStudyDay = nil
    self.createdAt = .now
    self.aiQuestionsUsedToday = 0
    self.aiUsageDay = .now
    self.scansUsedThisMonth = 0
  }
}

enum LearningStyle: String, CaseIterable, Identifiable {
  case visual = "Visual"
  case reading = "Reading"
  case handsOn = "Hands-on"
  case balanced = "Balanced"
  var id: String { rawValue }
  var icon: String {
    switch self {
    case .visual: return "eye"
    case .reading: return "book"
    case .handsOn: return "hand.raised"
    case .balanced: return "circle.grid.2x2"
    }
  }
}

enum Subject: String, CaseIterable, Identifiable {
  case math = "Math"
  case science = "Science"
  case english = "English"
  var id: String { rawValue }
  var icon: String {
    switch self {
    case .math: return "function"
    case .science: return "atom"
    case .english: return "text.book.closed"
    }
  }
}
