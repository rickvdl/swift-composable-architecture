#if os(macOS) || os(iOS) || os(watchOS) || os(visionOS) || os(tvOS)
import OSLog
#else
// OSLog is not available on Linux, use a dummy type
public typealias OSLogType = UInt8
public extension OSLogType {
  static let `default`: OSLogType = 0
}
#endif

@_spi(Logging)
#if swift(<5.10)
  @MainActor(unsafe)
#else
  @preconcurrency@MainActor
#endif
public final class Logger {
  public static let shared = Logger()
  public var isEnabled = false
  @Published public var logs: [String] = []
  #if DEBUG
    #if os(macOS) || os(iOS) || os(watchOS) || os(visionOS) || os(tvOS)
    @available(iOS 14, macOS 11, tvOS 14, watchOS 7, *)
    var logger: os.Logger {
      os.Logger(subsystem: "composable-architecture", category: "store-events")
    }
    #endif
    public func log(level: OSLogType = .default, _ string: @autoclosure () -> String) {
      guard self.isEnabled else { return }
      let string = string()
      if isRunningForPreviews {
        print("\(string)")
      } else {
        #if os(macOS) || os(iOS) || os(watchOS) || os(visionOS) || os(tvOS)
        if #available(iOS 14, macOS 11, tvOS 14, watchOS 7, *) {
          self.logger.log(level: level, "\(string)")
        }
        #endif
      }
      self.logs.append(string)
    }
    public func clear() {
      self.logs = []
    }
  #else
    @inlinable @inline(__always)
    public func log(level: OSLogType = .default, _ string: @autoclosure () -> String) {
    }
    @inlinable @inline(__always)
    public func clear() {
    }
  #endif
}

private let isRunningForPreviews: Bool = {
  #if os(macOS) || os(iOS) || os(watchOS) || os(visionOS) || os(tvOS)
  return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
  #else
  return false
  #endif
}()
