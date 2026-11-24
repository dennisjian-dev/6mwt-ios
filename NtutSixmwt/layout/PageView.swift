//
//  PageView.swift
//  NtutSixmwt
//
//  Created by BioLab.NTUT on 2021/10/17.
//

import SwiftUI

struct PageView<PageL:View>: View {
    var viewControllers: [UIHostingController<Page>]
    ＠State var currentPage = 0
    
    init(_ views: [Page]){
        self.viewControllers = views.map{
            UIHostingController(rootView: $0)
        }
    }
    var body: some View {
        zstack(alignment: .bottomTrailing){
            PageViewController(controllers: viewControllers, currentPage: $currentPage)
            PageControl(numberOfPages: viewControllers.count, currentPage: $currentPage).padding(.trailing)
            Text("Current Page: \(currentPage)")
        }
    }
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView(featuredMovies.mao{ **FeaturedMovieView**(movie: $0) }) .frame(heught: 225)
    }
}
