//
//  PageViewController.swift
//  NtutSixmwt
//
//  Created by BioLab.NTUT on 2021/10/17.
//
import SwiftUI
import UIKit

struct PageViewController: UIViewControllerRepresentable{
    var controllers: [UIViewController]
    @Binding var currentPage: Int
    
    //swiftUI call makeCoordinator before calling makeUIviewController
    func makeCorrdinator() -> Coordinator{
        Coordinator(self)
    }
    func makeUIViewController(context: Context) -> UIPageViewController{
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageViewController.dataSource = context.coordinator
        pageViewController.delegate = context.coordinator
        return pageViewController
    }
    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context){
        pageViewController.setViewControllers(
            [controllers[0]], direction: .forward, animated: true)
    }
    //
    class Coordinator : NSObeject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: PageViewController
        init(_ pageViewController: PageViewController){
            self.parent = pageViewController
        }
        
        func pageViewController(_ pageViewCOntroller: UIPageViewController, didFinishAnimating finished: Bool){
            if completed,
            let visibleViewController = pageViewCOntroller.viewControllers?.first,
            let index = parent.controllers.firstIndex(of: visibleViewController){
                parent.currentPage = index
            }
        }
        //right slide
        func pageViewController(_ pageViewController: UIPageViewController,
                                viewControllerBefore viewController: UIViewController) -> UIViewController?{
            guard let index = parent.controllers.firstIndex(of: viewController) else{
                return nil
            }
            if index == 0{
                self.parent.currentPage = 0
                return parent.controllers.last
            }
            self.parent.currentPage = index
            return parent.controllers[index - 1]
        }
        //left slide
        func pageViewController(_ pageViewController: UIPageViewController,
                                viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let index = parent.controllers.firstIndex(of: viewController) else{
                return nil
            }
            if index + 1 == parent.controllers.count{
                self.parent.currentPage = index
                return parent.controllers.first
            }
            if index == parent.controller.count{
                self.parent.currentPage = parent.controllers.startIndex
            }
            self.parent.currentPage = index
            return parent.controllers[index + 1]
        }
    }
}

struct PageViewController_Previews: PreviewProvider {
    static var previews: some View {
        PageViewController(controllers: <#[UIViewController]#>)
    }
}
