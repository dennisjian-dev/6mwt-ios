//
//  TabnavigatorView.swift
//  NtutSixmwt
//
//  Created by BioLab.NTUT on 2021/10/17.
//
import SQLite3
import SwiftUI

struct TabNavigatorView: View {
    @ObservedObject var tabNavigatorModel = TabNavigatorViewModel()

    var body: some View {
        TabView{
            TutorialView().tabItem {
                VStack{
                    Image("guide_bk").resizable().renderingMode(/*@START_MENU_TOKEN@*/.template/*@END_MENU_TOKEN@*/).aspectRatio(contentMode: .fit)
                    Text("使用教學").fontWeight(.semibold)
                }.tag(2)
            }
            PersonalDataView().tabItem {
                VStack {
                    Image("identification_bk").resizable().renderingMode(/*@START_MENU_TOKEN@*/.template/*@END_MENU_TOKEN@*/).aspectRatio(contentMode: .fit)
                    Text("使用者資料").fontWeight(.semibold)
                }.tag(1)
            }
            TestingView().tabItem {
                VStack{
                    Image("test_bk").resizable().renderingMode(/*@START_MENU_TOKEN@*/.template/*@END_MENU_TOKEN@*/).aspectRatio(contentMode: .fit)
                    Text("開始測試").fontWeight(.semibold)
                }.tag(3)
            }
            HistoryDataView().tabItem {
                VStack{
                    Image("heartrate_bk").resizable().renderingMode(/*@START_MENU_TOKEN@*/.template/*@END_MENU_TOKEN@*/).aspectRatio(contentMode: .fit)
                    Text("測試資料").fontWeight(.semibold)
                }.tag(4)
            }.accentColor(.green)
        }
    }
    
}

struct TabNavigatorView_Previews: PreviewProvider {
    static var previews: some View {
        TabNavigatorView()
    }
}

struct TabItemView: View{
    var image: String
    var text: String
    var body: some View{
        VStack{
            
        }
    }
}


