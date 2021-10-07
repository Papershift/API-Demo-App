import Foundation
import Microya

enum PapershiftEndpoint {
  case signIn(request: SignInRequest)
  case timeTrackingAction(workspaceId: String, request: TimeTrackingActionRequest)
  case paginated(endpoint: PaginatedEndpoint, page: Int)

  enum PaginatedEndpoint {
    case workspaces(accountId: String)
    case timeTrackings(workspaceId: String)
  }
}

// MARK: -  Request Data Types
struct SignInRequest: Encodable {
  let email: String
  let password: String
}

struct TimeTrackingActionRequest: Encodable {
  let actionType: TimeTrackingAction
  let deviceId: String
  let actionTime: Date
  let userId: String
}

enum TimeTrackingAction: String, Codable {
  case start = "start"
  case startBreak = "start-break"
  case endBreak = "end-break"
  case end = "end"
}

struct ApiRequestWrapper<ObjectType: Encodable>: Encodable {
  let data: DataRequestWrapper<ObjectType>
}

struct DataRequestWrapper<ObjectType: Encodable>: Encodable {
  public let type: String
  public let attributes: ObjectType
}

// MARK: - Endpoint Details
extension PapershiftEndpoint: Endpoint {
  var subpath: String {
    switch self {
    case .signIn:
      return "/sign_in"

    case let .timeTrackingAction(workspaceId, _):
      return "/workspaces/\(workspaceId)/time_trackings/actions"

    case let .paginated(.workspaces(accountId), _):
      return "/accounts/\(accountId)/workspaces"

    case let .paginated(.timeTrackings(workspaceId), _):
      return "/workspaces/\(workspaceId)/time_trackings"
    }
  }

  var method: HttpMethod {
    switch self {
    case let .signIn(request):
      return .post(body: try! encoder.encode(wrapped(request, type: "user")))

    case let .timeTrackingAction(_, request):
      return .post(body: try! encoder.encode(wrapped(request, type: "action")))

    case .paginated:
      return .get
    }
  }

  var queryParameters: [String: QueryParameterValue] {
    switch self {
    case let .paginated(_, page):
      return ["page": .string(String(page))]

    default:
      return [:]
    }
  }

  func wrapped<RequestType: Encodable>(_ request: RequestType, type: String) -> ApiRequestWrapper<RequestType> {
    ApiRequestWrapper(data: DataRequestWrapper(type: type, attributes: request))
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

// MARK: - Response Data Types
// TODO: [cg_2021-10-07] not yet implemented
