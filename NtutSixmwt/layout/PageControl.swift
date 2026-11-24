//
//  PageControl.swift
//  NtutSixmwt
//
//  Created by BioLab.NTUT on 2021/10/17.
//

import SwiftUI

struct PageControl: UIViewRepresentable {
    var numberOfPage: Int
    @Binding var currentPage: Int
    
    func makeCorrdinator() -> Corrdinator{
        Coordinator(self)
    }
    
    func makeUIView(context: Context)-> UIPageControl{
        let control = UIPageControl()
        control.numberOfPages = numberOfPages
        control.addTarget(context.coordinator,
                          action:#selector(Cooedinator.updateCurrentPage(sender:)), for: .valueChanged)
        return control
    }
    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.currentPage = currentPage
    }
    
    class Coordinator: NSObject{
        var control: PageControl
        init(_ control: PageControl){
            self.control = control
        }
        @objc func updateCurrentPage(sender: UIPageControl){
            control.currentPage = sender.currentPage
        }
    }
}

struct PageControl_Previews: PreviewProvider {
    static var previews: some View {
        PageControl()
    }
}
