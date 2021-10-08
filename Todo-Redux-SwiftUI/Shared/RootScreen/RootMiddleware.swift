import Foundation
import SwiftRex
import CombineRex
import Combine

class RootMiddleware: Middleware {
  private var output: AnyActionHandler<RootAction>?
  private var getState: GetState<RootState>?
  func receiveContext(getState: @escaping GetState<RootState>, output: AnyActionHandler<RootAction>) {
    self.getState = getState
    self.output = output
  }
  
  func handle(action: RootAction, from dispatcher: ActionSource, afterReducer: inout AfterReducer) {
    guard let state = getState?() else {
      return
    }
    print(state)
    afterReducer = .do { [weak self] in
      guard let self = self else {return}
      let stateAfter = self.getState!()
      print(stateAfter)
      switch action {
      case .mainAction(let mainAction):
        switch mainAction {
        case .changeRootScreen(let screen):
          self.output?.dispatch(.changeRootScreen(screen))
        default:
          break
        }
      case .authAction(let authAction):
        switch authAction {
        case .changeRootScreen(let screen):
          self.output?.dispatch(.changeRootScreen(screen))
        }
      default:
        break
      }
    }
  }
}
