import Foundation

#if os(macOS) || os(iOS) || os(watchOS) || os(visionOS) || os(tvOS)
extension UnsafeMutablePointer<os_unfair_lock_s> {
  @inlinable @discardableResult
  func sync<R>(_ work: () -> R) -> R {
    os_unfair_lock_lock(self)
    defer { os_unfair_lock_unlock(self) }
    return work()
  }

  func lock() {
    os_unfair_lock_lock(self)
  }

  func unlock() {
    os_unfair_lock_unlock(self)
  }
}
#else
// Linux-compatible locking using NSLock
// On Linux, we use NSLock as a drop-in replacement for os_unfair_lock
typealias os_unfair_lock_t = NSLock

extension NSLock {
  @inlinable @discardableResult
  func sync<R>(_ work: () -> R) -> R {
    self.lock()
    defer { self.unlock() }
    return work()
  }

  // Note: lock() and unlock() are already provided by NSLock from Foundation,
  // so we don't need to re-implement them. The typealias allows the same API
  // to work on both platforms.
}
#endif

extension NSRecursiveLock {
  @inlinable @discardableResult
  @_spi(Internals) public func sync<R>(work: () -> R) -> R {
    self.lock()
    defer { self.unlock() }
    return work()
  }
}
