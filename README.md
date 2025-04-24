# 환율계산기
실시간 환율 정보(USD 기준)를 Open API (https://open.er-api.com/v6/latest/USD) 로 받아오고, 금액을 변환하거나, 관심 있는 통화를 즐겨찾기에 추가할 수 있는 앱. 
<br>



## 📱 실행 화면
![Simulator Screen Recording - iPhone 16 Pro - 2025-04-24 at 09 41 48](https://github.com/user-attachments/assets/80eaba31-13ca-4ddd-97fe-c05f2593285b)
<br>


## 🛠️ 기술 스택
### 아키텍처
- MVVM

### 데이터 처리
- CoreData

### 활용 API
- SnapKit
- Alamofire

### UI Frameworks
- UIKit
- AutoLayout     
<br>

## 🔫 Trouble Shooting
- 파일명 및 변수명 변경 시 오류, Level 2 오토 레이아웃 오류 <br>
https://feather-cotija-f8b.notion.site/TIL-04-15-1d66a15498a0809eb3e7de7b623661e9?pvs=4
- 필터링 오류 및 기타 오류 <br> https://feather-cotija-f8b.notion.site/TIL-04-16-1d76a15498a080b8a3e0e1cb3545a345?pvs=4
- 키보드 해제 오류, 실시간 금액 반영 오류 <br> https://feather-cotija-f8b.notion.site/TIL-04-17-1d86a15498a080388e4cf2fe9440813c?pvs=4
- 테이블 뷰 셀 항목 바인딩 오류 <br> https://feather-cotija-f8b.notion.site/TIL-04-21-1dc6a15498a080d99cf0ff3322c474a5?pvs=4
- 검색 창, 검색 후 즐겨찾기 변경 시 오류 <br> https://feather-cotija-f8b.notion.site/TIL-04-22-1dd6a15498a08041a3b1dd0d3b3496bb?pvs=4

<br>

## 🔍 메모리 누수 확인
<img width="1552" alt="스크린샷 2025-04-24 09 29 39" src="https://github.com/user-attachments/assets/726d8120-59c1-4571-a442-9c3bef86b396" />

<br>

## 🗂️ 파일 구조

```
|-- ExchangeRateCalculator
|   |-- App
|   |   |-- AppColor.swift
|   |   |-- AppDelegate.swift
|   |   `-- SceneDelegate.swift
|   |-- Base.lproj
|   |-- CoreData
|   |   |-- CachedRateDataManager.swift
|   |   |-- ExchangeRateCalculator.xcdatamodeld
|   |   |   `-- ExchangeRateCalculator.xcdatamodel
|   |   |       `-- contents
|   |   |-- FavoritesDataManager.swift
|   |   |-- LastScreenDataManager.swift
|   |   |-- OldCachedRateDataManager.swift
|   |   `-- SubClasses
|   |       |-- CachedRate+CoreDataClass.swift
|   |       |-- CachedRate+CoreDataProperties.swift
|   |       |-- Favorites+CoreDataClass.swift
|   |       |-- Favorites+CoreDataProperties.swift
|   |       |-- LastScreen+CoreDataClass.swift
|   |       |-- LastScreen+CoreDataProperties.swift
|   |       |-- OldCachedRate+CoreDataClass.swift
|   |       `-- OldCachedRate+CoreDataProperties.swift
|   |-- Info.plist
|   |-- Model
|   |   |-- ExchangeRateResponse.swift
|   |   |-- MockData.swift
|   |   `-- RateItem.swift
|   |-- Network
|   |   `-- NetworkManager.swift
|   |-- Resource
|   |   |-- Assets.xcassets
|   |   |   |-- AccentColor.colorset
|   |   |   |   `-- Contents.json
|   |   |   |-- AppIcon.appiconset
|   |   |   |   `-- Contents.json
|   |   |   |-- BackgroundColor.colorset
|   |   |   |   `-- Contents.json
|   |   |   |-- ButtonColor.colorset
|   |   |   |   `-- Contents.json
|   |   |   |-- CellBackGroundColor.colorset
|   |   |   |   `-- Contents.json
|   |   |   |-- Contents.json
|   |   |   |-- SecondaryTextColor.colorset
|   |   |   |   `-- Contents.json
|   |   |   `-- TextColor.colorset
|   |   |       `-- Contents.json
|   |   `-- Base.lproj
|   |       `-- LaunchScreen.storyboard
|   |-- ViewModels
|   |   |-- CalculatorViewModel.swift
|   |   |-- ExchangeRateCellViewModel.swift
|   |   |-- ExchangeRateViewModel.swift
|   |   `-- ViewModelProtocol.swift
|   `-- Views
|       |-- CalculatorViewController.swift
|       |-- ExchangeRateCell.swift
|       |-- ExchangeRateViewController.swift
|       `-- Extensions.swift
`-- README.md
```
