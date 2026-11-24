//
//  TutorialViewModel.swift
//  NtutSixmwt
//
//  Created by BioLab.NTUT on 2022/3/28.
//

import Foundation
class TutorialViewModel: ObservableObject {
    private var ks = KeychainService()
    
    @Published var text: String = ""
    init(){

    }

    
    func getText()->String{
        var text = ""
        text.append(contentsOf: "注意1：請先確認是否有授權資料，如果沒有授權請先回首頁進行授權。\n")
        text.append(contentsOf: "注意2：測試前請先在戴上手錶的情況下休息2分鐘以上，再進行測試。\n")
        text.append(contentsOf: "第一步：先至使用者資料頁面下載fitbit使用者資料，")
        text.append(contentsOf: "若下載資料有誤，可直接進行修改，或至fitbit app 進行修改。\n")
        text.append(contentsOf: "第二步：至測試頁面按下播放鍵，即可開始測試，")
        text.append(contentsOf: "測試期間總共有2個階段:1.步行測試(6分鐘)、2.休息靜待(3分鐘)，")
        text.append(contentsOf: "請等待2階段結束再進行下一步。\n")
        text.append(contentsOf: "第三步：打開fitbit app下滑更新手錶資料，")
        text.append(contentsOf: "（注意：需同時開啟藍芽與定位功能）\n")
        text.append(contentsOf: "第四步：回到此APP按下下載按鈕，")
        text.append(contentsOf: "若下載成功，即可至測試資料頁面點擊資料進行觀看。\n")
        text.append(contentsOf: "第五步：在測試資料頁面按下右上角的多選按鈕，")
        text.append(contentsOf: "按資料左邊的圓點進行勾選，再按下下方的傳送按鈕將資料上傳雲端，")
        text.append(contentsOf: "日後可以得到更進一步的分析結果。\n")
        return text
    }

}
