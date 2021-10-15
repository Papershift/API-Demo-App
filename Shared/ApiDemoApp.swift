import SwiftUI

@main
struct ApiDemoApp: App {
  @AppStorage("signedIn") var signedIn: Bool = false
  
  var body: some Scene {
    WindowGroup {
      if signedIn {
        TimeTrackingView()
          .platformSpecificPadding()
          .frame(minWidth: 500, minHeight: 220)
      } else {
        LoginView()
          .platformSpecificPadding()
          .frame(minWidth: 400, minHeight: 150)
      }
    }
  }
}
