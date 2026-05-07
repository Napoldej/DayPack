
import Vapor

struct RegisterDTO: Content {
    let name: String
    let email: String
    let password: String
}

struct LoginDTO: Content {
    let email: String
    let password: String
}

struct AuthResponseDTO: Content {
    let token: String
    let user: UserResponseDTO
}
