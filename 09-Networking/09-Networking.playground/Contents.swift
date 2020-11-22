import UIKit
import Combine

var str = "Hello, playground"

struct Wrapper: Codable {
    let results: [Film]
}

struct Film: Codable {
    let title: String
    let episode_id: Int
}


var subscriptions: Set<AnyCancellable> = []

func URLSessionExtensions() {
    guard let url = URL(string: "https://swapi.dev/api/films/") else { return }
    URLSession.shared
        .dataTaskPublisher(for: url)
        .sink(receiveCompletion: { completion in
            if case .failure(let err) = completion {
                print("Retrieving Data failed with error: \(err)")
            }
        }, receiveValue: { data, response in
            print("Retrieved data of size \(data.count), response = \(response)")
        })
        .store(in: &subscriptions)
}

func withCodable(){
    guard let url = URL(string: "https://swapi.dev/api/films/") else { return }
    URLSession.shared
        .dataTaskPublisher(for: url)
        .map(\.data)
        .decode(type: Wrapper.self, decoder: JSONDecoder())
        .sink(receiveCompletion: { completion in
            if case .failure(let err) = completion {
                print("Retrieving Data failed with error: \(err)")
            }
        }, receiveValue: { wrapper in
            print("Retrieved response of: \(wrapper.results)")
        })
        .store(in: &subscriptions)
}

func withMulticast() {
    guard let url = URL(string: "https://swapi.dev/api/films/") else { return }
    
    let publisher = URLSession.shared
        .dataTaskPublisher(for: url)
        .map(\.data)
        .decode(type: Wrapper.self, decoder: JSONDecoder())
        .multicast {
            PassthroughSubject<Wrapper, Error>()
        }
    
   publisher
        .print("Sink 1: ")
        .sink(receiveCompletion: { completion in
            if case .failure(let err) = completion {
                print("Sink 1: Retrieving Data failed with error: \(err)")
            }
        } , receiveValue: { wrapper in
            print("Sink 1: Retrieved Object: \(wrapper)")
        })
    .store(in: &subscriptions)
    
    publisher
        .print("Sink 2: ")
         .sink(receiveCompletion: { completion in
             if case .failure(let err) = completion {
                 print("Retrieving Data failed with error: \(err)")
             }
         } , receiveValue: { wrapper in
             print("Retrieved Object: \(wrapper)")
         })
     .store(in: &subscriptions)
    
    publisher.connect()
        .store(in: &subscriptions)
}





URLSessionExtensions()
withCodable()
withMulticast()


