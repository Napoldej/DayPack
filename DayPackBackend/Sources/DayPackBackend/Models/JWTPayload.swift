// Models/JWTPayload.swift
import JWT
import Vapor

struct AppJWTPayload: JWTPayload, Authenticatable {
    var subject: SubjectClaim
    var expiration: ExpirationClaim
    var userID: UUID

    func verify(using signer: JWTSigner) throws {
        try expiration.verifyNotExpired()
    }
}
