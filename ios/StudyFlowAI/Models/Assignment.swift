import Foundation
import SwiftData

@Model
final class Assignment {
  var title: String
  var subject: String
  var dueDate: Date
  var difficulty: Int  // 1...3
  var estimatedMinutes: Int
  var priority: Int  // 1 low ... 3 high
  var isDone: Bool
  var createdAt: Date
  @Relationship(deleteRule: .cascade) var steps: [AssignmentStep]

  init(
    title: String,
    subject: String,
    dueDate: Date,
    difficulty: Int = 2,
    estimatedMinutes: Int = 30,
    priority: Int = 2,
    isDone: Bool = false,
    steps: [AssignmentStep] = []
  ) {
    self.title = title
    self.subject = subject
    self.dueDate = dueDate
    self.difficulty = difficulty
    self.estimatedMinutes = estimatedMinutes
    self.priority = priority
    self.isDone = isDone
    self.createdAt = .now
    self.steps = steps
  }
}

@Model
final class AssignmentStep {
  var detail: String
  var dayOffset: Int
  var isDone: Bool
  init(detail: String, dayOffset: Int, isDone: Bool = false) {
    self.detail = detail
    self.dayOffset = dayOffset
    self.isDone = isDone
  }
}

@Model
final class TestDate {
  var subject: String
  var title: String
  var date: Date
  init(subject: String, title: String, date: Date) {
    self.subject = subject
    self.title = title
    self.date = date
  }
}
