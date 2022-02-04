import Foundation

enum AuthAction: Equatable {
  case viewOnAppear
  case viewOnDisappear
  case none
  case requestLogin
  case responeLogin(Result<Bool, Never>)
  case changeRootScreen(RootScreen)
}
