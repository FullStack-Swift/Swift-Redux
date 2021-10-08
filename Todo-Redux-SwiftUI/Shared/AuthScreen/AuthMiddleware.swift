import Foundation
import SwiftRex
import Combine

class AuthMiddleware: Middleware {
  private var output: AnyActionHandler<AuthAction>?
  private var getState: GetState<AuthState>?
  func receiveContext(getState: @escaping GetState<AuthState>, output: AnyActionHandler<AuthAction>) {
    self.getState = getState
    self.output = output
  }
  
  func handle(action: AuthAction, from dispatcher: ActionSource, afterReducer: inout AfterReducer) {
    guard let state = getState?() else {
      return
    }
    print(state)
    afterReducer = .do { [weak self] in
      guard let self = self else {return}
      let stateAfter = self.getState!()
      print(stateAfter)
      switch action {
      case .changeRootScreen(let rootScreen):
        print(rootScreen)
      }
    }
  }
}
