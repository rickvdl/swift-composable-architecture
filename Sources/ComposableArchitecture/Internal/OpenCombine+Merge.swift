// MIT License

// Copyright (c) 2019 Quentin Jin

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#if !os(macOS) && !os(iOS) && !os(watchOS) && !os(visionOS) && !os(tvOS)
@preconcurrency import OpenCombine

extension Publisher {
  /// Combines elements from this publisher with those from another publisher, delivering an interleaved sequence of elements.
  ///
  /// The merged publisher continues to emit elements until all upstream publishers finish. If an upstream publisher produces an error, the merged publisher fails with that error.
  /// - Parameter other: Another publisher.
  /// - Returns: A publisher that emits an event when either upstream publisher emits an event.
  public func merge<P: Publisher>(with other: P) -> Publishers.Merge<Self, P>
  where Failure == P.Failure, Output == P.Output {
    return .init(self, other)
  }
}

extension Publishers.Merge: Equatable where A: Equatable, B: Equatable {
  /// Returns a Boolean value that indicates whether two publishers are equivalent.
  ///
  /// - Parameters:
  ///   - lhs: A merging publisher to compare for equality.
  ///   - rhs: Another merging publisher to compare for equality..
  /// - Returns: `true` if the two merging publishers are equivalent.
  public static func == (lhs: Publishers.Merge<A, B>, rhs: Publishers.Merge<A, B>) -> Bool {
    return lhs.a == rhs.a && lhs.b == rhs.b
  }
}

extension Publishers {
  /// A publisher created by applying the merge function to two upstream publishers.
  public struct Merge<A, B>: Publisher
  where A: Publisher, B: Publisher, A.Failure == B.Failure, A.Output == B.Output {
    public typealias Output = A.Output
    public typealias Failure = A.Failure

    public let a: A
    public let b: B

    let pub: AnyPublisher<A.Output, A.Failure>

    public init(_ a: A, _ b: B) {
      self.a = a
      self.b = b

      self.pub =
        Publishers
        .Sequence(sequence: [a.eraseToAnyPublisher(), b.eraseToAnyPublisher()])
        .flatMap { $0 }
        .eraseToAnyPublisher()
    }

    public func receive<S: Subscriber>(subscriber: S)
    where B.Failure == S.Failure, B.Output == S.Input {
      self.pub.subscribe(subscriber)
    }
  }
}
#endif


