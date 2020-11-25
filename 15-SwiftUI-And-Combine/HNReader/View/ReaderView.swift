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

import SwiftUI
import Combine

struct ReaderView: View {
  
  private let timer = Timer.publish(every: 10, on: .main, in: .common)
    .autoconnect()
    .eraseToAnyPublisher()
  
  @ObservedObject
  var model: ReaderViewModel
  
  @State
  var presentingSettingsSheet = false

  @State
  var currentDate = Date()
  
  @Environment(\.colorScheme)
  var colorScheme: ColorScheme
  
  @EnvironmentObject
  var settings: Settings
  
  init(model: ReaderViewModel) {
    self.model = model
  }
  
  var body: some View {
    return NavigationView {
      List {
        Section(header: getHeader()) {
          ForEach(self.model.stories) { story in
            VStack(alignment: .leading, spacing: 10) {
              TimeBadge(time: story.time)
              
              Text(story.title)
                .frame(minHeight: 0, maxHeight: 100)
                .font(.title)
              
              PostedBy(time: story.time, user: story.by, currentDate: self.currentDate)
              
              Button(story.url) {
                print(story)
              }
              .font(.subheadline)
              .foregroundColor(self.colorScheme == .light ? .blue : .orange)
              .padding(.top, 6)
            }
            .padding()
          }
          .onReceive(timer) {
            self.currentDate = $0
          }
        }.padding()
      }
      // Present the Settings sheet here
      .sheet(isPresented: $presentingSettingsSheet) {
        SettingsView()
          .environmentObject(settings)
      }
      .alert(item: self.$model.error) { error in
        Alert(
          title: Text("Network Error"),
          message: Text(error.localizedDescription),
          dismissButton: .cancel()
        )
      }
      .navigationBarTitle(Text("\(self.model.stories.count) Stories"))
      .navigationBarItems(trailing:
        Button("Settings") {
          // Set presentingSettingsSheet to true here
            
            presentingSettingsSheet = true
          
        }
      )
    }
  }
  
  private func getHeader() -> AnyView {

    guard !settings.keywords.isEmpty else {
      let defaultFilter = "Showing all stories"
      return AnyView(Text(defaultFilter).padding(.leading, -10))
    }
    
    let filters = settings.keywords.map { $0.value}.joined(separator: ", ")
    return AnyView(Text(filters).padding(.leading, -10))
  }
  
}

#if DEBUG
struct ReaderView_Previews: PreviewProvider {
  static var previews: some View {
    ReaderView(model: ReaderViewModel())
  }
}
#endif
