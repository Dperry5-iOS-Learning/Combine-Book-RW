// 1
import Foundation
import SwiftUI
import CoreData
import ChuckNorrisJokesModel

// 2
extension JokeManagedObject {
  // 3
  static func save(joke: Joke, inViewContext viewContext: NSManagedObjectContext) {
    // 4
    guard joke.id != "error" else { return }
    // 5
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(
      entityName: String(describing: JokeManagedObject.self))
    // 6
    fetchRequest.predicate = NSPredicate(format: "id = %@", joke.id)
    
    // 7
    if let results = try? viewContext.fetch(fetchRequest),
       let existing = results.first as? JokeManagedObject {
      existing.value = joke.value
      existing.categories = joke.categories as NSArray
      existing.languageCode = joke.languageCode
      existing.translationLanguageCode = joke.translationLanguageCode
      existing.translatedValue = joke.translatedValue
    } else {
      // 8
      let newJoke = self.init(context: viewContext)
      newJoke.id = joke.id
      newJoke.value = joke.value
      newJoke.categories = joke.categories as NSArray
      newJoke.languageCode = joke.languageCode
      newJoke.translationLanguageCode = joke.translationLanguageCode
      newJoke.translatedValue = joke.translatedValue
    }
    
    // 9
    do {
      try viewContext.save()
    } catch {
      fatalError("\(#file), \(#function), \(error.localizedDescription)")
    }
  }
}

extension Collection where Element == JokeManagedObject, Index == Int {
  // 1
  func delete(at indices: IndexSet, inViewContext viewContext: NSManagedObjectContext) {
    // 2
    indices.forEach { index in
      viewContext.delete(self[index])
    }
    
    // 3
    do {
      try viewContext.save()
    } catch {
      fatalError("\(#file), \(#function), \(error.localizedDescription)")
    }
  }
}
