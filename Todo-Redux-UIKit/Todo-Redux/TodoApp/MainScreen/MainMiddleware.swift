import Foundation
import SwiftRex
import Combine
import ConvertSwift
import Json
import AnyRequest
import Alamofire
import RxSwiftRex

/// Using Closure
class MainMiddleware: Middleware {
  private var output: AnyActionHandler<MainAction>?
  private var getState: GetState<MainState>?
  func receiveContext(getState: @escaping GetState<MainState>, output: AnyActionHandler<MainAction>) {
    self.getState = getState
    self.output = output
  }
  
  func handle(action: MainAction, from dispatcher: ActionSource, afterReducer: inout AfterReducer) {
    guard let beforeState = getState?() else {
      return
    }
    print(beforeState)
    afterReducer = .do { [weak self] in
      guard let self = self else {return}
      let state = self.getState!()
      let urlString = "http://127.0.0.1:8080/todos"
      switch action {
      case .changeRootScreen(_):
        break
      case .counterAction(_):
        break
      case .getTodo:
        AF.request(urlString, method: .get).response { dataResponse in
          if let data = dataResponse.data {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
              self.output?.dispatch(MainAction.responseTodo(data))
            }
          }
        }
      case .createTodo:
        if beforeState.title.isEmpty {
          return
        }
        let todo = Todo(id: nil, title: beforeState.title, isCompleted: false)
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
