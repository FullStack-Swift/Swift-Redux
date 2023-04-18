import SwiftUI

struct ExampleView: View {

  @EnvironmentObject var navigationViewStore: ViewStore<NavigationAction, NavigationState>

    private let store: AnyStoreType<ExampleAction, ExampleState>

    @ObservedObject
    private var viewStore: ViewStore<ExampleAction, ExampleState>

    init(store: AnyStoreType<ExampleAction, ExampleState>? = nil) {
      let unwrapStore = store ?? ReduxStoreBase(
        subject: .combine(initialValue: ExampleState()),
        reducer: ExampleReducer,
        middleware: ExampleMiddleware()
      )
        .eraseToAnyStoreType()
      self.store = unwrapStore
      self.viewStore = unwrapStore.asViewStore(initialState: ExampleState())
    }


  var body: some View {
    List {
      Section(header: Text("Navigation started")) {
        HStack {
          Text("Navigation Examples")
            .multilineTextAlignment(.leading)
          Spacer()
        }
        .background(Color.white.opacity(1/1000))
        .clipShape(Rectangle())
        .onTapGesture {
          navigationViewStore.send(.pushScreen([.one]))
        }
      }
    }
    .listStyle(.plain)
  }
}

struct ExampleView_Previews: PreviewProvider {
  static var previews: some View {
    ExampleView()
  }
}
