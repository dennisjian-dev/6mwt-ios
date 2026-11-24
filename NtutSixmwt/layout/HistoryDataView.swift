//
//  HistoryDataView.swift
//  NtutSixmwt
//
//  Created by BioLab.NTUT on 2021/12/13.
//

import SwiftUI

struct HistoryDataView: View {
    @ObservedObject var historyDataModel = HistoryDataViewModel()
    @State var checkVisible:Bool = false
    init() {
//        UITableViewCell.appearance().backgroundColor = UIColor(Color(red:0.235, green:0.725, blue:1))
//        UITableView.appearance().backgroundColor = UIColor(Color(red:0.235, green:0.725, blue:1))
    }
    var body: some View {
        GeometryReader { gr in
            let width = gr.size.width
            let height = gr.size.height
            LoadingView(isShowing: Binding<Bool>(get:{self.historyDataModel.showLoading}, set:{_ in}), text: "wait"){
                VStack(alignment:.leading, spacing: 2){
                    HStack{
                        Text("測試紀錄").fontWeight(.black).foregroundColor(Color(red:0.235, green:0.725, blue:1))
                        Text(verbatim: self.historyDataModel.alterModel.showAlert).opacity(0)

                        Spacer()
                        Button(action:{
                            if(checkVisible){
                                checkVisible = false
                                self.historyDataModel.cleanCheck()
                            }else{
                                checkVisible = true
                            }
                        }, label:{
                            if(!checkVisible){
                                Text("多選").fontWeight(.semibold).foregroundColor(Color.white).padding(3)
                            }else{
                                Text("取消多選").fontWeight(.semibold).foregroundColor(Color.white).padding(3)
                            }
                        }).background(Color(red: 0.35, green: 0.67, blue: 0.67))
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                        
                    }.padding(2)
                    .frame(width: width, height: height/15, alignment: .leading)
                    .background(Color(red:0.93, green:0.93, blue:0.93))
                    
                    Spacer()
                    
                    List{
                        ForEach( self.historyDataModel.dataList.indices, id: \.self){ (idx) in
                            CardView(checkVisible: $checkVisible, filter: self.$historyDataModel.dataList[idx])
                        }.onDelete(perform: { indexSet in
                            self.historyDataModel.deleteData(indices: indexSet)
                            let indices = Array(indexSet)
                            if(indices.count > 0){
                                let index: IndexSet = [indices[0]]
                                self.historyDataModel.dataList.remove(atOffsets: index)
                            }
                        }).listRowBackground(Color(red:0.235, green:0.725, blue:1))
                    }.body.background(Color(red:0.235, green:0.725, blue:1))
                    
                    Spacer()
                    if(checkVisible){
                        HStack(alignment: .center){
                            Button(action:{
                                self.historyDataModel.postData()
                            }, label:{
                                Text("傳送資料")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(5)
                            }).background(Color(red: 0.35, green: 0.67, blue: 0.67))
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                            
                            
                        }.padding(2)
                        .frame(width: width, height: height/15, alignment: .center)
                        .background(Color(red:0.235, green:0.725, blue:1))
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(Color(red:0.235, green:0.725, blue:1))
                .onAppear(){
                    self.historyDataModel.updateList()
                }
            }.alert(isPresented: Binding<Bool>(get:{self.historyDataModel.alterModel.isShow},
                                               set:{ _ in self.historyDataModel.alterModel.resetAlert()})){
                 return Alert(title: Text(self.historyDataModel.alterModel.title),
                 message: Text(self.historyDataModel.alterModel.content),
                 dismissButton: .default(Text("OK")))
             }
        }
    }
}

struct HistoryDataView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryDataView()
    }
}


struct CardView: View{
    @Binding var checkVisible: Bool
    @Binding var filter: TestData
    var body: some View{
        HStack{
            if(checkVisible == true){
                ZStack{
                    Circle()
                        .stroke(filter.checked ? Color.orange:
                                    Color.white, lineWidth: 1)
                        .frame(width:15, height: 15)
                    if filter.checked{
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size:15))
                            .foregroundColor(Color.orange)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture (perform:{
                    filter.checked.toggle()
                })
                Text(filter.Time).fontWeight(.semibold).foregroundColor(Color.white)
                Spacer()
            }else{
                NavigationLink(destination: TestDataDetailView(testData: filter)){
                    Text(filter.Time).fontWeight(.semibold).foregroundColor(Color.white)
                }
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
        .listRowBackground(Color(red:0.235, green:0.725, blue:1))
    }
}




