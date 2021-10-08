import Foundation
import SwiftRex
import Combine
import ConvertSwift
import Json
import AnyRequest
import Alamofire
import CombineRex

/// Using Closure
class MainMiddleware: Middleware {
  private var output: AnyActionHandler<MainAction>?
  private var getState: GetState<MainState>?
  func receiveContext(getState: @escaping GetState<MainState>, output: AnyActionHandler<MainAction>) {
    self.getState = getState
    self.output = output
  }
  
  func handle(action: MainAction, from dispatcher: ActionSource, afterReducer: inout AfterReducer) {
    guard let state = getState?() else {
      return
    }
    print(state)
    afterReducer = .do { [weak self] in
      guard let self = self else {return}
      let stateAfter = self.getState!()
      print(stateAfter)
      let urlString = "http://127.0.0.1:8080/todos"
      switch action {
      case .changeRootScreen(_):
        break
      case .counterAction(_):
        break
      case .getTodo:
        AF.request(urlString, method: .get).response { dataResponse in
          if let data = dataResponse.data {
            self.output?.dispatch(MainAction.responseTodo(data))
          }
        }
      case .createTodo:
        if state.title.isEmpty {
          return
        }
        let todo = Todo(id: nil, title: state.title, isCompleted: false)
        AF.request(urlString, method: .post, parameters: todo, encoder: JSONParameterEncoder.default).response { dataResponse in
          if let data = dataResponse.data {
            self.output?.dispatch(MainAction.responseCreateTodo(data))
          }
        }
      case .updateTodo(let todo):
        guard var todo = state.todos.filter({$0 == todo}).first else {
          return
        }
        todo.isCompleted.toggle()
        AF.request(urlString + "/\(todo.id!)", method: .post, parameters: todo, encoder: JSONParameterEncoder.default).response { dataResponse in
          if let data = dataResponse.data {
            self.output?.dispatch(MainAction.responseUpdateTodo(data))
          }
        }
      case .deleteTodo(let todo):
        AF.request(urlString + "/\(todo.id!)", method: .delete).response { dataResponse in
          if let data = dataResponse.data {
            self.output?.dispatch(MainAction.reponseDeleteTodo(data))
          }
        }
      default:
        break
      }
    }
  }
}

/// Using Effect
let mainEffectMiddleware: SimpleEffectMiddleware<MainAction, MainState> = SimpleEffectMiddleware.onAction { action, actionSource, state in
  let urlString = "http://127.0.0.1:8080/todos"
  let state = state()
  switch action {
  case .getTodo:
    let request = Request {
      RMethod(.get)
      RUrl(urlString: urlString)
    }
    return request
      .delay(for: 2, scheduler: RunLoop.main) // fake loading
      .compactMap {$0.data}
      .map(MainAction.responseTodo)
      .asEffect(info: "getTodo")
  case .createTodo:
    if state.title.isEmpty {
      return .doNothing
    }
    let todo = Todo(id: nil, title: state.title, isCompleted: false)
    let request = Request {
      RUrl(urlString: urlString)
      REncoding(.json)
      RMethod(.post)
      Rbody(todo.toData())
    }
    return request
      .compactMap {$0.data}
      .map(MainAction.responseCreateTodo)
      .asEffect(info: "createTodo")
  case .updateTodo(let todo):
    guard var todo = state.todos.filter({$0 == todo}).first else {
      return .doNothing
    }
    todo.isCompleted.toggle()
    let request = Request {
      REncoding(.json)
      RUrl(urlString: urlString).withPath(todo.id)
      RMethod(.post)
      Rbody(todo.toData())
    }
    return request
      .compactMap {$0.data}
      .map(MainAction.responseUpdateTodo)
      .asEffect(info: "updateTodo")
  case .deleteTodo(let todo):
    let request = Request {
      RUrl(urlString: urlString).withPath(todo.id)
      RMethod(.delete)
    }
    return request
      .compactMap {$0.data}
      .map(MainAction.reponseDeleteTodo)
      .asEffect(info: "deleteTodo")
  default:
    return .doNothing
  }
}
