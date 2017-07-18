//
//  QCellTextLeft.swift
//  QiscusSDK
//
//  Created by Ahmad Athaullah on 1/3/17.
//  Copyright © 2017 Ahmad Athaullah. All rights reserved.
//

import UIKit
import SwiftyJSON

class QCellTextLeft: QChatCell, UITextViewDelegate {
    let maxWidth:CGFloat = QiscusUIConfiguration.chatTextMaxWidth
    let minWidth:CGFloat = 80
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var balloonView: UIImageView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var balloonTopMargin: NSLayoutConstraint!
    @IBOutlet weak var leftMargin: NSLayoutConstraint!
    @IBOutlet weak var cellHeight: NSLayoutConstraint!
    @IBOutlet weak var textLeading: NSLayoutConstraint!
    @IBOutlet weak var textViewWidth: NSLayoutConstraint!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var balloonWidth: NSLayoutConstraint!
    @IBOutlet weak var linkContainerWidth: NSLayoutConstraint!
    
    @IBOutlet weak var LinkContainer: UIView!
    @IBOutlet weak var linkDescription: UITextView!
    @IBOutlet weak var linkTitle: UILabel!
    @IBOutlet weak var linkImage: UIImageView!
    @IBOutlet weak var linkImageWidth: NSLayoutConstraint!
    
    @IBOutlet weak var linkHeight: NSLayoutConstraint!
    @IBOutlet weak var textTopMargin: NSLayoutConstraint!
    @IBOutlet weak var ballonHeight: NSLayoutConstraint!
    @IBOutlet weak var cellWidth: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.contentInset = UIEdgeInsets.zero
        textView.delegate = self
        
        LinkContainer.isHidden = true
        LinkContainer.layer.cornerRadius = 4
        LinkContainer.clipsToBounds = true
        linkContainerWidth.constant = self.maxWidth + 2
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(QCellTextLeft.openLink))
        LinkContainer.addGestureRecognizer(tapRecognizer)
        linkImage.clipsToBounds = true
    }
    
    open override func setupCell(){
        
    }
    override func clearContext() {
        textView.layoutIfNeeded()
        LinkContainer.isHidden = true
    }
    func openLink(){
        if data.showLink{
            if data.linkURL != ""{
                let url = data.linkURL
                var urlToCheck = url.lowercased()
                if !urlToCheck.contains("http"){
                    urlToCheck = "http://\(url.lowercased())"
                }
                if let urlToOpen = URL(string: urlToCheck){
                    UIApplication.shared.openURL(urlToOpen)
                }
            }
        }
        else if data.commentType == .reply {
            DispatchQueue.global().async {
                let replyData = JSON(parseJSON: self.data.comment!.commentButton)
                let commentId = replyData["replied_comment_id"].intValue
                var found = false
                if let comment = self.data.comment {
                    if let chatView = Qiscus.shared.chatViews[comment.roomId]{
                        
                        var indexPath = IndexPath(item: 0, section: 0)
                        var section = 0
                        for commentGroup in chatView.comments{
                            var row = 0
                            for comment in commentGroup {
                                if comment.commentId == commentId {
                                    found = true
                                    indexPath = IndexPath(item: row, section: section)
                                    break
                                }
                                row += 1
                            }
                            if found {
                                break
                            }else{
                                section += 1
                            }
                        }
                        if found {
                            DispatchQueue.main.async {
                                chatView.scrollToIndexPath(indexPath, position: .top, animated: true, delayed: false)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return true
    }

    public override func commentChanged() {
        self.textView.attributedText = self.comment?.attributedText
        self.textView.linkTextAttributes = self.linkTextAttributes
        self.balloonView.image = self.getBallon()
        
        let textSize = self.comment!.textSize
        var textWidth = self.comment!.textSize.width
        
        if textWidth > self.minWidth {
            textWidth = textSize.width
        }else{
            textWidth = self.minWidth
        }
        
//        if self.data.showLink {
//            self.linkTitle.text = self.data.linkTitle
//            self.linkDescription.text = self.data.linkDescription
//            self.linkImage.image = self.data.linkImage
//            self.LinkContainer.isHidden = false
//            self.ballonHeight.constant = 83
//            self.textTopMargin.constant = 73
//            self.linkHeight.constant = 65
//            textWidth = self.maxWidth
//            
//            if !self.data.linkSaved{
//                QiscusDataPresenter.getLinkData(withData: self.data)
//            }
//        }else
        if self.comment!.type == .reply{
            let replyData = JSON(parseJSON: self.comment!.data)
            var text = replyData["replied_comment_message"].stringValue
            let replyType = self.comment!.replyType(message: text)
            
            var username = replyData["replied_comment_sender_username"].stringValue
            let repliedEmail = replyData["replied_comment_sender_email"].stringValue
            if repliedEmail == QiscusMe.sharedInstance.email {
                username = "You"
            }
            switch replyType {
            case .text:
                self.linkImageWidth.constant = 0
                self.linkImage.isHidden = true
                break
            case .image, .video:
                self.linkImage.image = Qiscus.image(named: "link")
                let filename = self.comment!.fileName(text: text)
                let url = self.comment!.getAttachmentURL(message: text)
                
                self.linkImageWidth.constant = 55
                self.linkImage.isHidden = false
                
                if let file = QFile.file(withURL: url){
                    if QiscusHelper.isFileExist(inLocalPath: file.localThumbPath){
                        self.linkImage.loadAsync(fromLocalPath: file.localThumbPath, onLoaded: { (image, _) in
                            self.linkImage.image = image
                        })
                    }else if QiscusHelper.isFileExist(inLocalPath: file.localMiniThumbPath){
                        self.linkImage.loadAsync(fromLocalPath: data.localMiniThumbURL!, onLoaded: { (image, _) in
                            self.linkImage.image = image
                        })
                    }else{
                        self.linkImage.loadAsync(file.thumbURL, onLoaded: { (image, _) in
                            self.linkImage.image = image
                        })
                    }
                }else{
                    var thumbURL = url.replacingOccurrences(of: "/upload/", with: "/upload/w_30,c_scale/")
                    let thumbUrlArr = thumbURL.characters.split(separator: ".")
                    
                    var newThumbURL = ""
                    var i = 0
                    for thumbComponent in thumbUrlArr{
                        if i == 0{
                            newThumbURL += String(thumbComponent)
                        }else if i < (thumbUrlArr.count - 1){
                            newThumbURL += ".\(String(thumbComponent))"
                        }else{
                            newThumbURL += ".png"
                        }
                        i += 1
                    }
                    thumbURL = newThumbURL
                    self.linkImage.loadAsync(thumbURL, onLoaded: { (image, _) in
                        self.linkImage.image = image
                    })
                }
                text = filename
                
                break
            default:
                let filename = self.comment!.fileName(text: text)
                text = filename
                self.linkImageWidth.constant = 0
                self.linkImage.isHidden = true
                break
            }
            
            
            self.linkTitle.text = username
            self.linkDescription.text = text
            
            self.LinkContainer.isHidden = false
            self.ballonHeight.constant = 83
            self.textTopMargin.constant = 73
            self.linkHeight.constant = 65
            textWidth = self.maxWidth
        }else{
            self.linkTitle.text = ""
            self.linkDescription.text = ""
            self.linkImage.image = Qiscus.image(named: "link")
            self.LinkContainer.isHidden = true
            self.ballonHeight.constant = 10
            self.textTopMargin.constant = 0
        }
        
        
        var size = self.textView.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
        if self.comment?.type == .postback && self.comment?.data != ""{
            let payload = JSON(parseJSON: self.comment!.data)
            
            if let buttonsPayload = payload.array {
                let heightAdd = CGFloat(35 * buttonsPayload.count)
                size.height += heightAdd
            }else{
                size.height += 35
            }
        }
        self.textViewWidth.constant = textWidth
        self.textViewHeight.constant = size.height
        
        self.userNameLabel.textAlignment = .left
        
        self.dateLabel.text = self.comment!.time.lowercased()
        self.balloonView.tintColor = QiscusColorConfiguration.sharedInstance.leftBaloonColor
        self.dateLabel.textColor = QiscusColorConfiguration.sharedInstance.leftBaloonTextColor
        
        
        if self.comment?.cellPos == .first || self.comment?.cellPos == .single{
            if let sender = self.comment?.sender {
                self.userNameLabel.text = sender.fullname
            }else{
                self.userNameLabel.text = self.comment?.senderName
            }
            self.userNameLabel.isHidden = false
            self.balloonTopMargin.constant = 20
            self.cellHeight.constant = 20
        }else{
            self.userNameLabel.text = ""
            self.userNameLabel.isHidden = true
            self.balloonTopMargin.constant = 0
            self.cellHeight.constant = 0
        }
        
        // last cell
//        if self.comment?.cellPos == .single{
//            self.leftMargin.constant = 35
//            self.textLeading.constant = 23
//            self.balloonWidth.constant = 31
//        }
//        else if self.comment?.cellPos == .last {
//            self.leftMargin.constant = 35
//            self.textLeading.constant = 23
//            self.balloonWidth.constant = 31
//        }else{
//            self.textLeading.constant = 8
//            self.leftMargin.constant = 50
//            self.balloonWidth.constant = 16
//        }
        self.textView.layoutIfNeeded()
    }
    
}
