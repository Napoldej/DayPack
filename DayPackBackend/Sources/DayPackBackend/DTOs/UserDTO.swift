import Fluent
import Vapor

struct UserDTO: Content {
    var id: UUID?
    var name: String?
    var email: String?
    
    func toModel() -> Todo {
        let model = User()
        
        model.id = self.id
        if let title = self.title {
            model.title = title
        }
        return model
    }
}
