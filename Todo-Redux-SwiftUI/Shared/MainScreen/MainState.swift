import Foundation

struct MainState: Equatable {
  var counterState = CounterState()
  var title: String = ""
  var todos: [Todo] = []
  var isLoading: Bool = false
}
