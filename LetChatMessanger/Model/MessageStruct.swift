import Foundation

struct MessageStruct {
    let user: String
    let messageBody: String
    let timestamp: Double
    let messageId: String
    
    init(user: String, messageBody: String, timestamp: Double, messageId: String) {
        self.user = user
        self.messageBody = messageBody
        self.messageId = messageId
        self.timestamp = timestamp
    }
}
