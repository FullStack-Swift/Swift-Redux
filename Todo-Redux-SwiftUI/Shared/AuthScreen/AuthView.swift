import SwiftUI
import CombineRex

struct AuthView: View {
  private let store: AnyStoreType<AuthAction, AuthState>
  @ObservedObject
  private var viewStore: ViewStore<AuthAction, AuthState>
  
  init(store: AnyStoreType<AuthAction, AuthState>) {
    self.store = store
    self.viewStore = store.asViewStore(initialState: AuthState())
  }
  
  var body: some View {
    ZStack {
      Button("Login") {
        viewStore.send(.changeRootScreen(.main))
      }
    }
  }
}

struct AuthView_Previews: PreviewProvider {
  static var previews: some View {
    AuthView(store: ReduxStoreBase(
      subject: .combine(initialValue: AuthState()),
      reducer: AuthReducer,
      middleware: IdentityMiddleware<AuthAction, AuthAction, AuthState>()
    ).eraseToAnyStoreType())
  }
}
