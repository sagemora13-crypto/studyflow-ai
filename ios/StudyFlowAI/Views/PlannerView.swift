import SwiftData
import SwiftUI

struct PlannerView: View {
  @Environment(\.modelContext) private var context
  @Query(sort: \Assignment.dueDate) private var assignments: [Assignment]

  @State private var showingNew = false

  var body: some View {
    Group {
      NavigationStack {
        ScrollView {
          VStack(alignment: .leading, spacing: 16) {
            if assignments.isEmpty {
              EmptyStateView(
                icon: "calendar",
                title: "Nothing planned",
                message:
                  "Add an assignment and StudyFlow keeps it front and center until it's done.",
                actionTitle: "Add assignment"
              ) { showingNew = true }
            } else {
              ForEach(assignments) { item in
                assignmentCard(item)
              }
            }
          }
          .padding(20)
        }
        .studyBackground()
        .navigationTitle("Planner")
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) {
            Button {
              showingNew = true
            } label: {
              Image(systemName: "plus")
            }
          }
        }
        .sheet(isPresented: $showingNew) { NewAssignmentSheet() }
      }
    }
    .__tenxTrackView("PlannerView")
  }

  private func assignmentCard(_ item: Assignment) -> some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack {
        TagPill(text: item.subject, color: Theme.subjectColor(item.subject))
        Spacer()
        Text(item.dueDate, format: .dateTime.weekday().month().day())
          .font(.caption).foregroundStyle(Theme.textSecondary)
      }
      HStack(spacing: 12) {
        Button {
          item.isDone.toggle()
        } label: {
          Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
            .font(.title3)
            .foregroundStyle(item.isDone ? Theme.success : Theme.textTertiary)
        }
        .buttonStyle(.plain)
        Text(item.title)
          .font(.headline)
          .strikethrough(item.isDone)
          .foregroundStyle(item.isDone ? Theme.textSecondary : Theme.text)
        Spacer()
      }
      if !item.steps.isEmpty {
        VStack(alignment: .leading, spacing: 6) {
          ForEach(item.steps) { step in
            Button {
              step.isDone.toggle()
            } label: {
              HStack(spacing: 8) {
                Image(systemName: step.isDone ? "checkmark.square.fill" : "square")
                  .foregroundStyle(step.isDone ? Theme.accent : Theme.textTertiary)
                Text(step.detail)
                  .font(.caption)
                  .foregroundStyle(Theme.textSecondary)
                Spacer(minLength: 0)
              }
            }
            .buttonStyle(.plain)
          }
        }
        .padding(.leading, 4)
      }
      Text("\(item.estimatedMinutes) min · \(difficultyLabel(item.difficulty))")
        .font(.caption2).foregroundStyle(Theme.textTertiary)
    }
    .card()
    .swipeActions {
      Button(role: .destructive) {
        context.delete(item)
      } label: {
        Label("Delete", systemImage: "trash")
      }
    }
  }

  private func difficultyLabel(_ d: Int) -> String {
    switch d {
    case 1: return "Easy"
    case 3: return "Hard"
    default: return "Medium"
    }
  }
}

struct NewAssignmentSheet: View {
  @Environment(\.modelContext) private var context
  @Environment(\.dismiss) private var dismiss

  @State private var title = ""
  @State private var subject = "Math"
  @State private var dueDate = Date().addingTimeInterval(86_400)
  @State private var difficulty = 2
  @State private var minutes = 30

  var body: some View {
    NavigationStack {
      Form {
        Section("Assignment") {
          TextField("Title", text: $title)
          Picker("Subject", selection: $subject) {
            ForEach(Subject.allCases) { Text($0.rawValue).tag($0.rawValue) }
          }
          DatePicker("Due", selection: $dueDate, displayedComponents: .date)
        }
        Section("Effort") {
          Picker("Difficulty", selection: $difficulty) {
            Text("Easy").tag(1)
            Text("Medium").tag(2)
            Text("Hard").tag(3)
          }
          Stepper("\(minutes) min", value: $minutes, in: 10...180, step: 5)
        }
      }
      .navigationTitle("New assignment")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
        ToolbarItem(placement: .confirmationAction) {
          Button("Save") { save() }
            .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
        }
      }
    }
  }

  private func save() {
    context.insert(
      Assignment(
        title: title, subject: subject, dueDate: dueDate, difficulty: difficulty,
        estimatedMinutes: minutes, priority: difficulty))
    dismiss()
  }
}
