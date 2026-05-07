// DTOs/UserDTO.swift
import Vapor

// Received from client on register
struct UserCreateDTO: Content {
    let name: String
    let email: String
    let password: String
}

// Received from client on update
struct UserUpdateDTO: Content {
    let name: String?
    let email: String?
    let password: String?
}

// Sent back to client — never exposes password
struct UserResponseDTO: Content {
    let id: UUID
    let name: String
    let email: String
}

extension User {
    func toDTO() -> UserResponseDTO {
        UserResponseDTO(
            id: self.id!,
            name: self.name,
            email: self.email
        )
    }
}
