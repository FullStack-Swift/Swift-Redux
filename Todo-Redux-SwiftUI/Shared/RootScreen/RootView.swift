import SwiftUI
import SwiftRex
import CombineRex

struct RootView: View {
  private let store: Store
  @ObservedObject
  private var viewStore: ViewStore<RootAction, RootState>
  
  init(store: Store) {
    self.store = store
    viewStore = store.asViewStore(initialState: RootState())
  }
  
  @ViewBuilder
  var body: some View {
    switch viewStore.state.rootScreen {
    case .main:
      MainView(store: store.projection(action: RootAction.mainAction, state: {$0.mainState}))
    case .auth:
      AuthView(store: store.projection(action: RootAction.authAction, state: {$0.authState}))
    }
  }
}

struct RootView_Previews: PreviewProvider {
  static var previews: some View {
    RootView(store: Store.create())
  }
}
