import SwiftUI
import SwiftyJSON
import HandySwiftUI

struct LoginView: View {
  @State var email: String = ""
  @State var password: String = ""

  @State var requestIsOngoing: Bool = false

  @AppStorage("userId") var userId: String?
  @AppStorage("username") var username: String?
  @AppStorage("avatarPath") var avatarPath: String?
  @AppStorage("accountId") var accountId: String?
  @AppStorage("workspaceId") var workspaceId: String?

  @AppStorage("signedIn") var signedIn: Bool?
  @AppStorage("bearerToken") var bearerToken: String?
  
  var body: some View {
    Form {
      Section {
        TextField("Email", text: $email)
          .textContentType(.username)

        SecureField("Password", text: $password)
          .textContentType(.password)
          .onSubmit { login() }
      }

      Button("Login", action: login)
        .progressOverlay(type: .indeterminate(running: requestIsOngoing))
    }
  }

  func login() {
    Task {
      requestIsOngoing = true
      await performSignIn()
      await fetchCurrentUser()
      requestIsOngoing = false
    }
  }
  
  func performSignIn() async {
    // send POST to /api/v3/sign_in endpoint
    let request = SignInRequest(email: email, password: password)
    let endpoint = PapershiftEndpoint.signIn(request: request)
    let responseData = try! await papershiftApi.rawDataResponse(on: endpoint).get()
    let responseJson = try! JSON(data: responseData)
    
    // get HTTP Bearer access token & persist for future requests
    bearerToken = responseJson["data"]["attributes"]["access_token"].stringValue
  }
  
  func fetchCurrentUser() async {
    // send GET to /api/v3/users/me endpoint
    let endpoint = PapershiftEndpoint.fetchCurrentUser
    let responseData = try! await papershiftApi.rawDataResponse(on: endpoint).get()
    let responseJson = try! JSON(data: responseData)
    
    // get user id, name and avatar URL & persist for future usage
    userId = responseJson["data"]["id"].stringValue
    username = responseJson["data"]["attributes"]["username"].stringValue
    avatarPath = responseJson["data"]["attributes"]["avatar"].stringValue
    
    // get account ID and workspace ID from relationships & persist for future usage
    accountId = responseJson["data"]["relationships"]["account"]["data"]["id"].stringValue
    workspaceId = responseJson["data"]["relationships"]["workspaces"]["data"].arrayValue[0]["id"].stringValue
    
    // set app to signed in mode
    signedIn = true
  }
}

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    LoginView()
  }
}
