import Foundation

class CounterMiddleware: MiddlewareProtocol {

  typealias InputActionType = CounterAction

  typealias OutputActionType = CounterAction

  typealias StateType = CounterState

  func handle(action: InputActionType, from dispatcher: ActionSource, state: @escaping GetState<StateType>) -> IO<OutputActionType> {
    let io = IO<OutputActionType> { output in
      let state = state()
      print(state)
      switch action {
      case .increment:
          break
      case .decrement:
          break
      default:
        break
      }
    }
    return io
  }
}
