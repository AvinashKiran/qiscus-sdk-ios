//
//  QUIBaseChatCell.swift
//  Pods
//
//  Created by asharijuang on 24/09/18.
//

import Foundation
import QiscusCore
import QiscusUI

open class enableMenuConfig : NSObject {
    internal var forward    : Bool = false
    internal var info       : Bool = false
    
    public init(forward: Bool = false, info : Bool = true) {
        self.forward        = forward
        self.info           = info
    }
}
extension UIBaseChatCell {
    
    open func setMenu(forward : Bool = false , info : Bool = false) {
        
        let reply = UIMenuItem(title: "Reply", action: #selector(reply(_:)))
        let forwardMessage = UIMenuItem(title: "Forward", action: #selector(forward(_:)))
        let share = UIMenuItem(title: "Share", action: #selector(share(_:)))
        let infoMessage = UIMenuItem(title: "Info", action: #selector(info(_:)))
        let delete = UIMenuItem(title: "Delete", action: #selector(deleteComment(_:)))
        let deleteForMe = UIMenuItem(title: "Delete For Me", action: #selector(deleteCommentForMe(_:)))
        
        var menuItems: [UIMenuItem] = [UIMenuItem]()
        menuItems.append(reply)
        menuItems.append(share)
        if(forward == true){
            menuItems.append(forwardMessage)
        }
        menuItems.append(deleteForMe)
        
        if let myComment = self.comment?.isMyComment() {
            if(myComment){
                //UIMenuController.shared.menuItems = [reply,infoMessage,share,forwardMessage,delete,deleteForMe]
                if(info == true){
                    menuItems.append(infoMessage)
                }
                menuItems.append(delete)
                UIMenuController.shared.menuItems = menuItems
            }else{
                //UIMenuController.shared.menuItems = [reply,share,forwardMessage,deleteForMe]
                UIMenuController.shared.menuItems = menuItems
            }
            
            UIMenuController.shared.update()
        }
        
        
        
    }
    
    @objc open func reply(_ send:AnyObject){
        QiscusNotification.publishDidClickReply(message: self.comment!)
    }
    
    @objc open func forward(_ send:AnyObject){
        QiscusNotification.publishDidClickForward(message: self.comment!)
    }
    
    @objc open func share(_ send:AnyObject){
        QiscusNotification.publishDidClickShare(message: self.comment!)
    }
    
    @objc open func deleteComment(_ send:AnyObject){
        var uniqueIDs = [String]()
        let uniqueID = self.comment!.uniqId
        uniqueIDs.append(uniqueID)
        QiscusCore.shared.deleteMessage(uniqueIDs: uniqueIDs, type: .forEveryone, onSuccess: { (commentsModel) in
            Qiscus.printLog(text: "success delete comment for everyone")
        }) { (error) in
            Qiscus.printLog(text: "failed delete comment for everyone")
        }
    
    }
    
    @objc open func deleteCommentForMe(_ send:AnyObject){
        var uniqueIDs = [String]()
        let uniqueID = self.comment!.uniqId
        uniqueIDs.append(uniqueID)
        
        QiscusCore.shared.deleteMessage(uniqueIDs: uniqueIDs, type: DeleteType.forMe, onSuccess: { (commentsModel) in
             Qiscus.printLog(text: "success delete comment for me")
        }) { (error) in
             Qiscus.printLog(text: "failed delete comment for me \(error.message)")
        }
    }
    
    @objc open func info(_ send:AnyObject){
        QiscusNotification.publishDidClickInfo(message: self.comment!)
    }
}

extension Array {
    func randomItem() -> Element? {
        if isEmpty { return nil }
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}


