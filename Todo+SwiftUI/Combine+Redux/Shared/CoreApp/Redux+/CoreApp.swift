@_exported import SwiftRex
@_exported import CombineRex

@_exported import MCombineRequest
@_exported import MCombineWebSocket
@_exported import MCombineSocketIO

@_exported import Dependencies
@_exported import Transform
@_exported import Json

// MARK: Functional
func ignore<T>(_ t: T) -> Void { }
func identity<T>(_ t: T) -> T { t }
func absurd<T>(_ never: Never) -> T { }
