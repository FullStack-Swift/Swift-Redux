import SwiftUI
import SwiftRex
import RxSwiftRex

@main
struct TodoApp: App {
  
  private let store = ReduxStoreBase(
    subject: .rx(initialValue: RootState()),
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
