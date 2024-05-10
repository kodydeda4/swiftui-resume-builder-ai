import ComposableArchitecture
import Foundation

extension PersistenceKey where Self == InMemoryKey<SupabaseDependencyClient.User> {
  static var user: Self { .init("user") }
}

extension SupabaseDependencyClient.User {
  static let mock = Self(
    id: UUID(),
    appMetadata: [:],
    userMetadata: [:],
    aud: "",
    createdAt: Date(),
    updatedAt: Date()
  )
}
