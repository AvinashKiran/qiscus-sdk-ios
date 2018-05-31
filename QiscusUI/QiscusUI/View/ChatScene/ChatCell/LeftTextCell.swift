//
//  LeftTextCell.swift
//  Qiscus
//
//  Created by Rahardyan Bisma on 08/05/18.
//

import UIKit

class LeftTextCell: BaseChatCell {
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var tvContent: UILabel!
    @IBOutlet weak var ivBaloonLeft: UIImageView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var ivStatus: UIImageView!
    @IBOutlet weak var lbNameHeight: NSLayoutConstraint!
    @IBOutlet weak var lbNameLeading: NSLayoutConstraint!
    @IBOutlet weak var lbNameTrailing: NSLayoutConstraint!
    @IBOutlet weak var statusWidth: NSLayoutConstraint!
    var leftConstrain: NSLayoutConstraint!
    var rightConstrain: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
        self.leftConstrain = NSLayoutConstraint(item: tvContent, attribute: .leading, relatedBy: .equal, toItem: lbName, attribute: .leading, multiplier: 1, constant: 7)
        self.rightConstrain = NSLayoutConstraint(item: lbName, attribute: .trailing, relatedBy: .equal, toItem: tvContent, attribute: .trailing, multiplier: 1, constant: 10)
    }
    
    override func menuResponderView() -> UIView {
        return self.ivBaloonLeft
    }
    
    override func bindDataToView() {
        super.bindDataToView()
        self.tvContent.text = self.comment.text
        self.lbName.text = self.comment.senderName
        self.lbTime.text = self.comment.time

        if self.comment.isMyComment {
            viewContainer.addConstraint(rightConstrain)
            viewContainer.removeConstraint(leftConstrain)
            lbNameTrailing.constant = 5
            lbNameLeading.constant = 20
            lbName.textAlignment = .right
            self.statusWidth.constant = 15
            
            switch self.comment.commentStatus {
            case .pending:
                let pendingIcon = QiscusUI.image(named: "ic_pending")?.withRenderingMode(.alwaysTemplate)
                self.ivStatus.tintColor = UIColor.lightGray
                self.ivStatus.image = pendingIcon
                break
            case .sending:
                let pendingIcon = QiscusUI.image(named: "ic_sending")?.withRenderingMode(.alwaysTemplate)
                self.ivStatus.tintColor = UIColor.lightGray
                self.ivStatus.image = pendingIcon
                break
            case .sent:
                let pendingIcon = QiscusUI.image(named: "ic_sending")?.withRenderingMode(.alwaysTemplate)
                self.ivStatus.tintColor = UIColor.lightGray
                self.ivStatus.image = pendingIcon
                break
            case .delivered:
                let pendingIcon = QiscusUI.image(named: "ic_read")?.withRenderingMode(.alwaysTemplate)
                self.ivStatus.tintColor = UIColor.lightGray
                self.ivStatus.image = pendingIcon
                break
            case .read:
                let pendingIcon = QiscusUI.image(named: "ic_read")?.withRenderingMode(.alwaysTemplate)
                self.ivStatus.tintColor = UIColor.green
                self.ivStatus.image = pendingIcon
                break
            case .deleting:
                let pendingIcon = QiscusUI.image(named: "ic_deleting")?.withRenderingMode(.alwaysTemplate)
                self.ivStatus.tintColor = UIColor.lightGray
                self.ivStatus.image = pendingIcon
                break
            case .deleted:
                let pendingIcon = QiscusUI.image(named: "ic_deleted")?.withRenderingMode(.alwaysTemplate)
                self.ivStatus.tintColor = UIColor.lightGray
                self.ivStatus.image = pendingIcon
                break
            case .deletePending:
                let pendingIcon = QiscusUI.image(named: "ic_deleting")?.withRenderingMode(.alwaysTemplate)
                self.ivStatus.tintColor = UIColor.lightGray
                self.ivStatus.image = pendingIcon
                break
            case .failed:
                let pendingIcon = QiscusUI.image(named: "ic_pending")?.withRenderingMode(.alwaysTemplate)
                self.ivStatus.tintColor = UIColor.lightGray
                self.ivStatus.image = pendingIcon
                break
            default:
                break
            }
        } else {
            viewContainer.addConstraint(leftConstrain)
            viewContainer.removeConstraint(rightConstrain)
            lbNameTrailing.constant = 20
            lbNameLeading.constant = 45
            lbName.textAlignment = .left
            self.statusWidth.constant = 0
        }

//        if firstInSection {
//            self.lbName.isHidden = false
//            self.lbNameHeight.constant = CGFloat(21)
//        } else {
//            self.lbName.isHidden = true
//            self.lbNameHeight.constant = CGFloat(0)
//        }
    }
}
