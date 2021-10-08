import Foundation
import SwiftRex

class AuthMiddleware: Middleware {
  private var output: AnyActionHandler<AuthAction>?
  private var getState: GetState<AuthState>?
  func receiveContext(getState: @escaping GetState<AuthState>, output: AnyActionHandler<AuthAction>) {
    self.getState = getState
    self.output = output
  }
  
  func handle(action: AuthAction, from dispatcher: ActionSource, afterReducer: inout AfterReducer) {
    afterReducer = .do {
      switch action {
      case .changeRootScreen(let rootScreen):
        print(rootScreen)
      }
    }
  }
}
