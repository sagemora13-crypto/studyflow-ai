import Foundation
import SwiftData

@Model
final class QuizResult {
  var topic: String
  var subject: String
  var scorePercent: Int
  var totalQuestions: Int
  var correctCount: Int
  var weakTopics: [String]
  var date: Date

  init(
    topic: String, subject: String, scorePercent: Int, totalQuestions: Int, correctCount: Int,
    weakTopics: [String] = []
  ) {
    self.topic = topic
    self.subject = subject
    self.scorePercent = scorePercent
    self.totalQuestions = totalQuestions
    self.correctCount = correctCount
    self.weakTopics = weakTopics
    self.date = .now
  }
}

@Model
final class StudySession {
  var subject: String
  var activity: String  // e.g. "Flashcards", "Focus timer", "Quiz"
  var minutes: Int
  var focusRating: Int  // 0 none, 1 distracted ... 3 very focused
  var date: Date

  init(subject: String, activity: String, minutes: Int, focusRating: Int = 0) {
    self.subject = subject
    self.activity = activity
    self.minutes = minutes
    self.focusRating = focusRating
    self.date = .now
  }
}

@Model
final class StudyGuide {
  var title: String
  var subject: String
  var mainIdeas: [String]
  var vocabulary: [String]
  var formulas: [String]
  var sampleQuestions: [String]
  var createdAt: Date

  init(
    title: String, subject: String, mainIdeas: [String] = [], vocabulary: [String] = [],
    formulas: [String] = [], sampleQuestions: [String] = []
  ) {
    self.title = title
    self.subject = subject
    self.mainIdeas = mainIdeas
    self.vocabulary = vocabulary
    self.formulas = formulas
    self.sampleQuestions = sampleQuestions
    self.createdAt = .now
  }
}

@Model
final class EarnedBadge {
  var name: String
  var detail: String
  var icon: String
  var earnedAt: Date
  init(name: String, detail: String, icon: String) {
    self.name = name
    self.detail = detail
    self.icon = icon
    self.earnedAt = .now
  }
}
