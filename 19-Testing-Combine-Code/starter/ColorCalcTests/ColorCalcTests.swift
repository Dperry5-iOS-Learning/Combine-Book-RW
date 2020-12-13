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
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACTa, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import XCTest
import Combine
import SwiftUI
@testable import ColorCalc

class ColorCalcTests: XCTestCase {
  var viewModel: CalculatorViewModel!
  var subscriptions = Set<AnyCancellable>()
  
  override func setUp() {
    viewModel = CalculatorViewModel()
  }
  
  override func tearDown() {
    subscriptions = []
  }
  
  // MARK:- Issue 1: Incorrect name displayed
  func test_correctNameRecieved() {
    // GIVEN
    let expected = "rwGreen 66%"
    var result = ""
    viewModel.$name
      .sink(receiveValue: { result = $0 })
      .store(in: &subscriptions)
    
    // WHEN
    viewModel.hexText = "006636AA"
    
    // THEN
    XCTAssert(result == expected, "Name expected to be \(expected) but was \(result)")
  }
  
  // MARK:- Issue #2: Tapping Backspace deletes two characters
  func test_processBackspaceDeletesLastCharacter() {
    // GIVEN
    let expected = "#0080F"
    var result = ""
    viewModel.$hexText
      .dropFirst()
      .sink(receiveValue: { result = $0})
      .store(in: &subscriptions)
    
    // WHEN
    viewModel.process(CalculatorViewModel.Constant.backspace)
    
    // THEN
    XCTAssert(result == expected, "Hex was expected to be \(expected) but was \(result)")
  }
  
  // MARK:- Issue #3: Incorrect background color
  func test_correctColorReceived() {
    // GIVEN
    let expected = Color(hex: ColorName.rwGreen.rawValue)!
    var result: Color = .clear
    
    viewModel.$color
      .sink(receiveValue: { result = $0})
      .store(in: &subscriptions)
    
    // WHEN
    viewModel.hexText = ColorName.rwGreen.rawValue
    
    // THEN
    XCTAssert(result == expected, "Color expected to be \(expected) but was \(result)")
  }
  
  func test_processBackspaceReceivesCorrectColor() {
    // GIVEN
    let expected = Color.white
    var result = Color.clear
    
    viewModel.$color
      .sink(receiveValue: { result = $0})
      .store(in: &subscriptions)
    // WHEN
    viewModel.process(CalculatorViewModel.Constant.backspace)
    
    // THEN
    XCTAssert(result == expected, "Hex was expected to be \(expected) but was \(result)")
  }
  
  func test_whiteColorReceivedForBadData() {
    // GIVEN
    let expected = Color.white
    var result = Color.clear
    
    viewModel.$color
      .sink(receiveValue: { result = $0})
      .store(in: &subscriptions)
    
    // WHEN
    viewModel.hexText = "abc"
    
    // THEN
    XCTAssert(result == expected, "Hex was expected to be \(expected) but was \(result)")
  }
}
