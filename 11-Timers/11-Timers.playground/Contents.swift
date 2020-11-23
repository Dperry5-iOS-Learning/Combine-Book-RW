import UIKit
import Combine

var str = "Hello, playground"
var subscriptions: Set<AnyCancellable> = []

// MARK:- Run Loop
func runLoopExample() {
    let runLoop = RunLoop.main
    let cancellable = runLoop.schedule(after: runLoop.now, interval: .seconds(1), tolerance:.milliseconds(100)) {
        print("timer fired!")
    }
    
    runLoop.schedule(after: .init(Date(timeIntervalSinceNow: 3.0))) {
        cancellable.cancel()
    }
}

func timerExample() {
    // Connectable Publisher, so need to connect
    Timer
        .publish(every: 1.0, on: .main, in: .common)
        .autoconnect()
        .prefix(10)
        .scan(0) { counter, _ in counter + 1 }
        .sink { counter in
            print("Counter is \(counter)")
        }
        .store(in: &subscriptions)
}

func dispatchQueueExample() {
    print("HERE")
    let queue = DispatchQueue.main
    
    let source = PassthroughSubject<Int, Never>()
    
    var counter = 0
    
   
    let cancellable = queue.schedule(after: queue.now, interval: .seconds(1)) {
        source.send(counter)
        counter += 1
    }
    
    source.sink {
            print("Timer Emitted: \($0)")
        }
        .store(in: &subscriptions)
    

    
    
}





runLoopExample()
timerExample()
dispatchQueueExample()

