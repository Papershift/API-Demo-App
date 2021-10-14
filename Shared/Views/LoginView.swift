import SwiftUI
import SwiftyJSON

struct LoginView: View {
  @State var email: String = ""
  @State var password: String = ""
  
  var body: some View {
    Form {
      Section {
        TextField("Email", text: $email)
          .textContentType(.username)
        
        SecureField("Password", text: $password)
          .textContentType(.password)
      }
      
      Button("Login") {
        Task {
          await performSignIn()
          await fetchCurrentUser()
        }
      }
    }
  }
  
  func performSignIn() async {
    // send POST to /api/v3/sign_in endpoint
    let request = SignInRequest(email: email, password: password)
    let endpoint = PapershiftEndpoint.signIn(request: request)
    let responseData = try! await papershiftApi.rawDataResponse(on: endpoint).get()
    let responseJson = try! JSON(data: responseData)
    
    // get HTTP Bearer access token & persist for future requests
    let bearerToken = responseJson["data"]["attributes"]["access_token"].stringValue
    UserDefaults.standard.set(bearerToken, forKey: "bearerToken")
  }
  
  func fetchCurrentUser() async {
    // send GET to /api/v3/users/me endpoint
    let endpoint = PapershiftEndpoint.fetchCurrentUser
    let responseData = try! await papershiftApi.rawDataResponse(on: endpoint).get()
    let responseJson = try! JSON(data: responseData)
    
    // get user id, name and avatar URL & persist for future usage
    let userId = responseJson["data"]["id"].stringValue
    let username = responseJson["data"]["attributes"]["username"].stringValue
    let avatarPath = responseJson["data"]["attributes"]["avatar"].stringValue
    
    UserDefaults.standard.set(userId, forKey: "userId")
    UserDefaults.standard.set(username, forKey: "username")
    UserDefaults.standard.set(avatarPath, forKey: "avatarPath")
    
    // get account ID and workspace ID from relationships & persist for future usage
    let accountId = responseJson["data"]["relationships"]["account"]["data"]["id"].stringValue
    let workspaceId = responseJson["data"]["relationships"]["workspaces"]["data"].arrayValue[0]["id"].stringValue
    
    UserDefaults.standard.set(accountId, forKey: "accountId")
    UserDefaults.standard.set(workspaceId, forKey: "workspaceId")
    
    // set app to signed in mode
    UserDefaults.standard.set(true, forKey: "signedIn")
  }
}

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    LoginView()
  }
}
