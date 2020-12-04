//: [Previous](@previous)
import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()
//: ## Designing your fallible APIs
example(of: "Joke API") {
  class DadJokes {
    
    struct Joke: Codable {
      let id: String
      let joke: String
    }
    
    enum Error: Swift.Error, CustomStringConvertible {
      case network
      case jokeDoesntExist(id: String)
      case parsing
      case unknown
      
      var description: String {
        switch self {
        case .network:
          return "Request to API Server Failed"
        case .parsing:
          return "Failed parsing response from server"
        case .jokeDoesntExist(let id):
          return "Joke ID \(id) doesn't exist"
        case .unknown:
          return "An unknown error occurred"
        }
      }
    }
    
    
    
    func getJoke(id: String) -> AnyPublisher<Joke, Error> {
      
      guard id.rangeOfCharacter(from: .letters) != nil else {
        return Fail<Joke, Error>(error: .jokeDoesntExist(id: id))
          .eraseToAnyPublisher()
      }
      
      
      let url = URL(string: "https://icanhazdadjoke.com/j/\(id)")!
      var request = URLRequest(url: url)
      request.allHTTPHeaderFields = [
        "Accept": "application/json"
      ]
      return URLSession.shared
        .dataTaskPublisher(for: request)
        .tryMap{ data, _ -> Data in
          guard let obj = try? JSONSerialization.jsonObject(with: data),
                let dict = obj as? [String: Any],
                dict["status"] as? Int == 404
          else {
            return data
          }
          throw DadJokes.Error.jokeDoesntExist(id: id)
        }
        .decode(type: Joke.self, decoder: JSONDecoder())
        .mapError{ error -> DadJokes.Error in
          switch error {
          case is URLError:
            return .network
          case is DecodingError:
            return .parsing
          default:
            return error as? DadJokes.Error ?? .unknown
          }
          
        }
        .eraseToAnyPublisher()
    }
  }
  
  let api = DadJokes()
  let jokeId = "9prWnjyImyd"
  let badJokeId = "123456"
  
  api.getJoke(id: jokeId)
    .sink(receiveCompletion: {print("Completion: \($0)")}) { joke in
      print("Value: \(joke)")
    }
    .store(in: &subscriptions)
  
  api.getJoke(id: badJokeId)
    .sink(receiveCompletion: {print("Completion: \($0)")}) { joke in
      print("Value: \(joke)")
    }
    .store(in: &subscriptions)

}
//: [Next](@next)

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
