import SwiftUI

@main
struct TodoApp: App {

  @Dependency(\.rootStore)
  private var rootStore

  @Dependency(\.authStore)
  private var authStore

  @Dependency(\.mainStore)
  private var mainStore

  @Dependency(\.counterStore)
  private var counterStore

  private let presentStore: StoreProjection<NavigationAction, NavigationState> = ReduxStoreBase(
    subject: .combine(initialValue: .init()),
    reducer: NavigationReducer,
    middleware: IdentityMiddleware()
  )
  .eraseToAnyStoreType()

  var body: some Scene {
    WindowGroup {
      let rootState = rootStore.asViewStore(initialState: RootState()).state
      RootView(store: rootStore)
        .environmentObject(presentStore.asViewStore(initialState: .init()))
        .environmentObject(rootStore.asViewStore(initialState: rootState))
        .environmentObject(authStore.asViewStore(initialState: rootState.authState))
        .environmentObject(mainStore.asViewStore(initialState: rootState.mainState))
        .environmentObject(counterStore.asViewStore(initialState: rootState.mainState.counterState))
    }
  }

}
