import UIKit
import Combine

var str = "Hello, playground"
var subscriptions: Set<AnyCancellable> = []

// print(_:to:) example.

func printExample() {
    (1...3).publisher
        .print("Publisher")
        .sink { _ in }
}

func textOutputStreamExample(){
    class TimeLogger: TextOutputStream {
        private var previous = Date()
        private let formatter = NumberFormatter()
        
        init() {
            formatter.maximumFractionDigits = 5
            formatter.minimumFractionDigits = 5
        }
        
        func write(_ string: String) {
            let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            let now = Date()
            print("+\(formatter.string(for: now.timeIntervalSince(previous))!)s: \(string)")
            previous = now
        }
    }
    
    (1...3).publisher
        .print("Publisher", to: TimeLogger())
        .sink { _ in }
}


func performingSideEffects() {
    let request = URLSession.shared
        .dataTaskPublisher(for: URL(string: "https://www.raywenderlich.com/")!)
    
    request
        .handleEvents(
            receiveSubscription: { _ in
                print("Network request will start")
            },
            receiveOutput: { _ in
                print("Network request data recieved")
            },
            receiveCancel: {
                print("Network request cancelled")
            }
        )
        .sink(receiveCompletion: { completion in
            print("Received Completion: \(completion)")
        }, receiveValue: { data, _ in
            print("Recieved Data: \(data)")
        })
        .store(in: &subscriptions)
}

// LAST RESORT
// Debuggers dont exist in playgrounds.
func debuggerExample() {
    (1...20).publisher
        .print("Publisher")
        .breakpoint(receiveOutput: { value in
            return value == 10
        })
        .sink { _ in }
        .store(in: &subscriptions)
}


// Execute Functions
printExample()
textOutputStreamExample()
performingSideEffects()
debuggerExample()
