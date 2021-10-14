import SwiftUI

struct TimeTrackingView: View {
  @AppStorage("userId") var userId: String = ""
  @AppStorage("username") var username: String = ""
  @AppStorage("workspaceId") var workspaceId: String = ""
  @AppStorage("avatarPath") var avatarPath: String?

  @State var ongoingRequestActionType: TimeTrackingAction?

  var body: some View {
    VStack {
      HStack {
        AsyncImage(
          url: avatarUrl,
          content: { image in
            image.resizable()
              .aspectRatio(contentMode: .fill)
              .frame(width: 50, height: 50)
              .cornerRadius(25)
              .clipped()
          },
          placeholder: {
            ProgressView()
          }
        )
          .padding()

        Text("Hi, \(username)!")
          .font(.title)
      }

      HStack {
        Button(action: sendStartAction) {
          if ongoingRequestActionType == .start {
            ProgressView()
          } else {
            Label("Start", systemImage: "play.fill")
          }
        }

        Button(action: sendPauseAction) {
          if ongoingRequestActionType == .startBreak {
            ProgressView()
          } else {
            Label("Pause", systemImage: "pause.fill")
          }
        }

        Button(action: sendContinueAction) {
          if ongoingRequestActionType == .endBreak {
            ProgressView()
          } else {
            Label("Continue", systemImage: "playpause.fill")
          }
        }

        Button(action: sendStopAction) {
          if ongoingRequestActionType == .end {
            ProgressView()
          } else {
            Label("Stop", systemImage: "stop.fill")
          }
        }
      }
    }
  }

  var avatarUrl: URL? {
    guard let avatarPath = avatarPath else { return nil }
    return URL(string: "https://app.papershift.com")!.appendingPathComponent(avatarPath)
  }

  func sendStartAction() {
    Task { await sendTimeTrackingAction(actionType: .start) }
  }

  func sendStopAction() {
    Task { await sendTimeTrackingAction(actionType: .end) }
  }

  func sendPauseAction() {
    Task { await sendTimeTrackingAction(actionType: .startBreak) }
  }

  func sendContinueAction() {
    Task { await sendTimeTrackingAction(actionType: .endBreak) }
  }

  func sendTimeTrackingAction(actionType: TimeTrackingAction) async {
    // send POST to /api/v3/workspaces/:workspace_id:/time_trackings/actions endpoint
    let request = TimeTrackingActionRequest(actionType: actionType, actionTime: Date.now, userId: Int(userId)!)
    let endpoint = PapershiftEndpoint.sendTimeTrackingAction(workspaceId: workspaceId, request: request)

    ongoingRequestActionType = actionType
    do {
      _ = try await papershiftApi.rawDataResponse(on: endpoint).get()
    } catch {
      print(error)
    }
    ongoingRequestActionType = nil
  }
}

struct TimeTrackingView_Previews: PreviewProvider {
  static var previews: some View {
    TimeTrackingView()
  }
}
