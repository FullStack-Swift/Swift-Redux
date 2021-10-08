import SwiftRex
import CombineRex
import SwiftUI

@dynamicMemberLookup
final public class ViewStore<ViewAction, ViewState>: ObservableViewModel<ViewAction, ViewState> {
  
  public subscript<LocalState>(dynamicMember keyPath: KeyPath<ViewState, LocalState>) -> LocalState {
    self.state[keyPath: keyPath]
  }
  
  public subscript<LocalState>(
    get state: HashableWrapper<(ViewState) -> LocalState>,
    send action: HashableWrapper<(LocalState) -> ViewAction>
  ) -> LocalState {
    get { state.rawValue(self.state) }
    set { self.dispatch(action.rawValue(newValue)) }
  }
  
  public func send(_ action: ViewAction) {
    dispatch(action)
  }
}

public struct HashableWrapper<Value>: Hashable {
  let rawValue: Value
  public static func == (lhs: Self, rhs: Self) -> Bool { false }
  public func hash(into hasher: inout Hasher) {}
}

extension ViewStore {
  public func binding<LocalState>(
    get: @escaping (ViewState) -> LocalState,
    send localStateToViewAction: @escaping (LocalState) -> ViewAction
  ) -> Binding<LocalState> {
    ObservedObject(wrappedValue: self)
      .projectedValue[get: .init(rawValue: get), send: .init(rawValue: localStateToViewAction)]
  }
}

extension StoreType where StateType: Equatable {
    public func asViewStore(
        initialState: StateType
    ) -> ViewStore<ActionType, StateType> {
        .init(initialState: initialState, store: self, emitsValue: .whenDifferent)
    }
}
