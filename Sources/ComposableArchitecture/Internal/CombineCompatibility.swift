#if !os(macOS) && !os(iOS) && !os(watchOS) && !os(visionOS) && !os(tvOS)
@_exported import OpenCombine

// Typealias OpenCombine types to Combine namespace for compatibility
public enum Combine {
  public typealias Subscriber = OpenCombine.Subscriber
  public typealias Subscription = OpenCombine.Subscription
  public typealias Publisher = OpenCombine.Publisher
  public typealias Subject = OpenCombine.Subject
  public typealias AnyCancellable = OpenCombine.AnyCancellable
  public typealias Cancellable = OpenCombine.Cancellable
  public typealias Subscribers = OpenCombine.Subscribers
  public typealias Publishers = OpenCombine.Publishers
}
#endif