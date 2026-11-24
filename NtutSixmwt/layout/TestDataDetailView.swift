//
//  TestDataDetailView.swift
//  NtutSixmwt
//
//  Created by BioLab.NTUT on 2022/3/1.
//

import SwiftUI
import UIKit
struct TestDataDetailView: View {
    var testData:TestData
    @State var heartValueList:[Double] = []
    @State var heartTimeList:[Double] = []
    @State var stepValueList:[Double] = []
    @State var stepTimeList:[Double] = []
    
    @ObservedObject var vm:TestDataDetailViewModel
//    (testData: TestData(fid: "test", Time: "time",jsonData: "json",startTestingTime: 0, endTestingTime: 0))
    init(testData: TestData){
        self.testData = testData
        self.vm = TestDataDetailViewModel(testData: testData)
        let barAppearance = UINavigationBar()
        barAppearance.backgroundColor = UIColor.init(Color(red:0.24, green:0.24, blue:0.24))
    }
    var body: some View {
        VStack(alignment: .center){
            GeometryReader{ gr in
                let width = gr.size.width
                let height = gr.size.height
                let chartW = width * 0.9
                let chartH = height * 0.9
                let axisWidth = chartW * 0.13
                let axisHeight = chartH * 0.17
                VStack{
                    ScrollView{
                        VStack{
                            Text("每秒心率").font(.system(size: 18)).fontWeight(.black).foregroundColor(Color.white)
                            HStack(spacing: 0){
                                VStack(spacing: 0){
                                    YaxisView(yValue: heartValueList, axisNum: 12, baseValue: 50)
                                        .frame(width: axisWidth, height: chartH - axisHeight)
                                    VStack{}.frame(width: axisWidth, height: axisHeight)
                                }.frame(width: axisWidth, height: chartH)
                                
                                VStack{
                                    ScrollView(.horizontal){
                                        VStack(alignment: .leading ,spacing:0) {
                                            ZStack{
                                                ChartAreaView(xValues: heartTimeList, yValues: heartValueList,
                                                              lineColor: Color(red: 1, green: 0.45, blue: 0.77), maxValue: 170, minValue:50,
                                                              startTime: heartTimeList.min() ?? 1, endTime: heartTimeList.max() ?? 1)
                                                    .frame(width: chartW * 1.5, height: chartH - axisHeight)
                                                
                                                ChartAreaView(xValues: heartTimeList, yValues: heartValueList,
                                                              lineColor: Color.red, maxValue: 170, minValue: 50,
                                                              startTime: self.vm.convertToTimeDouble(mTime: self.vm.startTime),
                                                              endTime: self.vm.convertToTimeDouble(mTime: self.vm.endTime))
                                                    .frame(width: chartW * 1.5, height: chartH - axisHeight)
                                                
                                            }
                                            XaxisView(start: heartTimeList.min() ?? 0, end:heartTimeList.max() ?? 1)
                                                .frame(width: chartW * 1.5, height: axisHeight)
                                        }
                                    }
                                }.frame(width: chartW - axisWidth, height: chartH)
                            }.frame(width: chartW, height: chartH, alignment: .leading)
                            
                            Text("每分鐘步數").font(.system(size: 18)).fontWeight(.black).foregroundColor(Color.white)
                            HStack(spacing: 0){
                                VStack(spacing: 0){
                                    YaxisView(yValue: stepValueList, axisNum: 15, baseValue: 0)
                                        .frame(width: axisWidth, height: chartH - axisHeight)
                                    VStack{}.frame(width: axisWidth, height: axisHeight)
                                }.frame(width: axisWidth, height: chartH)
                                
                                VStack{
                                    ScrollView(.horizontal){
                                        VStack(alignment: .leading ,spacing:0) {
                                            ZStack{
                                                ChartAreaView(xValues: stepTimeList, yValues: stepValueList,
                                                              lineColor:  Color(red: 0.2, green: 0.71, blue: 1), maxValue: 150, minValue: 0,
                                                              startTime: stepTimeList.min() ?? 0,
                                                              endTime: stepTimeList.max() ?? 0)
                                                    .frame(width: chartW * 1.5, height: chartH - axisHeight)
                                                ChartAreaView(xValues: stepTimeList, yValues: stepValueList,
                                                              lineColor: Color(red: 0.17, green: 0.17, blue: 1), maxValue: 150, minValue: 0,
                                                              startTime: self.vm.convertToTimeDouble(mTime: self.vm.startTime),
                                                              endTime: self.vm.convertToTimeDouble(mTime: self.vm.endTime))
                                                    .frame(width: chartW * 1.5, height: chartH - axisHeight)
                                            }
                                            XaxisView(start: stepTimeList.min() ?? 0, end:stepTimeList.max() ?? 1)
                                                .frame(width: chartW * 1.5, height: axisHeight)
                                        }
                                    }
                                }.frame(width: chartW - axisWidth, height: chartH)
                            }.frame(width: chartW, height: chartH, alignment: .leading)
                        }.onAppear{
                            self.vm.decodeHeartJson()
                            self.vm.decodeStepJson()
                            heartValueList = self.vm.getHeartRateValueList()
                            heartTimeList = self.vm.getHeartRateTimeList()
                            stepValueList = self.vm.getStepValueList()
                            stepTimeList = self.vm.getStepTimeList()
                            print("\(width)----\(height)")
                        }.frame(alignment: .center)//vstack
                    }//scroll
                }.frame(width: width, height: height,alignment: .center)
            }//geo
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center).background(Color(red:0.24, green:0.24, blue:0.24))//vstack
    }
}

struct TestDataDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TestDataDetailView(testData: TestData(fid: "test", Time: "time",jsonData: "json",startTestingTime: 0, endTestingTime: 0, checked: false))
    }
}

struct YaxisView: View{
    var yValue: [Double]
    var baseValue:Int
    var axisNum: Int
    let unit = 10
    init(yValue: [Double], axisNum: Int, baseValue: Int){
        self.yValue = yValue
//        if(yValue.count > 1){
//            axisNum = Int((yValue.max()! - yValue.min()!)/Double(unit)) + 1
//        }else{
//            axisNum = 1
//        }
//        baseValue = Int(self.yValue.min() ?? 0)
        self.axisNum = axisNum
        self.baseValue = baseValue
    }
    var body: some View{
        GeometryReader{ gr in
            let width = gr.size.width
            let fullCharHeight = gr.size.height
            let interval = (fullCharHeight)/CGFloat(axisNum)
            ZStack(alignment: .topTrailing){
                ForEach(0...axisNum, id: \.self){ i in
                    Text("\(baseValue + unit * i)")
                        .font(.system(size: 12))
                        .offset(x: -20, y: interval * CGFloat(axisNum - i))
                        .foregroundColor(Color.white)
                    
                    Rectangle()
                        .fill(Color.white)
                        .frame(width:10, height: 2)
                        .offset(x: 5, y: interval * CGFloat(axisNum - i))
                }
                Rectangle()
                    .fill(Color.white)
                    .frame(width:2, height: fullCharHeight)
            }.frame(width: gr.size.width, height: gr.size.height, alignment: .topTrailing)
        }
    }
}


struct XaxisView: View{
    let start: Double
    let end: Double
    @State var dataList:[String]?
    init(start: Double, end: Double){
        self.start = start
        self.end = end
        self.dataList = getData()
    }
    var body: some View{
        GeometryReader { gr in
            ZStack( alignment: .topLeading){
                let dataList = getData()
                let interval = gr.size.width / CGFloat(dataList.count - 1)
                
                ForEach(0..<(dataList.count - 1), id: \.self){ i in
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 2, height: 14)
                        .offset(x: interval * CGFloat(i), y: -10)
                        
                    Text("\(dataList[i])")
                        .rotationEffect(Angle(degrees: 80)).font(.system(size: 12))
                        .offset(x: interval * CGFloat(i) - interval * 0.35, y: interval * 0.5)
                        .foregroundColor(Color.white)
                }//.onAppear{print("interval \(interval)")}
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 2, height: 14)
                    .offset(x: gr.size.width-2, y: -10)
            
                Text("\(dataList[dataList.count - 1])")
                    .rotationEffect(Angle(degrees: 90)).font(.system(size: 12))
                    .offset(x: gr.size.width-35, y: interval * 0.5)
                    .foregroundColor(Color.white)
                Rectangle()
                    .fill(Color.white)
                    .frame(width: gr.size.width, height: 2)
                
            }.frame(width: gr.size.width, height: gr.size.height , alignment: .topLeading)
        }
    }
    func getData() -> [String]{
        var dataList = [String]()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let timeLong = Int((end - start)/60)
        for i in 0...timeLong{
            dataList.append(formatter.string(from: Date.init(timeIntervalSince1970: (start + Double(i) * 60))))
        }
        if(Int(end-start) % 60 != 0){
            dataList.append(formatter.string(from: Date.init(timeIntervalSince1970: end)))
        }
        
//        print("dataList:  \(dataList)")
        return dataList
    }
}


struct ChartAreaView: View {
    var xValues: [Double]
    var yValues: [Double]
    var lineColor:Color
    let maxValue: Double
    let minValue: Double
    let startTime: Double
    let endTime: Double
    var body: some View {
        ZStack {
            HStack(spacing:0) {
                LineShape(xValues: xValues, yValues: yValues, minValue: minValue, maxValue: maxValue, startTime: startTime, endTime: endTime)
                    .stroke(lineColor, lineWidth: 2.0)
            }
            .padding(2)
        }
    }
}
struct LineShape: Shape{
    let xValues: [Double]
    let yValues: [Double]
    let minValue: Double
    let maxValue: Double
    let maxRange: Double
    let startTime: Double
    let endTime: Double
    init(xValues: [Double], yValues: [Double], minValue: Double, maxValue: Double, startTime: Double, endTime: Double){
        self.xValues = xValues
        self.yValues = yValues
        self.minValue = minValue
        self.maxValue = maxValue
        self.maxRange = maxValue - minValue
        self.startTime = startTime
        self.endTime = endTime
    }
    
    func path(in rect: CGRect) -> Path{
        let xIncrement = Double(rect.width)
        var timeLength = 1.0
        if (xValues.count > 1){
            timeLength = xValues.max()! - xValues.min()!
        }
        var factor: Double = Double(rect.height) / 1.0
        if(yValues.count > 0 && yValues.max()! > 0){
            factor = Double(rect.height) / maxRange
        }
        
        
        var path = Path()
        
        if(xValues.count < 1 || yValues.count < 1){
            return path
        }
        
        var cutXValue:[Double] = Array()
        var cutYVulae:[Double] = Array()
        
        for i in 0..<xValues.count{
            if(xValues[i] >= startTime && xValues[i] <= endTime){
                cutXValue.append(xValues[i])
                cutYVulae.append(yValues[i])
            }
        }
        if(cutXValue.count < 1 || cutYVulae.count < 1){
            return path
        }
        
        path.move(to: CGPoint(x: (cutXValue[0] - xValues.min()!)/timeLength * xIncrement,
                              y:Double(rect.height) - (cutYVulae[0]-minValue) * factor))
        
        if(cutYVulae.count > 0){
            for i in 1..<cutXValue.count{
//                print("\((xValues[i] - startPointX)/timeLength * xIncrement) :  \(Double(rect.height) - (yValues[i]-minValue) * factor)")
                if(maxRange == 0){
                    let pt = CGPoint(x: ((cutXValue[i] - xValues.min()!)/timeLength * xIncrement),
                                     y: Double(rect.height))
                    path.addLine(to: pt)
                }else{
                    let pt = CGPoint(x: ((cutXValue[i] - xValues.min()!)/timeLength * xIncrement),
                                     y: Double(rect.height) - (cutYVulae[i]-minValue) * factor)
                    path.addLine(to: pt)
                }
            }
        }
        return path
    }
}

