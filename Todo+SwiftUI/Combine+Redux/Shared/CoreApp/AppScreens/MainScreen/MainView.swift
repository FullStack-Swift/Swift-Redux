import SwiftUI

struct MainView: View {
  
  private let store: AnyStoreType<MainAction, MainState>
  
  @ObservedObject
  private var viewStore: ViewStore<MainAction, MainState>

  @EnvironmentObject var navigationViewStore: ViewStore<NavigationAction, NavigationState>
  @EnvironmentObject var counterViewStore: ViewStore<CounterAction, CounterState>
  @Dependency(\.counterStore) var counterStore

  init(store: AnyStoreType<MainAction, MainState>? = nil) {
    let unwrapStore = store ?? ReduxStoreBase(
      subject: .combine(initialValue: MainState()),
      reducer: MainReducer,
      middleware: MainMiddleware()
    )
      .eraseToAnyStoreType()
    self.store = unwrapStore
    self.viewStore = unwrapStore.asViewStore(initialState: MainState())
  }
  
  var body: some View {
    ZStack {
#if os(macOS)
      content
        .toolbar {
          ToolbarItem(placement: .status) {
            HStack {
              CounterView(store: store.projection(action: MainAction.counterAction, state: {$0.counterState}))
              Spacer()
              Button(action: {
                viewStore.send(.logout)
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
      NavigationContainer {
        ZStack {
          Color.white
          TabView {
            content
              .navigationBarItems(leading: Text("ABC"), trailing: Text("123"))
              .tabItem {
                VStack {
                  Image(systemName: "bolt.circle")
                  Text("Todos")
                }
              }
            content
              .navigationBarItems(leading: Text("ABC"), trailing: Text("123"))
              .tabItem {
                VStack {
                  Image(systemName: "bolt.circle")
                  Text("Todos")
                }
              }
            content
              .navigationBarItems(leading: Text("ABC"), trailing: Text("123"))
              .tabItem {
                VStack {
                  Image(systemName: "bolt.circle")
                  Text("Todos")
                }
              }
          }
          .navigationBarTitle(Text("Todos"), displayMode: .inline)
          .navigationBarItems(leading: leadingBarItems, trailing: trailingBarItems)
        }
      }
#endif
    }
    .onAppear {
      viewStore.send(.viewOnAppear)
    }
    .onDisappear {
      viewStore.send(.viewOnDisappear)
    }
  }
}


extension MainView {
  /// create content view in screen
  private var content: some View {
    List {
      Section {
        ZStack {
          HStack {
            Spacer()
            if viewStore.isLoading {
              ProgressView()
            } else {
              Text("Reload")
                .bold()
                .onTapGesture {
                  viewStore.send(.getTodo)
                }
            }
            Spacer()
          }
          .frame(height: 60)
        }
      }
      HStack {
        TextField("title", text: viewStore.binding(get: \.title, send: MainAction.changeText))
        Button(action: {
          viewStore.send(.viewCreateTodo)
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
              .frame(width: 40, height: 40, alignment: .center)
            Text(todo.title)
              .underline(todo.isCompleted, color: Color.black)
            Spacer()
          }
          .contentShape(Rectangle())
          .onTapGesture {
            viewStore.send(.toggleTodo(todo))
          }
          Button(action: {
            viewStore.send(.deleteTodo(todo))
          }, label: {
            Text("Delete")
              .foregroundColor(Color.gray)
          })
        }
      }
      .padding(.all, 0)
    }
    .padding(.all, 0)
    .listStyle(.plain)
    .background(Color.white)
  }
  
  private var leadingBarItems: some View {
    HStack {
      Button {
        navigationViewStore.send(.pushScreen([.counter]))
      } label: {
        Text("+-")
      }
      Button {
        navigationViewStore.send(.pushScreen([.examples]))
      } label: {
        Text("Examples")
      }
    }
  }
  
  private var trailingBarItems: some View {
    Button(action: {
      viewStore.send(.logout)
    }, label: {
      Text("Logout")
        .foregroundColor(Color.blue)
    })
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
  }
}
