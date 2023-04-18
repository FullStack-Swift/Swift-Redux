import SwiftUI
import SwiftRex
import NavigationStackBackport
import IdentifiedCollections

struct NavigationContainer<Root: View>: View {

  @EnvironmentObject var viewStore: ViewStore<NavigationAction, NavigationState>

  let root: () -> Root

  var body: some View {
    NavigationStackBackport.NavigationStack(path: viewStore.binding(get: { Array($0.stack) }, send: NavigationAction.set)) {
      root()
        .backport.navigationDestination(for: Destination.State.self) { value in
          NavigationDetailView(screen: value.screen)
        }
        .navigationViewStyle(.stack)
    }
  }
}

struct NavigationContainer_Previews: PreviewProvider {
    static var previews: some View {
      NavigationContainer {
        Text("TodoList")
      }
    }
}

let NavigationReducer = Reducer<NavigationAction, NavigationState>.reduce { action, state in
  switch action {
    case .pushScreen(let screens):
      state.stack.append(contentsOf: screens.map { .init(id: "\(UUID().uuidString).\($0)", screen: $0) })
    case .popToScreen(let screen):
      if let index = state.stack.firstIndex(where: {$0.screen == screen}) {
        state.stack = .init(uniqueElements: state.stack[state.stack.startIndex...index])
      }
    case .push(let stack):
      state.stack.append(contentsOf: stack.map { .init(id: "\(UUID().uuidString).\($0)", screen: $0.screen) })
    case .set(let stack):
      state.stack = state.stack.filter { destination in
        stack.contains(destination)
      }
    case .pop:
      _ = state.stack.popLast()
    case .popTo(let screen):
      guard let screen = screen else { return }
      if let index = state.stack.index(id: screen.id) {
        state.stack = .init(uniqueElements: state.stack[state.stack.startIndex...index])
      }
    case .popToRoot:
      state.stack.removeAll()
    case .shuffle:
      state.stack.shuffle()
    case .destination(let destination):
      switch destination {
        case .push(let stack):
          state.stack.append(contentsOf: stack.map { .init(id: "\(UUID().uuidString).\($0)", screen: $0.screen) })
        case .set(let stack):
          state.stack = state.stack.filter { destination in
            stack.contains(destination)
          }
        case .pop:
          _ = state.stack.popLast()
        case .popTo(let screen):
          guard let screen = screen else { return }
          if let index = state.stack.index(id: screen.id) {
            state.stack = .init(uniqueElements: state.stack[state.stack.startIndex...index])
          }
        case .popToRoot:
          state.stack.removeAll()
        case .shuffle:
        state.stack.shuffle()
      }
    default:
      break
  }
}

struct NavigationState: Equatable {
  var stack: IdentifiedArrayOf<Destination.State> = []
}

enum NavigationAction: Equatable {
  case destination(_ action: Destination.Action)
  case pushScreen([NavigationScreenDetailType])
  case popToScreen(NavigationScreenDetailType)
  case push([Destination.State])
  case set([Destination.State])
  case popTo(Destination.State?)
  case pop
  case popToRoot
  case shuffle
  case none
}

enum Destination {

  struct State: Identifiable, Equatable, Hashable {
    var id: String = UUID().uuidString
    var screen: NavigationScreenDetailType = .none
  }

  enum Action: Equatable {
    case push([Destination.State])
    case set([Destination.State])
    case popTo(Destination.State?)
    case pop
    case popToRoot
    case shuffle
  }
}

struct NavigationDetailView: View {

  @EnvironmentObject var viewStore: ViewStore<NavigationAction, NavigationState>
  var screen: NavigationScreenDetailType = .none

  @Dependency(\.counterStore) var counterStore

  var body: some View {
    switch screen {
      case .one:
        ZStack {
          Color.red
          VStack {
            Button("Open Three") {
              viewStore.send(.pushScreen([.two, .three]))
            }
            Button("Open Two") {
              viewStore.send(.pushScreen([.two])
              )
            }
            Button("Pop to Root") {
              viewStore.send(.popToRoot)
            }
          }
          .foregroundColor(.white)
        }
        .navigationTitle(screen.title)
      case .two:
        ZStack {
          Color.green
          VStack {
            Button("Pop One") {
              viewStore.send(.pop)
            }
            Button("Open Three") {
              viewStore.send(.pushScreen([.three]))
            }
            Button("Pop to Root") {
              viewStore.send(.popToRoot)
            }
          }
          .foregroundColor(.white)
        }
        .navigationTitle(screen.title)
      case .three:
        ZStack {
          Color.blue
          VStack {
            Button("Pop to Root") {
              viewStore.send(.popToRoot)
            }
            Button("Pop to One") {
              viewStore.send(.popToScreen(.one))
            }
            Button("Pop to Two") {
              viewStore.send(.pop)
            }
          }
          .foregroundColor(.white)
        }
        .navigationTitle(screen.title)
      case .examples:
        ZStack {
          ExampleView()
        }
      case .counter:
        ZStack {
          CounterView()
        }
      case .none:
        ZStack {

        }
    }
  }
}

enum NavigationScreenDetailType {
  case one
  case two
  case three
  case examples
  case counter
  case none

  var title: String {
    switch self {
      case .one:
        return "One"
      case .two:
        return "Two"
      case .three:
        return "Three"
      case .examples:
        return "Examples"
      case .none:
        return ""
      case .counter:
        return "Counter"
    }
  }
}
