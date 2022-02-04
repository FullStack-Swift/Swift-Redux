@_exported import SwiftRex
@_exported import ReactiveSwiftRex

@_exported import MReactiveSwiftRequest
@_exported import MReactiveSwiftWebSocket
@_exported import MReactiveSwiftSocketIO

@_exported import Dependencies
@_exported import Transform
@_exported import Json

// MARK: Functional
func ignore<T>(_ t: T) -> Void { }
func identity<T>(_ t: T) -> T { t }
func absurd<T>(_ never: Never) -> T { }
