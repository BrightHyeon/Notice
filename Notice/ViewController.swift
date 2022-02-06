//
//  ViewController.swift
//  Notice
//
//  Created by HyeonSoo Kim on 2022/01/31.
//

import UIKit
import FirebaseRemoteConfig
import FirebaseAnalytics //이벤트를 위함.

class ViewController: UIViewController {
    
    //RemoteConfig객체 선언
    var remoteConfig: RemoteConfig?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //RemoteConfig객체 정의
        remoteConfig = RemoteConfig.remoteConfig()
        
        //RemoteConfig세팅
        let setting = RemoteConfigSettings()
        setting.minimumFetchInterval = 0 //test를 위해서 새로운 값을 fetch(;가져옴)하는 interval(;간격)을 최소화해서 최대한 자주 원격구성에 있는 data들을 가져올 수 있도록 함.
        
        //설정한 값 할당.
        remoteConfig?.configSettings = setting
        //기본값 설정용 plist가져오기(plist에는 기본값이 있음.)
        remoteConfig?.setDefaults(fromPlist: "RemoteConfigDefaults")
//        print("뷰 로드로드")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getNotice() //Remote를 통해 재정의된 값을 가져올 수 있음.
//        print("나타날것나타날것")
    }
}

/*
 class안에 생성한 remoteConfig객체의 각 키에 대한 기본값을 설정해야함.
 기본값 설정을 위해 new file로 Property List(plist)를 추가.
 
 why? => 원격구성(RemoteConfig)은 key-value형태의 Storage, 즉 딕셔너리 형태의 클라우드 기반 저장소를 다루고, 기본값 설정 후 값을 재정의 하는 방식으로 배포, 업데이트 없이 앱을 변경하는 형태이기 때문.
 */

//RemoteConfig
extension ViewController {
    func getNotice() {
        guard let remoteConfig = remoteConfig else { return }
        
        remoteConfig.fetch {[weak self] status, _ in
            //원격구성 정보를 잘 가져왔다면,
            if status == .success {
                remoteConfig.activate(completion: nil) //성공상태일 시 활성화.
            } else {
                print("ERROR: Config not fetched")
            }
            
            guard let self = self else { return }
            
            if !self.isNoticeHidden(remoteConfig) { //isHidden이 참이면 실행x, 거짓이면 조건문 참이되면서 실행o.
                let noticeVC = NoticeViewController(nibName: "NoticeViewController", bundle: nil) //xib파일 인식.
                
                noticeVC.modalPresentationStyle = .custom
                noticeVC.modalTransitionStyle = .crossDissolve
                
                let title = (remoteConfig["title"].stringValue ?? "").replacingOccurrences(of: "\\n", with: "\n") //Firebase 콘솔상에서 입력한 \n이 \\n으로 전송되기에 다시 \n으로 대체해줘야함.
                let detail = (remoteConfig["detail"].stringValue ?? "").replacingOccurrences(of: "\\n", with: "\n")
                let date = (remoteConfig["date"].stringValue ?? "").replacingOccurrences(of: "\\n", with: "\n")
                
                noticeVC.noticeContents = (title: title, detail: detail, date: date)
                self.present(noticeVC, animated: true, completion: nil)
            } else {
                self.showEventAlert()
            }
        }
    }
    
    func isNoticeHidden(_ remoteConfig: RemoteConfig) -> Bool {
        return remoteConfig["isHidden"].boolValue //타입 명시
    }
}

//요약: plist로 기본값 설정한 것이고, Firebase 프로젝트 콘솔에서 RemoteConfig를 이용하여 값을 재정의함으로써 배포, 업데이트 없이 앱 변경이 가능해진다.

//A/B Testing
extension ViewController {
    func showEventAlert() {
        guard let remoteConfig = remoteConfig else { return }
        
        remoteConfig.fetch {[weak self] status, _ in
            if status == .success {
                remoteConfig.activate(completion: nil)
            } else {
                print("Config not fetched")
            }
            
            let message = remoteConfig["message"].stringValue ?? ""
            
            let confirmAction = UIAlertAction(title: "확인하기", style: .default) { _ in
                //Google Analytics. 버튼이 눌릴때마다 이벤트를 기록하게됨. 분석을 위함.
                Analytics.logEvent("promotion_alert", parameters: nil)
            }
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            let alertController = UIAlertController(title: "깜짝이벤트", message: message, preferredStyle: .alert)
            
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            
            self?.present(alertController, animated: true, completion: nil)
        }
    }
}
