import SwiftUI
import CombineRex

struct MainView: View {
  private let store: AnyStoreType<MainAction, MainState>
  @ObservedObject
  private var viewStore: ViewStore<MainAction, MainState>
  
  init(store: AnyStoreType<MainAction, MainState>) {
    self.store = store
    self.viewStore = store.asViewStore(initialState: MainState())
  }
  
  var body: some View {
    ZStack {
      List {
        HStack {
          Spacer()
          Text(viewStore.isLoading ? "Loading" : "Reload")
            .bold()
          Spacer()
        }
        .onTapGesture {
          viewStore.send(.getTodo)
        }
        HStack {
          TextField("title", text: viewStore.binding(get: \.title, send: MainAction.updatedTitle))
          Button(action: {
            viewStore.send(.createTodo)
          }, label: {
            Text("Create")
              .bold()
              .foregroundColor(viewStore.title.isEmpty ? Color.gray : Color.green)
          })
            .disabled(viewStore.title.isEmpty)
        }
        
        ForEach(viewStore.todos) { todo in
          HStack {
            HStack {
              Image(systemName: todo.isCompleted ? "checkmark.square" : "square")
              Text(todo.title)
                .underline(todo.isCompleted, color: Color.black)
              Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
              viewStore.send(.updateTodo(todo))
            }
            Button(action: {
              viewStore.send(.deleteTodo(todo))
            }, label: {
              Text("Delete")
                .foregroundColor(Color.gray)
            })
          }
        }
#if os(iOS)
        .listStyle(PlainListStyle())
#else
        .listStyle(PlainListStyle())
#endif
        
        .padding(.all, 0)
      }
      .padding(.all, 0)
#if os(macOS)
      .toolbar {
        ToolbarItem(placement: .status) {
          VStack {
            Spacer()
            Button(action: {
              viewStore.send(.changeRootScreen(.auth))
            }, label: {
              Text("Logout")
                .foregroundColor(Color.blue)
            })
          }
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
#endif
#if os(iOS)
      .navigationTitle("Todos")
      .navigationViewStyle(.stack)
      .navigationBarItems(leading: leadingBarItems, trailing: trailingBarItems)
      .embedNavigationView()
#endif
    }
    .onAppear {
      viewStore.send(.getTodo)
    }
  }
}

extension MainView {
  
  private var leadingBarItems: some View {
    CounterView(store: store.projection(action: MainAction.counterAction, state: {$0.counterState}))
  }
  
  private var trailingBarItems: some View {
    Button(action: {
      viewStore.send(.changeRootScreen(.auth))
    }, label: {
      Text("Logout")
        .foregroundColor(Color.blue)
    })
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView(store: ReduxStoreBase(
      subject: .combine(initialValue: MainState()),
      reducer: MainReducer,
      middleware: IdentityMiddleware<MainAction, MainAction, MainState>()).eraseToAnyStoreType()
    )
  }
}

extension View {
    func embedNavigationView() -> some View {
        NavigationView {
            self
        }
    }
}
