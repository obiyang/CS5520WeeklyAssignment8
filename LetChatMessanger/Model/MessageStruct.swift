import Foundation  // 添加这行

struct MessageStruct {
    let user: String
    let messageBody: String
    let timestamp: String
    let messageId: String
    
    init(user: String, messageBody: String, timestamp: Double, messageId: String) {
        self.user = user
        self.messageBody = messageBody
        self.messageId = messageId
        
        // 格式化时间戳
        let date = Date(timeIntervalSince1970: timestamp/1000)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        self.timestamp = formatter.string(from: date)
    }
}
