import Foundation
import SwiftRex
import ReactiveSwiftRex
import ReactiveSwift

class RootMiddleware: MiddlewareProtocol {
  
  typealias InputActionType = RootAction
  
  typealias OutputActionType = RootAction
  
  typealias StateType = RootState
  
  func handle(action: InputActionType, from dispatcher: ActionSource, state: @escaping GetState<StateType>) -> IO<OutputActionType> {
    let io = IO<OutputActionType> { output in
      switch action {
        case .mainAction(let mainAction):
          switch mainAction {
            case .changeRootScreen(let screen):
              output.dispatch(.changeRootScreen(screen))
            default:
              break
          }
        case .authAction(let authAction):
          switch authAction {
            case .changeRootScreen(let screen):
              output.dispatch(.changeRootScreen(screen))
            default:
              break
          }
        default:
          break
      }
    }
    return io
  }
}
