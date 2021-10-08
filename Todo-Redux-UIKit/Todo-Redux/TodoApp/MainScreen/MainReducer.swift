import Foundation
import SwiftRex
import ConvertSwift
let MainReducer = Reducer<MainAction, MainState>.reduce { action, state in
  switch action {
  case .changeRootScreen(_):
    break
  case .counterAction(_):
    break
  case .getTodo:
    if state.isLoading {
      return
    }
    state.isLoading = true
    state.todos.removeAll()
    break
  case .responseTodo(let data):
    state.isLoading = false
    state.todos.removeAll()
    if let todos = data.toModel([Todo].self) {
      state.todos = todos
    }
  case .createTodo:
    state.title = ""
    break
  case .responseCreateTodo(let data):
    if let todo = data.toModel(Todo.self) {
      state.todos.append(todo)
    }
  case .updateTodo(let todo):
    break
  case .responseUpdateTodo(let data):
    if let todo = data.toModel(Todo.self) {
      if let index = state.todos.firstIndex(where: { item in
        item.id == todo.id
      }) {
        state.todos[index] = todo
      }
    }
  case .deleteTodo(let todo):
    break
  case .reponseDeleteTodo(let data):
    if let todo = data.toModel(Todo.self) {
      state.todos.removeAll {
        $0.id == todo.id
      }
    }
  case .updatedTitle(let title):
    state.title = title
  case .logout:
    break
  case .none:
    break
  }
}
