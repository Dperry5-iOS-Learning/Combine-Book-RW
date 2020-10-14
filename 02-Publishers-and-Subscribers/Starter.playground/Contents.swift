import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

// MARK:- 2.1.0 - Hello Publisher
example(of: "Publisher") {
    /// Summary: Create a Notification, A publisher for it, and an observer. Send notification Once
    /// 1. Create a notification name.
    let notification = Notification.Name("MyNotification")
    /// 2. Access Notification Centers Default publisher
    let publisher = NotificationCenter.default.publisher(for: notification)
    /// 3.  Access Notification Center
    let center = NotificationCenter.default
    /// 4.  Add an Observer to the Notification Center
    let observer = center.addObserver(forName: notification, object: nil, queue: nil) { notification in
        print("Notification Recieved")
    }
    /// 5. Post a Notification
    center.post(name: notification, object: nil)
    /// 6. Remove Observer from notification Center
    center.removeObserver(observer)
}

// MARK:- 2.2.0 - Hello Subscriber
// MARK:- 2.2.1 - Sink Subscriber
example(of: "Subscriber") {
    /// Summary: Create a Notification, A publisher for it, and an observer. Send notification Once
    /// 1. Create a notification name.
    let notification = Notification.Name("MyNotification")
    /// 2. Access Notification Centers Default publisher
    let publisher = NotificationCenter.default.publisher(for: notification)
    /// 3.  Access Notification Center
    let center = NotificationCenter.default
    /// 4. Create a subscription using .sink
    let subscription = publisher.sink { _ in
        print("Notification recieved from publisher")
    }
    /// 5. Post a notificaition
    center.post(name: notification, object: nil)
    /// 6. Cancel subscription to clear memory.
    subscription.cancel()
}

// MARK:- 2.2.2 - Just
example(of: "Just") {
    /// 1. Create a publisher using Just, which lets you create a publisher from a primitive value type
    let just = Just("Hello World!")
    /// 2. Create a subscription  to the publisher and print a message for each recieved event.
    _ = just.sink(
        receiveCompletion: {
          print("Recieved Completion:", $0)
        }, receiveValue: {
            print("Recieved Value:", $0)

        })
    /// 3. Add another Subscription to observe that Just publishes just once to each subscriber
    _ = just.sink(
        receiveCompletion: {
          print("Recieved Antoher Completion:", $0)
        }, receiveValue: {
            print("Recieved Another Value:", $0)

        })
}

// MARK:- 2.2.3 - assign(to:on:)
example(of: "assign(on:to:)") {
    /// 1. Define a class and property with a didSet Value
    class SampleObject {
        var value: String = "" {
            didSet {
                print("Updating Value to", value)
            }
        }
    }
    /// 2. Instantiate Class
    let newObject = SampleObject()
    /// 3. Create Publisher
    let publisher = ["Hello", "World!"].publisher
    /// 4. Subscribe to publisher and update value
    publisher.assign(to:
        \.value, on: newObject)
}

//MARK:- 2.3.0 - Hello Cancellable
example(of: "Cancellable") {
    /// Summary: Create a Notification, A publisher for it, and an observer. Send notification Once
    /// 1. Create a notification name.
    let notification = Notification.Name("MyNotification")
    /// 2. Access Notification Centers Default publisher
    let publisher = NotificationCenter.default.publisher(for: notification)
    /// 3.  Access Notification Center
    let center = NotificationCenter.default
    /// 4. Create a subscription using .sink
    let subscription = publisher.sink { _ in
        print("Notification recieved from publisher")
    }
    /// 5. Post a notificaition
    center.post(name: notification, object: nil)
    /// 6. Cancel subscription to clear memory.
    /// You don't have to cancel.
    subscription.cancel()
}

// MARK:- 2.3.1 - Custom Subscriber
example(of: "Custom Subscriber") {
    // 1. Create a Publisher
    // Needs to be an Integer, b/c Subscriber expects Into as Input
    let publisher = (7...12).publisher
    
    // 2. Define Custom Subscriber Class
    final class IntSubscriber: Subscriber {
        // 3. Typealiases
        typealias Input = Int
        typealias Failure = Never
        
        // 4. Function Stubs required by Protocol
        func receive(subscription: Subscription) {
            // 6. Only Recieve up to 3 values from subscription.
            subscription.request(.max(3))
        }
        
        func receive(_ input: Int) -> Subscribers.Demand {
            print("Received value", input)
            // Doesnt add to max
//            return .none
            // Adds to the max each time
            return .unlimited
        }
        
        func receive(completion: Subscribers.Completion<Never>) {
            print("Received completion", completion)
        }
    }
    // 5. Create Subscriber and Publisher
    let subscriber = IntSubscriber()
    publisher.subscribe(subscriber)
}

// MARK:- 2.4.0 Hello Future
example(of: "Future") {
    
    
    // 1. Create function that returns a future (essentailly, a promise)
    func futureIncrement(integer: Int, afterDelay delay: TimeInterval) -> Future<Int, Never> {
        Future<Int, Never> { promise in
            // A Future Executes as soon as it is created.
            print("Original")
            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                promise(.success(integer + 1))
            }
        }
    }
    
    // 2. Create a future
    let future = futureIncrement(integer: 1, afterDelay: 3)
    

    // 3. Subscribe to future
    future
        .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    // 4. A Second Subscription to the future
    future
        .sink(receiveCompletion: { print("Second: ", $0) }, receiveValue: { print("Second: ", $0) })
        .store(in: &subscriptions)
}

// MARK:- 2.5.0 Hello Subject
// MARK:- 2.5.1 Passthrough Subject
example(of: "Passthrough Subject") {
    // 1. Define Error Type
    enum MyError: Error {
        case test
    }
    
    // 2. Define a custom subscriber that recieves Strings and MyErrors.
    final class StringSubscriber: Subscriber {
        typealias Input = String
        typealias Failure = MyError
        
        func receive(subscription: Subscription) {
            subscription.request(.max(2))
        }
        
        func receive(_ input: String) -> Subscribers.Demand {
            print("Recieved Value: ", input)
            // 3. Adjust demand based on the recieved value.
            return input == "World" ? .max(1) : .none
        }
        
        func receive(completion: Subscribers.Completion<MyError>) {
            print("Received Completion", completion)
        }
    }
    
    // 4. Create Subscriber
    let subscriber = StringSubscriber()
    
    // 5. Create an instance of Passthrough Subject
    let subject = PassthroughSubject<String, MyError>()
    
    // 6. subscribe to subject
    subject.subscribe(subscriber)
    
    // 7. Create another subscription using a sink.
    let subscription = subject
        .sink { completion in
            print("Recieved Completion (sink): ", completion)
        } receiveValue: { value in
            print("Recieved Value: ", value)
        }

    subject.send("Hello")
    subject.send("World")
    subscription.cancel()
    
    subject.send("Still there?")
    // Error type here
//    subject.send(completion: .failure(.test))
    subject.send(completion: .finished)
    subject.send("How about another one?")
}

// MARK:- 2.5.2 Current Value Subject
example(of: "CurrentValueSubject") {
    // 1. Create subscription set
    var newSubscriptions = Set<AnyCancellable>()
    
    // 2. CurrentValueSubject Int and Never
    let subject = CurrentValueSubject<Int, Never>(0)
    
    // 3. Create a subscription to the subject.
    subject
        .print()
        .sink(receiveValue: { print($0) })
        .store(in: &newSubscriptions)
    
    subject.send(1)
    subject.send(2)
    
    // 4. You can ask a CurrnetValueSubject for its CurrentValue
    print("Current Value: ", subject.value)
    
    // 5. Create a second subscription to the subject.
    subject
        .print()
        .sink(receiveValue: { print("Second Subscription: ", $0) })
        .store(in: &newSubscriptions)
    
    subject.send(completion: .finished)
}

// MARK:- 2.6.0 Dynamically Adjusting Demand
example(of: "Dynamically Adjusting Demand") {
    final class IntSubscriber: Subscriber {
        typealias Input = Int
        typealias Failure = Never
        
        func receive(subscription: Subscription) {
            subscription.request(.max(2))
        }
        
        func receive(_ input: Int) -> Subscribers.Demand {
            print("Recieved Value: ", input)
            switch input {
            case 1:
                return .max(2)
            case 3:
                return .max(1)
            default:
                return .none
            }
        }
        
        func receive(completion: Subscribers.Completion<Never>) {
            print("Recieve Completion: ", completion)
        }
    }
    
    let subscriber = IntSubscriber()
    
    let subject = PassthroughSubject<Int, Never>()
    
    subject.subscribe(subscriber)
    
    subject.send(1)
    subject.send(2)
    subject.send(3)
    subject.send(4)
    subject.send(5)
    subject.send(6)
}

// MARK:- 2.7.0 Type Erasure
example(of: "Type Erasure") {
    // 1. Create a PassthroughSubject
    let subject = PassthroughSubject<Int, Never>()
    // 2. Create a type erased publisher
    let publisher = subject.eraseToAnyPublisher()
    // 3. Subscribe to type-erased publisher
    publisher
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    // 4. Send a new value thru passthrough subject
    subject.send(0)
    
    //5.  Cant do this:
    // publisher.send(1)
}



/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.
