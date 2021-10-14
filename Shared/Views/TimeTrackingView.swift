import SwiftUI

struct TimeTrackingView: View {
  @AppStorage("userId") var userId: String = ""
  @AppStorage("username") var username: String = ""
  @AppStorage("avatarPath") var avatarPath: String?

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
          Label("Start", systemImage: "play.fill")
        }

        Button(action: sendPauseAction) {
          Label("Pause", systemImage: "pause.fill")
        }

        Button(action: sendContinueAction) {
          Label("Continue", systemImage: "playpause.fill")
        }

        Button(action: sendStopAction) {
          Label("Stop", systemImage: "stop.fill")
        }
      }
    }
  }

  var avatarUrl: URL? {
    guard let avatarPath = avatarPath else { return nil }
    return URL(string: "https://app.papershift.com")!.appendingPathComponent(avatarPath)
  }

  func sendStartAction() {
    Task { await sendTimeTrackingAction(action: .start) }
  }

  func sendStopAction() {
    Task { await sendTimeTrackingAction(action: .end) }
  }

  func sendPauseAction() {
    Task { await sendTimeTrackingAction(action: .startBreak) }
  }

  func sendContinueAction() {
    Task { await sendTimeTrackingAction(action: .endBreak) }
  }

  func sendTimeTrackingAction(action: TimeTrackingAction) async {
    // TODO: [cg_2021-10-14] not yet implemented
  }
}

struct TimeTrackingView_Previews: PreviewProvider {
  static var previews: some View {
    TimeTrackingView()
  }
}
