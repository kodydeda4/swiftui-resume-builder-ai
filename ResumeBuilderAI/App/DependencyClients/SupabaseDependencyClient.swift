import ComposableArchitecture
import Supabase
import SwiftUI
import Tagged

/// Supabase is an open source Firebase alternative.
/// https://github.com/supabase/supabase-swift
@DependencyClient
struct SupabaseDependencyClient: DependencyKey {
  var signIn: @Sendable (SignInWithAppleToken) async throws -> User
  var signOut: @Sendable () async throws -> Void
  var currentUser: @Sendable () async -> AsyncStream<User?> = { .finished }
  
  struct Failure: Equatable, Error {}
  typealias User = Supabase.User
  
  static var liveValue: Self {
    let supabase = SupabaseClient(
      supabaseURL: Secrets.supabaseURL,
      supabaseKey: Secrets.supabaseKey
    )
    
    return Self(
      signIn: { token in
        try await supabase.auth.signInWithIdToken(credentials: OpenIDConnectCredentials.init(
          provider: OpenIDConnectCredentials.Provider.apple,
          idToken: token.appleID,
          nonce: token.nonce
        )).user
      },
      signOut: {
        try await supabase.auth.signOut()
      },
      currentUser: {
        AsyncStream { continuation in
          let task = Task {
            while !Task.isCancelled {
              await continuation.yield(try? supabase.auth.user())
              
              for await value in await supabase.auth.authStateChanges {
                switch value.event {
                  
                case .signedIn,
                    .signedOut:
                  await continuation.yield(try? supabase.auth.user())
                  
                default:
                  break
                }
              }
            }
          }
          continuation.onTermination = { _ in task.cancel() }
        }
      }
    )
  }
}

extension DependencyValues {
  var supabase: SupabaseDependencyClient {
    get { self[SupabaseDependencyClient.self] }
    set { self[SupabaseDependencyClient.self] = newValue }
  }
}
