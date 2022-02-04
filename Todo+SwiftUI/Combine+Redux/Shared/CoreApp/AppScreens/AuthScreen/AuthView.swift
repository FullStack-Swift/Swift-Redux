import SwiftUI

struct AuthView: View {
  
  private let store: AnyStoreType<AuthAction, AuthState>
  
  @ObservedObject
  private var viewStore: ViewStore<AuthAction, AuthState>
  
  init(store: AnyStoreType<AuthAction, AuthState>? = nil) {
    let unwrapStore = store ?? ReduxStoreBase(
      subject: .combine(initialValue: AuthState()),
      reducer: AuthReducer,
      middleware: AuthMiddleware()
    )
      .eraseToAnyStoreType()
    self.store = unwrapStore
    self.viewStore = unwrapStore.asViewStore(initialState: AuthState())
  }
  
  var body: some View {
    ZStack {
      Button("Login") {
        viewStore.send(.requestLogin)
      }
    }
    .onAppear {
      viewStore.send(.viewOnAppear)
    }
    .onDisappear {
      viewStore.send(.viewOnDisappear)
    }
  }
}

struct AuthView_Previews: PreviewProvider {
  static var previews: some View {
    AuthView()
  }
}
