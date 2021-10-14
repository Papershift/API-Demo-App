import SwiftUI

@main
struct ApiDemoApp: App {
  @AppStorage("userId") var userId: String?
  @AppStorage("username") var username: String?

  var body: some Scene {
    WindowGroup {
      if userId != nil && username != nil {
        TimeTrackingView()
          .platformSpecificPadding()
      } else {
        LoginView()
          .platformSpecificPadding()
      }
    }
  }
}
