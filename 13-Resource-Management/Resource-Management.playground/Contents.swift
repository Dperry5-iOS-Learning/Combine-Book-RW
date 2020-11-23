import UIKit
import Combine

var str = "Hello, playground"

// Share Operator
func shareExample() {
    // Share isn't really needed here.
    // If you add on late, it messed it up.
    let shared = URLSession.shared
        .dataTaskPublisher(for: URL(string: "https://www.raywenderlich.com")!)
        .map(\.data)
        .print("shared")
        .share()
    
    print("Subscribing first")
    
    let subscription1 = shared
        .sink(receiveCompletion: { _ in }, receiveValue: { print("Subscription2 recieved: '\($0)'")
        })
    
    print("Subscribing Second")
    
    let subscription2 = shared.sink(receiveCompletion: { _ in }, receiveValue: { print("Subscription 2 Recieved: '\($0)'" )}
    )
}

func multicastExample() {
    let subject = PassthroughSubject<Data, URLError>()
    let multicasted = URLSession.shared
        .dataTaskPublisher(for: URL(string: "https://www.raywenderlich.com")!)
        .map(\.data)
        .print("shared")
        .multicast(subject: subject)
    
    
    let subscription1 = multicasted
        .sink(receiveCompletion: {_ in } , receiveValue: {
            print("Subscription 1 Recieved: '\($0)'")
        })
    
    let subscription2 = multicasted
        .sink(receiveCompletion: {_ in } , receiveValue: {
            print("Subscription 1 Recieved: '\($0)'")
        })
    
    multicasted.connect()
    
    subject.send(Data())
}


func futureExample() {
    
    func performSomeWork() throws -> Int {
        return 3
    }
    
    let future = Future<Int, Error> { fulfill in
        do {
            let result = try performSomeWork()
            fulfill(.success(result))
        } catch {
            fulfill(.failure(error))
        }
    }
}

shareExample()
multicastExample()
