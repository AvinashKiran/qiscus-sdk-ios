//
//  QParticipant.swift
//  Example
//
//  Created by Ahmad Athaullah on 7/5/17.
//  Copyright © 2017 Ahmad Athaullah. All rights reserved.
//

import Foundation
import RealmSwift

public class QParticipant:Object {
    public dynamic var localId:String = ""
    public dynamic var roomId:Int = 0
    public dynamic var email:String = ""
    public dynamic var lastReadCommentId:Int = 0
    public dynamic var lastDeliveredCommentId:Int = 0
    
    // MARK: - Primary Key
    override public class func primaryKey() -> String {
        return "localId"
    }
    // MARK: - Getter variable
    public var user:QUser? {
        get{
            let realm = try! Realm(configuration: Qiscus.dbConfiguration)
            return realm.object(ofType: QUser.self, forPrimaryKey: self.email)
        }
    }
    public class func participant(inRoomWithId roomId:Int, andEmail email: String)->QParticipant?{
        let realm = try! Realm(configuration: Qiscus.dbConfiguration)
        return realm.object(ofType: QParticipant.self, forPrimaryKey: "\(roomId)_\(email)")
    }
    public func updateLastDeliveredId(commentId:Int){
        if commentId > self.lastDeliveredCommentId {
            let realm = try! Realm(configuration: Qiscus.dbConfiguration)
            try! realm.write {
                self.lastDeliveredCommentId = commentId
            }
        }
    }
    public func updateLastReadId(commentId:Int){
        let realm = try! Realm(configuration: Qiscus.dbConfiguration)
        if commentId > self.lastReadCommentId {
            try! realm.write {
                self.lastDeliveredCommentId = commentId
            }
        }
        self.updateLastDeliveredId(commentId: commentId)
    }
    public class func all(withEmail email:String)->[QParticipant]{
        var participants = [QParticipant]()
        let realm = try! Realm(configuration: Qiscus.dbConfiguration)
        let data =  realm.objects(QParticipant.self).filter("email == '\(email)'")
        for participant in data {
            participants.append(participant)
        }
        return participants
    }
}
