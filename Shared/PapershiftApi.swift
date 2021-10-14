import Foundation
import Microya

let papershiftApi = ApiProvider<PapershiftEndpoint>(
  baseUrl: URL(string: "https://papershift-web.herokuapp.com/api/v3")!,
  plugins: [
    HttpAuthPlugin(
      scheme: .bearer,
      tokenClosure: { UserDefaults.standard.string(forKey: "bearerToken") }
    ),
    RequestLoggerPlugin { request in
      print(request)

      if let body = request.httpBody?.prettyPrintedJsonString {
        print("Body:\n", body)
      }
    },
    ResponseLoggerPlugin { response in
      print(response)

      if let body = response.data?.prettyPrintedJsonString {
        print("Body:\n", body)
      }
    },
  ]
)

enum PapershiftEndpoint {
  case signIn(request: SignInRequest)
  case fetchCurrentUser
  case sendTimeTrackingAction(workspaceId: String, request: TimeTrackingActionRequest)
  case fetchTimeTrackings(workspaceId: String, page: Int)
}

// MARK: -  Request Data Types
struct SignInRequest: Encodable {
  let email: String
  let password: String
}

struct TimeTrackingActionRequest: Encodable {
  let actionType: TimeTrackingAction
  let deviceId: String = UUID().uuidString
  let actionTime: Date
  let userId: Int
}

enum TimeTrackingAction: String, Codable {
  case start = "start"
  case startBreak = "start-break"
  case endBreak = "end-break"
  case end = "end"
}

struct JsonApiWrapper<ObjectType: Encodable>: Encodable {
  let data: DataWrapper<ObjectType>
}

struct DataWrapper<ObjectType: Encodable>: Encodable {
  public let type: String
  public let attributes: ObjectType
}

// MARK: - Endpoint Details
extension PapershiftEndpoint: Endpoint {
  var subpath: String {
    switch self {
    case .signIn:
      return "/sign_in"
      
    case .fetchCurrentUser:
      return "/users/me"
      
    case .sendTimeTrackingAction(let workspaceId, _):
      return "/workspaces/\(workspaceId)/time_trackings/actions"
      
    case .fetchTimeTrackings(let workspaceId, _):
      return "/workspaces/\(workspaceId)/time_trackings"
    }
  }
  
  var method: HttpMethod {
    switch self {
    case .signIn(let request):
      return .post(body: try! encoder.encode(wrapped(request, type: "user")))
      
    case .sendTimeTrackingAction(_, let request):
      return .post(body: try! encoder.encode(wrapped(request, type: "action")))
      
    case .fetchCurrentUser, .fetchTimeTrackings:
      return .get
    }
  }
  
  var queryParameters: [String: QueryParameterValue] {
    switch self {
    case .fetchTimeTrackings(_, let page):
      return ["page": .string(String(page))]
      
    default:
      return [:]
    }
  }
  
  var headers: [String: String] {
    [
      "Accept-Language": "\(Locale.current.languageCode ?? "en")",
      "Content-Type": "application/vnd.api+json"
    ]
  }

  public var decoder: JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }

  public var encoder: JSONEncoder {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.keyEncodingStrategy = .convertToSnakeCase
    return encoder
  }
  
  func wrapped<RequestType: Encodable>(_ request: RequestType, type: String) -> JsonApiWrapper<RequestType> {
    JsonApiWrapper(data: DataWrapper(type: type, attributes: request))
  }
  
  typealias ClientErrorType = PapershiftError
}

struct PapershiftError: Decodable {
  public let errors: [ErrorResponse]
  
  public struct ErrorResponse: Decodable {
    let status: String
    let title: String
  }
}

extension Data {
  /// Use for logging received JSON formatted data.
  var prettyPrintedJsonString: String? {
    guard
      let object = try? JSONSerialization.jsonObject(with: self, options: []),
      let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted])
    else { return nil }

    return String(data: data, encoding: .utf8)
  }
}
