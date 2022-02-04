import Foundation

let AuthReducer = Reducer<AuthAction, AuthState>.reduce { action, state in
  switch action {
    case .viewOnAppear:
      break
    case .viewOnDisappear:
      break
    case .requestLogin:
      break
    case .responeLogin(let result):
      break
    case .changeRootScreen(_):
      break
    default:
      break
  }
}
