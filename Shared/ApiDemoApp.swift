import SwiftUI

@main
struct ApiDemoApp: App {
  var body: some Scene {
    WindowGroup {
      LoginView()
        .platformSpecificPadding()
    }
  }
}
