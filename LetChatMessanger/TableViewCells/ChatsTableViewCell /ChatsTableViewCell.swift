
import UIKit
import ChameleonFramework
import FirebaseAuth

class ChatsTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var messageText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.image = UIImage(systemName: "person.fill")
        messageText.layer.cornerRadius = 5
        messageText.layer.cornerCurve = .continuous
        messageText.layer.masksToBounds = true
    }
    
    func configureCellValue(entry: MessagesStructt) {
        messageText.text = entry.messageBody
        if entry.user == Auth.auth().currentUser?.email as? String {
            messageText.backgroundColor = UIColor.flatMint()
            messageText.textAlignment = .right
        }else {
            messageText.textAlignment = .left
            messageText.backgroundColor = UIColor.flatRed()
        }
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
