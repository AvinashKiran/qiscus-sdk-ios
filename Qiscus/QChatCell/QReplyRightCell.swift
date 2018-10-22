//
//  QReplyRightCell.swift
//  Qiscus
//
//  Created by asharijuang on 05/09/18.
//

import UIKit
import QiscusUI
import QiscusCore
import SwiftyJSON

class QReplyRightCell: UIBaseChatCell {
    @IBOutlet weak var viewReplyPreview: UIView!
    @IBOutlet weak var ivCommentImageWidhtCons: NSLayoutConstraint!
    @IBOutlet weak var lbCommentSender: UILabel!
    @IBOutlet weak var tvCommentContent: UITextView!
    @IBOutlet weak var ivCommentImage: UIImageView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var lbContent: UILabel!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var ivBaloon: UIImageView!
    @IBOutlet weak var ivStatus: UIImageView!
    var menuConfig = enableMenuConfig()
    var delegateChat: QiscusChatVC? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setMenu(forward: menuConfig.forward, info: menuConfig.info)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        
        viewReplyPreview.addGestureRecognizer(tap)
        viewReplyPreview.isUserInteractionEnabled = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.setMenu(forward: menuConfig.forward, info: menuConfig.info)
        // Configure the view for the selected state
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if let delegate = delegateChat {
            guard let replyData = self.comment?.payload else {
                return
            }
            let json = JSON(replyData)
            var commentID = json["replied_comment_id"].int ?? 0
            if commentID != 0 {
                if let comment = QiscusCore.database.comment.find(id: "\(commentID)"){
                    delegate.scrollToComment(comment: comment)
                }
            }
        }
    }
    
    override func present(message: CommentModel) {
        // parsing payload
        self.bindData(message: message)
        
    }
    
    override func update(message: CommentModel) {
        self.bindData(message: message)
    }
    
    func bindData(message: CommentModel){
        self.setupBalon()
        self.status(message: message)
        
        guard let replyData = message.payload else {
            return
        }
        var text = replyData["replied_comment_message"] as? String
        var replyType = message.replyType(message: text!)
        
        if replyType == .text  {
            switch replyData["replied_comment_type"] as? String {
            case "location":
                replyType = .location
                break
            case "contact_person":
                replyType = .contact
                break
            default:
                break
            }
        }
        var username = replyData["replied_comment_sender_username"] as? String
        let repliedEmail = replyData["replied_comment_sender_email"] as? String
        if repliedEmail == Qiscus.client.email {
            username = "You"
        }
        
        switch replyType {
        case .text:
            self.ivCommentImageWidhtCons.constant = 0
            self.tvCommentContent.text = text
        case .image:
            var filename = message.fileName(text: text!)
            self.tvCommentContent.text = filename
            let url = URL(string: message.getAttachmentURL(message: text!))
            self.ivCommentImage.sd_setShowActivityIndicatorView(true)
            self.ivCommentImage.sd_setIndicatorStyle(.gray)
            self.ivCommentImage.sd_setImage(with: url)
            
        case .video:
            self.tvCommentContent.text = text
        case .audio:
            self.tvCommentContent.text = text
        case .document:
            //pdf
            let url = URL(string: message.getAttachmentURL(message: text!))
            self.ivCommentImage.sd_setShowActivityIndicatorView(true)
            self.ivCommentImage.sd_setIndicatorStyle(.gray)
            self.ivCommentImage.sd_setImage(with: url)
            var filename = message.fileName(text: text!)
            self.tvCommentContent.text = filename
            self.tvCommentContent.text = text
        case .location:
            self.tvCommentContent.text = text
            self.ivCommentImage.image = Qiscus.image(named: "map_ico")
        case .contact:
            self.tvCommentContent.text = text
            self.ivCommentImage.image = Qiscus.image(named: "contact")
        case .file:
            var filename = message.fileName(text: text!)
            self.tvCommentContent.text = filename
            self.ivCommentImage.image = Qiscus.image(named: "ic_file")
        case .other:
            self.tvCommentContent.text = text
            self.ivCommentImageWidhtCons.constant = 0
        }
        
        self.lbCommentSender.text = username
        self.lbContent.text = message.message
        self.lbTime.text = self.hour(date: message.date())
        if(message.isMyComment() == true){
            self.lbName.text = "You"
        }else{
            self.lbName.text = message.username
        }
        
    }
    
    func setupBalon(){
        self.ivBaloon.image = self.getBallon()
        self.ivBaloon.tintColor = QiscusColorConfiguration.sharedInstance.rightBaloonColor
    }
    
    func status(message: CommentModel){
        
        switch message.status {
        case .deleted:
            ivStatus.image = Qiscus.image(named: "ic_deleted")?.withRenderingMode(.alwaysTemplate)
            break
        case .sending, .pending:
            lbTime.textColor = QiscusColorConfiguration.sharedInstance.rightBaloonTextColor
            ivStatus.tintColor = QiscusColorConfiguration.sharedInstance.rightBaloonTextColor
            lbTime.text = QiscusTextConfiguration.sharedInstance.sendingText
            ivStatus.image = Qiscus.image(named: "ic_info_time")?.withRenderingMode(.alwaysTemplate)
            break
        case .sent:
            lbTime.textColor = QiscusColorConfiguration.sharedInstance.rightBaloonTextColor
            ivStatus.tintColor = QiscusColorConfiguration.sharedInstance.rightBaloonTextColor
            ivStatus.image = Qiscus.image(named: "ic_sending")?.withRenderingMode(.alwaysTemplate)
            break
        case .delivered:
            lbTime.textColor = QiscusColorConfiguration.sharedInstance.rightBaloonTextColor
            ivStatus.tintColor = QiscusColorConfiguration.sharedInstance.rightBaloonTextColor
            ivStatus.image = Qiscus.image(named: "ic_read")?.withRenderingMode(.alwaysTemplate)
            break
        case .read:
            lbTime.textColor = QiscusColorConfiguration.sharedInstance.rightBaloonTextColor
            ivStatus.tintColor = Qiscus.style.color.readMessageColor
            ivStatus.image = Qiscus.image(named: "ic_read")?.withRenderingMode(.alwaysTemplate)
            break
        case . failed:
            lbTime.textColor = QiscusColorConfiguration.sharedInstance.failToSendColor
            lbTime.text = QiscusTextConfiguration.sharedInstance.failedText
            ivStatus.image = Qiscus.image(named: "ic_warning")?.withRenderingMode(.alwaysTemplate)
            ivStatus.tintColor = QiscusColorConfiguration.sharedInstance.failToSendColor
            break
        }
    }
    
    func hour(date: Date?) -> String {
        guard let date = date else {
            return "-"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone      = TimeZone.current
        let defaultTimeZoneStr = formatter.string(from: date);
        return defaultTimeZoneStr
    }
    
}
