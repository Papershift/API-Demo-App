import SwiftUI

@main
struct ApiDemoApp: App {
  @AppStorage("signedIn") var signedIn: Bool = false
  
  var body: some Scene {
    WindowGroup {
      if signedIn {
        TimeTrackingView()
          .platformSpecificPadding()
      } else {
        LoginView()
          .platformSpecificPadding()
      }
    }
  }
}
