import Foundation

class AuthMiddleware: MiddlewareProtocol {
  typealias InputActionType = AuthAction
  
  typealias OutputActionType = AuthAction
  
  typealias StateType = AuthState
  
  func handle(action: InputActionType, from dispatcher: ActionSource, state: @escaping GetState<StateType>) -> IO<OutputActionType> {
    let io = IO<OutputActionType> { output in
      let state = state()
      print(state)
      switch action {
      case .requestLogin:
        output.dispatch(.changeRootScreen(.main))
      default:
        break
      }
    }
    return io
  }
}
