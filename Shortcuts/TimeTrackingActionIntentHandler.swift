import Foundation
import Microya

class TimeTrackingActionIntentHandler: NSObject {
  /// Returns `true` if action was sent successfully, else `false`.
  func handleTimeTrackingAction(actionType: TimeTrackingAction) async -> Bool {
    guard
      let userId = sharedUserDefaults.string(forKey: "userId"),
      let userIdInt = Int(userId),
      let workspaceId = sharedUserDefaults.string(forKey: "workspaceId")
    else {
      return false
    }

    let request = TimeTrackingActionRequest(actionType: actionType, actionTime: .now, userId: userIdInt)
    let endpoint = PapershiftEndpoint.sendTimeTrackingAction(workspaceId: workspaceId, request: request)

    switch await papershiftApi.rawDataResponse(on: endpoint) {
    case .success:
      return true

    case .failure:
      return false
    }
  }
}

extension TimeTrackingActionIntentHandler: StartTimeTrackingIntentHandling {
  func handle(intent: StartTimeTrackingIntent) async -> StartTimeTrackingIntentResponse {
    .init(code: await handleTimeTrackingAction(actionType: .start) ? .success : .failure, userActivity: nil)
  }
}

extension TimeTrackingActionIntentHandler: StartBreakIntentHandling {
  func handle(intent: StartBreakIntent) async -> StartBreakIntentResponse {
    .init(code: await handleTimeTrackingAction(actionType: .startBreak) ? .success : .failure, userActivity: nil)
  }
}

extension TimeTrackingActionIntentHandler: EndBreakIntentHandling {
  func handle(intent: EndBreakIntent) async -> EndBreakIntentResponse {
    .init(code: await handleTimeTrackingAction(actionType: .endBreak) ? .success : .failure, userActivity: nil)
  }
}

extension TimeTrackingActionIntentHandler: EndTimeTrackingIntentHandling {
  func handle(intent: EndTimeTrackingIntent) async -> EndTimeTrackingIntentResponse {
    .init(code: await handleTimeTrackingAction(actionType: .end) ? .success : .failure, userActivity: nil)
  }
}
