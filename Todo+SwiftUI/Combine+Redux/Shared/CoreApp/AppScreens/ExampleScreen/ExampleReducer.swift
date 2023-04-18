import Foundation

let ExampleReducer = Reducer<ExampleAction, ExampleState>.reduce { action, state in
  switch action {
    case .viewOnAppear:
      break
    case .viewOnDisappear:
      break
    case .none:
      break
  }
}
