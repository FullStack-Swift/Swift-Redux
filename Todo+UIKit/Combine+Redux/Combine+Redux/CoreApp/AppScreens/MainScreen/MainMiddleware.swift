import Foundation
import SwiftRex
import ConvertSwift
import Json
import Combine
import CombineRex
import CombineRequest

class MainMiddleware: MiddlewareProtocol {
  
  typealias InputActionType = MainAction
  
  typealias OutputActionType = MainAction
  
  typealias StateType = MainState
  
  func handle(action: InputActionType, from dispatcher: ActionSource, state: @escaping GetState<StateType>) -> IO<OutputActionType> {
    let urlString = "https://todolistappproj.herokuapp.com/todos"
    let io = IO<OutputActionType> { output in
      let state = state()
      switch action {
          /// view action
        case .viewDidLoad:
          output.dispatch(.getTodo, from: .here())
        case .toggleTodo(let todo):
          var todo = todo
          todo.isCompleted.toggle()
          output.dispatch(.updateTodo(todo))
        case .logout:
          output.dispatch(.changeRootScreen(.auth))
        case .viewCreateTodo:
          if state.title.isEmpty {
            return
          }
          let title = state.title
          let id = UUID()
          let todo = TodoModel(id: id, title: title, isCompleted: false)
          output.dispatch(.createOrUpdateTodo(todo))
          /// networking
        case .getTodo:
          AF.request(urlString, method: .get).response { dataResponse in
            if let data = dataResponse.data {
              output.dispatch(MainAction.responseTodo(data))
            }
          }
        case .createOrUpdateTodo(let todo):
          AF.request(urlString, method: .post, parameters: todo, encoder: JSONParameterEncoder.default).response { dataResponse in
            if let data = dataResponse.data {
              output.dispatch(MainAction.responseCreateOrUpdateTodo(data))
            }
          }
        case .updateTodo(let todo):
          AF.request(urlString + "/\(todo.id.toString())", method: .post, parameters: todo, encoder: JSONParameterEncoder.default).response { dataResponse in
            if let data = dataResponse.data {
              output.dispatch(MainAction.responseUpdateTodo(data))
            }
          }
        case .deleteTodo(let todo):
          AF.request(urlString + "/\(todo.id.toString())", method: .delete).response { dataResponse in
            if let data = dataResponse.data {
              output.dispatch(MainAction.reponseDeleteTodo(data))
            }
          }
        default:
          break
      }
    }
    return io
  }
}

/// EffectMiddleware
let MainEffectMiddleware: SimpleEffectMiddleware<MainAction, MainState> = SimpleEffectMiddleware.onAction { action, actionSource, state in
  let urlString = "https://todolistappproj.herokuapp.com/todos"
  let state = state()
  switch action {
      /// view action
    case .viewDidLoad:
      let publisher = Just(MainAction.getTodo)
      return publisher
        .asEffect()
    case .toggleTodo(let todo):
      var todo = todo
      todo.isCompleted.toggle()
      let publisher = Just(MainAction.updateTodo(todo))
      return publisher
        .asEffect()
    case .logout:
      let publisher = Just(MainAction.changeRootScreen(.auth))
      return publisher
        .asEffect()
    case .viewCreateTodo:
      if state.title.isEmpty {
        return .doNothing
      }
      let title = state.title
      let id = UUID()
      let todo = TodoModel(id: id, title: title, isCompleted: false)
      let publisher = Just(MainAction.createOrUpdateTodo(todo))
      return publisher
        .asEffect()
      /// networking
    case .getTodo:
      let request = MRequest {
        RMethod(.get)
        RUrl(urlString: urlString)
      }
      return request
        .compactMap {$0.data}
        .map(MainAction.responseTodo)
        .asEffect(info: "getTodo")
    case .createOrUpdateTodo(let todo):
      let request = MRequest {
        RUrl(urlString: urlString)
        REncoding(.json)
        RMethod(.post)
        Rbody(todo.toData())
      }
      return request
        .compactMap {$0.data}
        .map(MainAction.responseCreateOrUpdateTodo)
        .asEffect(info: "createTodo")
    case .updateTodo(let todo):
      let request = MRequest {
        REncoding(.json)
        RUrl(urlString: urlString)
          .withPath(todo.id.toString())
        RMethod(.post)
        Rbody(todo.toData())
      }
      return request
        .compactMap {$0.data}
        .map(MainAction.responseUpdateTodo)
        .asEffect(info: "updateTodo")
    case .deleteTodo(let todo):
      let request = MRequest {
        RUrl(urlString: urlString)
          .withPath(todo.id.toString())
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
