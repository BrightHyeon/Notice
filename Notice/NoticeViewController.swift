//
//  NoticeViewController.swift
//  Notice
//
//  Created by HyeonSoo Kim on 2022/01/31.
//

import UIKit

class NoticeViewController: UIViewController {
    //원격정보는 mainViewController로부터 받아올 것.
    //이 Notice를 표시할지 안할지도 원격구성을 통해 제어하기 때문.
    var noticeContents: (title: String, detail: String, date: String)?
    
    @IBOutlet weak var noticeView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        noticeView.layer.cornerRadius = 6
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        guard let noticeContents = noticeContents else { return }
        titleLabel.text = noticeContents.title
        detailLabel.text = noticeContents.detail
        dateLabel.text = noticeContents.date
    }
    
    @IBAction func tapDoneButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}
