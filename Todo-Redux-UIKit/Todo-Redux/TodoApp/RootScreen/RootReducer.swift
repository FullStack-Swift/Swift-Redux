import Foundation
import SwiftRex

let RootReducer = Reducer<RootAction, RootState>.reduce { action, state in
  switch action {
  case .mainAction(let mainAction):
    print(mainAction)
    switch mainAction {
    case .updatedTitle(let title):
      state.mainState.title = title
    default:
      break
    }
  case .authAction(let authAction):
    print(authAction)
  case .changeRootScreen(let screen):
    state.rootScreen = screen
    break
  }
}
