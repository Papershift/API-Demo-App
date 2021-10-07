import SwiftUI

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
        // TODO: [cg_2021-10-07] not yet implemented
      }
    }
  }
}

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    LoginView()
  }
}
