import Foundation

class ExampleMiddleware: MiddlewareProtocol {

  typealias InputActionType = ExampleAction

  typealias OutputActionType = ExampleAction

  typealias StateType = ExampleState

  func handle(action: ExampleAction, from dispatcher: ActionSource, state: @escaping GetState<ExampleState>) -> IO<ExampleAction> {
    let io = IO<OutputActionType> { output in
      let state = state()
      print(state)
      switch action {
        case .viewOnAppear:
          break
        case .viewOnDisappear:
          break
        default:
          break
      }
    }
    return io
  }

}
