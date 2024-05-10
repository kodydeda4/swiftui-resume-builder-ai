import ComposableArchitecture
import Supabase
import Foundation

extension PersistenceKey where Self == InMemoryKey<Supabase.User> {
  static var user: Self { .init("user") }
}

extension Supabase.User {
  static let mock = Self(
    id: UUID(),
    appMetadata: [:],
    userMetadata: [:],
    aud: "",
    createdAt: Date(),
    updatedAt: Date()
  )
}
