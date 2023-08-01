//
//  View+Helpers.swift
//
//  Copyright (c) Andres F. Lozano
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//


import SwiftUI


extension View {
  
  func asUIImage() -> UIImage {
    let controller = UIHostingController(rootView: self)
    
    controller.view.backgroundColor = .clear
    
    controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
    UIApplication.shared.windows.first?.rootViewController?.view.addSubview(controller.view)
    
    let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
    controller.view.bounds = CGRect(origin: .zero, size: size)
    controller.view.sizeToFit()
    
    let image = controller.view.asUIImage()
    controller.view.removeFromSuperview()
    return image
  }
}
