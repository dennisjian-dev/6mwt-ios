# 6 分鐘走路測試 iOS App（NTUT 6MWT）

NTUT 6MWT 是一款以 SwiftUI 開發的 iOS 應用程式，用於協助使用者進行 6 分鐘走路測試（6-Minute Walk Test, 6MWT）。App 可透過 Fitbit OAuth 取得使用者資料與活動紀錄，並在本機保存測試資料供檢視與後續上傳。

## 主要功能

- Fitbit 帳號授權與權杖保存
- 下載 Fitbit 個人資料，包括名稱、性別、生日、身高、體重與步長
- 執行 6 分鐘步行測試與 3 分鐘休息倒數
- 測試期間與結束後發送本機通知
- 取得測試期間的心率與步數資料
- 使用定位記錄測試相關資訊
- 使用 SQLite 在裝置上保存測試紀錄
- 多選歷史資料並上傳至雲端分析服務
- 支援 iPhone 與 iPad 的主要操作介面

## 技術棧

| 類別 | 使用技術 |
| --- | --- |
| 平台 | iOS 14.0+ |
| UI | SwiftUI |
| 語言 | Swift 5 |
| 帳號授權 | Fitbit OAuth 2.0、AuthenticationServices |
| 網路 | URLSession |
| 資料儲存 | iOS Keychain、SQLite 3 |
| 裝置功能 | CoreLocation、UserNotifications |
| 資料模型 | Codable、Core Data 模型檔案 |
| 專案管理 | Xcode Project |

專案目前沒有使用 CocoaPods、SPM 或 Carthage 等第三方套件管理工具。

## 專案結構

```text
IOSsixmwt-main/
├── NtutSixmwt/
│   ├── NtutSixmwtApp.swift       # App 進入點
│   ├── Assets.xcassets/          # 圖示、圖片與 App Icon
│   ├── CoreData/                 # Core Data 類別與 OAuth 設定
│   ├── codable/                  # Fitbit API 回應資料模型
│   ├── layout/                   # SwiftUI View
│   ├── viewModel/                # 頁面邏輯與狀態管理
│   ├── OtherComponent/           # 網路、Keychain、通知與定位等服務
│   ├── sqlite/                   # SQLite 封裝與橋接檔案
│   ├── NtutSixmwt.xcdatamodeld/  # Core Data 模型
│   ├── Info.plist                # App 權限與版本設定
│   └── NtutSixmwt.entitlements   # App 權限設定
├── NtutSixmwt.xcodeproj/         # Xcode 專案與工作區
├── NtutSixmwtTests/              # Unit Test 目標
└── NtutSixmwtUITests/            # UI Test 目標
```

主要頁面：

- `layout/AuthorizationView.swift`：授權與進入測試
- `layout/TutorialView.swift`：操作教學
- `layout/PersonalDataView.swift`：Fitbit 個人資料
- `layout/TestingView.swift`：6 分鐘步行與休息倒數
- `layout/HistoryDataView.swift`：歷史測試紀錄與上傳
- `layout/TestDataDetailView.swift`：單筆測試資料細節

## 環境需求

- macOS 並安裝 Xcode（建議使用支援 iOS 14.4 SDK 的版本）
- iOS 模擬器或實體 iPhone/iPad
- 可用於 Fitbit 開發者平台的 Fitbit 帳號
- 已註冊的 Fitbit 應用程式及 OAuth 2.0 設定
- 實體裝置進行完整測試時，需要支援定位、通知與藍牙的 iOS 裝置

> Fitbit OAuth 與資料下載需要網路連線。由於應用程式會使用心率、步數、定位與通知功能，建議在實體裝置上進行驗證。

## Fitbit 環境設定

設定檔位於：

```text
NtutSixmwt/CoreData/OAuthInfo.json
```

格式如下：

```json
{
  "clientID": "YOUR_FITBIT_CLIENT_ID",
  "clientSecret": "YOUR_FITBIT_CLIENT_SECRET",
  "redirectURL": "myfitbit://appauth",
  "scope": "activity heartrate location profile sleep weight",
  "expires_in": "60"
}
```

設定時請確認：

1. 在 Fitbit Developer 網站建立應用程式並取得 Client ID 與 Client Secret。
2. 將 Callback URL 設為 `myfitbit://appauth`。
3. 將實際憑證填入 `OAuthInfo.json`。
4. 在 Fitbit 應用程式註冊頁面核對授權範圍至少包含專案使用的 `activity`、`heartrate`、`location`、`profile`、`sleep` 與 `weight`。
5. 不要將實際 Client Secret 提交至公開版本控制；若憑證曾經公開或共用，請立即於 Fitbit Developer 平台重新產生。

## 啟動步驟

### 1. 取得原始碼

```bash
git clone <repository-url>
cd IOSsixmwt-main
```

若專案已經位於本機，直接進入專案根目錄即可。

### 2. 開啟專案

使用 Finder 或終端機開啟：

```bash
open NtutSixmwt.xcodeproj
```

在 Xcode 左側選擇 `NtutSixmwt` scheme。

### 3. 設定 Team 與 Bundle Identifier

1. 選取專案中的 `NtutSixmwt` target。
2. 在 Signing & Capabilities 選擇可用的 Apple Developer Team。
3. 若 Bundle Identifier 已被占用，修改為自有的值，例如 `com.yourname.NtutSixmwt`。
4. 確認專案部署目標為 iOS 14.0 或更高版本。

### 4. 設定 Fitbit 應用程式憑證

依上方「Fitbit 環境設定」更新 `OAuthInfo.json`。修改後確認檔案仍包含於 Xcode target 的 Resources。

### 5. 執行應用程式

1. 選擇 iOS 模擬器或實體裝置。
2. 按 Xcode 的 `Run` 或使用 `⌘R`。
3. 首次啟動時依提示允許定位與通知權限。
4. 在首頁按「授權」完成 Fitbit OAuth 登入。

首次授權成功後，App 會將 Access Token、Refresh Token 等資訊保存於 iOS Keychain。

## 使用流程

1. 回到首頁並完成 Fitbit 授權。
2. 在「使用者資料」頁面下載或修改個人資料。
3. 在「使用教學」頁面確認測試準備事項。
4. 在「開始測試」頁面開始 6 分鐘走路測試。
5. 測試結束後先在 Fitbit App 更新手錶資料，再回到 App 下載活動資料。
6. 在「測試資料」頁面檢視測試紀錄。
7. 透過「多選」勾選資料並上傳至雲端分析服務。

測試資料會保存於 App 沙盒中的 `Documents/db.sqlite`；OAuth 權杖、使用者資料與測試進度則保存於 iOS Keychain。

## 測試與驗證

在 Xcode 中可執行：

- Unit Tests：`NtutSixmwtTests`
- UI Tests：`NtutSixmwtUITests`
- 測試全部目標：`⌘U`

也可透過終端機執行模擬器測試：

```bash
xcodebuild \
  -project NtutSixmwt.xcodeproj \
  -scheme NtutSixmwt \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  test
```

模擬器名稱需與本機已安裝的 iOS 執行環境相符。

## 權限與隱私

專案可能會要求以下權限：

- 定位：取得測試相關位置與溫度資訊
- 通知：測試開始、休息與結束階段提醒
- 藍牙與 Fitbit 資料：由裝置上的 Fitbit 生態系統提供同步資料

實際位置與身份資料的收集、保存、上傳規範應依專案實際用途與適用法規檢視；正式發布前請確認隱私權政策、資料最小化、使用者同意及 Fitbit API 條款。
