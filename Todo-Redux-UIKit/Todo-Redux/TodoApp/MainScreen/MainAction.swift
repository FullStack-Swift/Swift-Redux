import Foundation

enum MainAction: Equatable {
  case changeRootScreen(RootScreen)
  case counterAction(CounterAction)
  case getTodo
  case responseTodo(Data)
  case createTodo
  case responseCreateTodo(Data)
  case updateTodo(Todo)
  case responseUpdateTodo(Data)
  case deleteTodo(Todo)
  case reponseDeleteTodo(Data)
  case updatedTitle(String)
  case logout
  case none
}

extension MainAction {
  public var counterAction: CounterAction? {
    guard case let .counterAction(value) = self else { return nil }
    return value
  }
}
