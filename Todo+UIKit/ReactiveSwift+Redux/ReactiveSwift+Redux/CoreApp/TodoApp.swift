import SwiftUI
import SwiftRex
import ReactiveSwiftRex

@main
struct TodoApp: App {
  
  private let store = ReduxStoreBase(
    subject: .reactive(initialValue: RootState()),
    reducer: rootReducer,
    middleware: rootMiddleware
  )
  
  var body: some Scene {
    WindowGroup {
      let vc = RootViewController(store: store)
      UIViewRepresented(makeUIView: { _ in vc.view })
    }
  }
}
