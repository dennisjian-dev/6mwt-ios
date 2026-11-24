//
//  Tutorial.swift
//  NtutSixmwt
//
//  Created by BioLab.NTUT on 2021/10/17.
//

import SwiftUI
import UserNotifications

struct TutorialView: View {
    @State var show:Bool = false
    @ObservedObject var viewModel = TutorialViewModel()
    
    var body: some View {
        VStack{
            ScrollView(.vertical){
                VStack{
                    Text(viewModel.getText())
                        .fontWeight(.semibold)
                        .font(.system(size: 17))
                        .tracking(1)
                        .lineSpacing(5)
                        .foregroundColor(Color(red:0.06, green:0.5, blue:1))
                        .padding(10)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(3)
    }
}

struct TutorialView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialView()
    }
}
