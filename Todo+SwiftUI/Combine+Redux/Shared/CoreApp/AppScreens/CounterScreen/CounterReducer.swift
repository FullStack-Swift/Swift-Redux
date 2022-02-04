import Foundation

let CounterReducer = Reducer<CounterAction, CounterState>.reduce { action, state in
  switch action {
    case .increment:
      state.count += 1
      print("CounterReducer increment: count = \(state.count)")
    case .decrement:
      state.count -= 1
      print("CounterReducer decrement: count = \(state.count)")
    default:
      break
  }
}
