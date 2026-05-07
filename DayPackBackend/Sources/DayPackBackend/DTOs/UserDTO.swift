import Fluent
import Vapor

struct UserDTO: Content {
    var id: UUID?
    var name: String?
    var email: String?
    
    func toModel() -> User {
        let model = User()
        
        model.id = self.id
        if let name = self.name {
            model.name = name
        }
        if let email = self.email {
            model.email = email
        }
        return model
    }
}

extension User {
    func toDTO() -> UserDTO {
        UserDTO(
            id: self.id,
            name: self.name,
            email: self.email
        )
    }
}
