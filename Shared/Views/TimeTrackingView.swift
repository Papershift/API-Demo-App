import SwiftUI
import SwiftyJSON
import HandySwiftUI

struct TimeTrackingView: View {
  enum TimeTrackingState: String {
    case running, paused
  }

  @AppStorage("userId") var userId: String = ""
  @AppStorage("username") var username: String = ""
  @AppStorage("workspaceId") var workspaceId: String = ""
  @AppStorage("avatarPath") var avatarPath: String?

  @State var ongoingRequestActionType: TimeTrackingAction?
  @State var runningTimeTrackingState: TimeTrackingState?
  @State var ongoingCurrentStateRefreshState: Bool = false

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

      HStack {
        Text("Current time tracking state is:")
        Text(runningTimeTrackingState?.rawValue.capitalized ?? "Not Running")
          .bold()
        Button(action: updateRunningTimeTracking) {
          Image(systemName: "arrow.triangle.2.circlepath")
        }
        .progressOverlay(type: .indeterminate(running: ongoingCurrentStateRefreshState))
      }

      AdaptiveStack(spacing: 20) {
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
      .buttonStyle(.bordered).controlSize(.small)
      .padding()
    }
    .task {
      // fetches the running time tracking once when this view appears
      await fetchRunningTimeTracking()
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
    await fetchRunningTimeTracking()
    ongoingRequestActionType = nil
  }

  func updateRunningTimeTracking() {
    Task {
      ongoingCurrentStateRefreshState = true
      await fetchRunningTimeTracking()
      ongoingCurrentStateRefreshState = false
    }
  }

  func fetchRunningTimeTracking() async {
    // send GET to /api/v3/workspaces/:workspace_id:/time_trackings endpoint with filter[running]=1
    let endpoint = PapershiftEndpoint.fetchRunningTimeTrackings(workspaceId: workspaceId)
    let responseData = try! await papershiftApi.rawDataResponse(on: endpoint).get()
    let responseJson = try! JSON(data: responseData)

    // get running time tracking state & update state
    let runningTimeTrackings = responseJson["data"].arrayValue

    if runningTimeTrackings.isEmpty {
      runningTimeTrackingState = nil
    } else {
      runningTimeTrackingState = .running

      // check if there's any running break
      if
        responseJson["included"].arrayValue
          .contains(where: { $0["type"] == "break" && $0["attributes"]["ends_at"].string == nil })
      {
        runningTimeTrackingState = .paused
      }
    }
  }
}

struct TimeTrackingView_Previews: PreviewProvider {
  static var previews: some View {
    TimeTrackingView()
  }
}
