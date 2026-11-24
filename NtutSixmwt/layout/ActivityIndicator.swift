//
//  ActivityIndicator.swift
//  NtutSixmwt
//
//  Created by BioLab.NTUT on 2022/3/27.
//

import SwiftUI


struct LoadingView<Content>: View where Content: View{
    @Binding var isShowing:Bool
    var text:String
//    var width: Float
//    var height: Float
    var content: () -> Content
    
    var body: some View{
        GeometryReader{ geometry in
            ZStack(alignment: .center){
                self.content()
                    .disabled(self.isShowing)
                    .blur(radius: self.isShowing ? 3 : 0)
                if(self.isShowing){
                    VStack{
                        ActivityIndicator(text: text)
                    }.edgesIgnoringSafeArea(.all)
                }
            }
//            .frame(width: CGFloat(width), height: CGFloat(height))
        }
    }
}

struct ActivityIndicator: View{
    @State var timer:Timer?
    @State var degrees = 0.0
    var text:String
    
    var body: some View{
        VStack{
            Circle()
                .trim(from: 0, to: 0.8)
                .stroke(AngularGradient(gradient: .init(colors: [Color(red:0.235, green:0.725, blue:1), Color(red: 0, green:0.51, blue: 0.82)]),
                                        center: .center), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: 45, height: 45)
                .rotationEffect(Angle(degrees: degrees))
                .onAppear(perform: {self.start()})
                .onDisappear(perform: {self.stop()})
            Text(text)
        }.padding(20)
        .frame(width: 120, height: 90)
        .background(Color.white)
        .cornerRadius(15)
    }
    
    func start(){
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true){ timer in
            withAnimation{
                self.degrees += 10.0
            }
            if self.degrees == 360.0{
                self.degrees = 0.0
            }
        }
    }
    func stop(){
        self.timer!.invalidate()
    }
}

struct ActivityIndicator_Previews: PreviewProvider {
    static var previews: some View {
        ActivityIndicator(text: "preview")
    }
}
