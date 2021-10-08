import SwiftRex

class CounterMiddleware: Middleware {
  private var output: AnyActionHandler<CounterAction>?
  private var getState: GetState<CounterState>?
  func receiveContext(getState: @escaping GetState<CounterState>, output: AnyActionHandler<CounterAction>) {
    self.getState = getState
    self.output = output
  }
  
  func handle(action: CounterAction, from dispatcher: ActionSource, afterReducer: inout AfterReducer) {
    guard let state = getState?() else {
      return
    }
    print(state)
    afterReducer = .do { [weak self] in
      guard let self = self else {return}
      let stateAfter = self.getState!()
      print(stateAfter)
      switch action {
      case .increment:
        print(action)
      case .decrement:
        print(action)
      }
    }
  }
}
