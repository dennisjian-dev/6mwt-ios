//
//  PersonalData.swift
//  NtutSixmwt
//
//  Created by BioLab.NTUT on 2021/10/17.
//

import SwiftUI

struct PersonalDataView: View {
    @StateObject var viewModel = PersonalDataViewModel()
    init(){
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
    }
    var body: some View {
        GeometryReader { gr in
            let width = gr.size.width
            let height = gr.size.height
            let tbWidth = width * 0.7
            let tbHeight = height * 0.5
            VStack{
                VStack{}.frame(width: width, height: height * 0.2)
                VStack(spacing:0){
                    HStack{
                        Text("名稱: ")
                        TextField("", text: Binding<String>(get: {viewModel.user!.FullName},
                                                    set:{viewModel.user!.FullName =  $0}))
                    }.frame(width: tbWidth*0.8, height: tbHeight/6)
                    HStack{
                        Text("性別: ")
                        TextField("", text: Binding<String>(get: {viewModel.user!.Gender},
                                                            set:{viewModel.user!.Gender =  $0}))
                    }.frame(width: tbWidth*0.8, height: tbHeight/6)
                    HStack{
                        Text("生日: ")
                        TextField("", text: Binding<String>(get: {viewModel.user!.Birth},
                                                            set:{viewModel.user!.Birth =  $0}))
                    }.frame(width: tbWidth*0.8, height: tbHeight/6)
                    HStack{
                        Text("身高: ")
                        TextField("", text: Binding<String>(get: {viewModel.user!.Height},
                                                            set:{viewModel.user!.Height =  $0}))
                    }.frame(width: tbWidth*0.8, height: tbHeight/6)
                    HStack{
                        Text("體重: ")
                        TextField("", text: Binding<String>(get: {viewModel.user!.Weight},
                                                            set:{viewModel.user!.Weight =  $0}))
                    }.frame(width: tbWidth*0.8, height: tbHeight/6)
                    HStack{
                        Text("步長: ")
                        TextField("", text: Binding<String>(get: {viewModel.user!.StrideLengthWalking},
                                                            set:{viewModel.user!.StrideLengthWalking =  $0}))
                    }.frame(width: tbWidth*0.8, height: tbHeight/6)
                }.frame(width: tbWidth, height: tbHeight)
                .background(Color(red:0.95, green:0.95, blue:0.95))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                VStack{}.frame(width: width, height: height * 0.1)
                HStack(spacing:20){
                    Button{
                        self.viewModel.downLoadPersonalData()
                    }label:{
                        Text("下載資料")
                            .fontWeight(.black)
                            .foregroundColor(Color(red:0.235, green:0.725, blue:1))
                            .padding(15)
                    }.background(Color.white).clipShape(Capsule())
                    Button{
                        self.viewModel.saveUserData()
                    }label:{
                        Text("儲存修改")
                            .fontWeight(.black)
                            .foregroundColor(Color(red:0.235, green:0.725, blue:1))
                            .padding(15)
                    }.background(Color.white).clipShape(Capsule())
                }.frame(width: tbWidth, height: tbHeight/6)
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top).background(Color(red:0.235, green:0.725, blue:1))
        }
    }
}

struct PersonalDataView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalDataView()
    }
}
