import SwiftUI
import CombineRex
import SwiftRex

struct CounterView: View {
  private let store: AnyStoreType<CounterAction, CounterState>
  @ObservedObject
  private var viewStore: ViewStore<CounterAction, CounterState>
  
  init(store: AnyStoreType<CounterAction, CounterState>) {
    self.store = store
    self.viewStore = store.asViewStore(initialState: CounterState())
  }
  
  var body: some View {
    HStack {
      Button(action: {
        viewStore.send(.increment)
      }, label: {
        Text("+")
      })
      Text(String(viewStore.count))
      Button(action: {
        viewStore.send(.decrement)
      }, label: {
        Text("-")
      })
    }
  }
}

struct CounterView_Previews: PreviewProvider {
  static var previews: some View {
    CounterView(store: ReduxStoreBase(
      subject: .combine(initialValue: CounterState()),
      reducer: CounterReducer,
      middleware: IdentityMiddleware<CounterAction, CounterAction, CounterState>()
    ).eraseToAnyStoreType())
  }
}
