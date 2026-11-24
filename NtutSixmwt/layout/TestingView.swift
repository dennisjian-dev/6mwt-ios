//
//  TestingView.swift
//  NtutSixmwt
//
//  Created by BioLab.NTUT on 2021/10/17.
//

import SwiftUI

struct TestingView: View {
    @StateObject private var tvm = TestingViewModel()
    @Environment(\.scenePhase) var scenePhase
    @State var isActive:Bool = true
    var body: some View {
        GeometryReader { gr in
            let width = gr.size.width
            let height = gr.size.height
            LoadingView(isShowing: Binding<Bool>(get:{self.tvm.showLoading}, set:{_ in}), text: "wait"){
                VStack{
                    VStack{}.frame(width:250, height: height*0.25)
                    VStack(spacing: 30){
                        Text(tvm.testInfo)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 20))
                            .frame(width: width * 0.8, height: height * 0.2)
                            .foregroundColor(Color.white)
                        ZStack{
                            Text(verbatim: self.tvm.alterModel.showAlert).opacity(0)
                            Text(verbatim: "\(self.tvm.showLoading)").opacity(0)
                            Text(verbatim: "\(isActive)").opacity(0).onChange(of: isActive){ isAct in
                                if(isAct){
                                    self.tvm.loadTimerRelated()
                                }else{
                                    if(self.tvm.testingStatus != TestingViewModel.TestingStatus.WaitingStart){
                                        self.tvm.setTimer(option: "pause")
                                    }
                                    self.tvm.saveTimeRelated()
                                }
                                
                            }
                            
                            Text(verbatim: self.tvm.remainedTimeStr)
                                .fontWeight(.semibold)
                                .font(.system(size: 50))
                                .frame(width: width * 0.6, height: height * 0.1)
                                .foregroundColor(Color.white)
                                
                        }
                        HStack{
                            Button(action:{
                                if(self.tvm.testingStatus == TestingViewModel.TestingStatus.WaitingStart){
                                    self.tvm.setTimer(option: "start")
                                }
                                else{
                                    self.tvm.setTimer(option: "reset")
                                }
                            }, label: {
                                if(self.tvm.testingStatus == TestingViewModel.TestingStatus.WaitingStart){
                                    Image(systemName: "play.circle")
                                        .renderingMode(.template)
                                        .resizable().frame(width: 40, height: 40,alignment: .center).foregroundColor(Color.white)
                                }else{
                                    Image(systemName: "stop.circle")
                                        .renderingMode(.template)
                                        .resizable().frame(width: 40, height: 40,alignment: .center).foregroundColor(Color.white)
                                    
                                }
                            }).frame(width: 50, height: 50, alignment: .center)
                            
                            if(self.tvm.testingStatus == TestingViewModel.TestingStatus.Finish){
                                Button(action:{
                                    self.tvm.downLoadFitbitData()
                                    }, label: {
                                        Image(systemName: "icloud.and.arrow.down")
                                            .renderingMode(.template)
                                            .resizable().frame(width: 40, height: 40,alignment: .center).foregroundColor(Color.white)
                                    }
                                ).frame(width: 50, height: 50, alignment: .center)
                            }
                            
                        }.alert(isPresented: Binding<Bool>(get:{self.tvm.alterModel.isShow},
                                                            set:{ _ in self.tvm.alterModel.resetAlert()})){
                            if(self.tvm.testingStatus == TestingViewModel.TestingStatus.WaitingStart){
                                return Alert(title: Text(self.tvm.alterModel.title).fontWeight(.semibold),
                                message: Text(self.tvm.alterModel.content),
                                primaryButton:.destructive(Text("否")){},
                                secondaryButton:.destructive(Text("是")){self.tvm.startTimer()})
                                
                            }else{
                                switch self.tvm.alterModel.isShowOption{
                                    case true:
                                        return Alert(title: Text(self.tvm.alterModel.title).fontWeight(.semibold),
                                        message: Text(self.tvm.alterModel.content),
                                        primaryButton:.destructive(Text("是")){self.tvm.resetTimer()},
                                        secondaryButton:.destructive(Text("否")){})
                                    case false:
                                        if(self.tvm.alertCondition == TestingViewModel.AddDataCondition.AddDataSuccess){
                                            return Alert(title: Text(self.tvm.alterModel.title),
                                            message: Text(self.tvm.alterModel.content),
                                            dismissButton: .default(Text("OK")){self.tvm.resetTimer()})
                                        }else{
                                            return Alert(title: Text(self.tvm.alterModel.title),
                                            message: Text(self.tvm.alterModel.content),
                                            dismissButton: .default(Text("OK")))
                                        }
                                }
                            }
                        }
                    }.frame(width: width*0.8, height: height*0.5)
                    VStack{}.frame(width:250, height: height*0.25)
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center).background(Color(red:0.235, green:0.725, blue:1))
                .onChange(of: scenePhase){ newPhase in
                    if newPhase == .active{
                        isActive = true
                    }
                    else if newPhase == .inactive{
                        isActive = false
                        self.tvm.setNotification()
                    }
                }
            }
        }
    }
}

struct TestingView_Previews: PreviewProvider {
    static var previews: some View {
        TestingView()
    }
}


struct VisibilityStyle: ViewModifier{
    let hidden:Bool
    @ViewBuilder
    func body(content: Content) -> some View{
        if hidden{
            content.hidden()
        }else{
            content
        }
    }
}
extension View{
    func visibility(hidden:Bool) -> some View{
        modifier(VisibilityStyle(hidden: hidden))
    }
}
