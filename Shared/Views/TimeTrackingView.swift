import SwiftUI
import HandySwiftUI

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
              .cornerRadius(25)
              .clipped()
          },
          placeholder: {
            ProgressView()
          }
        )
          .frame(width: 50, height: 50)

        Text("Hi, \(username)!")
          .font(.title)
      }
      .padding()

      Spacer()

      AdaptiveStack {
        Button(action: sendStartAction) {
          Label("Start", systemImage: "play.fill")
        }
        .buttonStyle(.borderedProminent).controlSize(.large)
        .progressOverlay(type: .indeterminate(running: ongoingRequestActionType == .start))

        Button(action: sendPauseAction) {
          Label("Pause", systemImage: "pause.fill")
        }
        .buttonStyle(.bordered).controlSize(.large)
        .progressOverlay(type: .indeterminate(running: ongoingRequestActionType == .startBreak))

        Button(action: sendContinueAction) {
          Label("Continue", systemImage: "playpause.fill")
        }
        .buttonStyle(.bordered).controlSize(.large)
        .progressOverlay(type: .indeterminate(running: ongoingRequestActionType == .endBreak))

        Button(action: sendStopAction) {
          Label("Stop", systemImage: "stop.fill")
        }
        .buttonStyle(.borderedProminent).controlSize(.large)
        .progressOverlay(type: .indeterminate(running: ongoingRequestActionType == .end))
      }
      .padding()

      Spacer()

      Button(action: logout) {
        Label("Logout", systemImage: "person.fill.xmark")
      }
      .tint(.systemRed)
      .buttonStyle(.bordered).controlSize(.mini)
      .padding()
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

  func logout() {
    for key in ["signedIn", "userId", "username", "accountId", "workspaceId", "avatarPath"] {
      UserDefaults.standard.removeObject(forKey: key)
    }
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
