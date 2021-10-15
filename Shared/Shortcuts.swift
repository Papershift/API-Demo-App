import Foundation
import Intents

enum Shortcuts {
  static func provideActionsToSystem() {
    provideStartTimeTrackingIntent()
    provideStartBreakIntent()
    provideEndBreakIntent()
    provideEndTimeTrackingIntent()
  }

  static func removeAll() {
    INInteraction.deleteAll(completion: nil)
  }

  private static func provideStartTimeTrackingIntent() {
    let intent = StartTimeTrackingIntent()
    let interaction = INInteraction(intent: intent, response: nil)
    interaction.donate(completion: nil)
  }

  private static func provideStartBreakIntent() {
    let intent = StartBreakIntent()
    let interaction = INInteraction(intent: intent, response: nil)
    interaction.donate(completion: nil)
  }

  private static func provideEndBreakIntent() {
    let intent = EndBreakIntent()
    let interaction = INInteraction(intent: intent, response: nil)
    interaction.donate(completion: nil)
  }

  private static func provideEndTimeTrackingIntent() {
    let intent = EndTimeTrackingIntent()
    let interaction = INInteraction(intent: intent, response: nil)
    interaction.donate(completion: nil)
  }
}
