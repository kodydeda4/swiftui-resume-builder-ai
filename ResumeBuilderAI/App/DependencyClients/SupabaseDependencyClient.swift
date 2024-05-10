import ComposableArchitecture
import Supabase
import SwiftUI
import Tagged

@DependencyClient
struct ApiClient: DependencyKey {
  var signIn: @Sendable (SignInWithAppleToken) async throws -> User
  var signOut: @Sendable () async throws -> Void
  var currentUser: @Sendable () async -> AsyncStream<Supabase.User?> = { .finished }
  var currentUserValue: @Sendable () async throws -> Supabase.User
  
  struct Failure: Equatable, Error {}
}

extension DependencyValues {
  var api: ApiClient {
    get { self[ApiClient.self] }
    set { self[ApiClient.self] = newValue }
  }
}

extension ApiClient {
  static var liveValue: Self {
    let supabase = SupabaseClient(
      supabaseURL: Secrets.supabaseURL,
      supabaseKey: Secrets.supabaseKey,
      options: .init(db: .init(
        encoder: .liveValue,
        decoder: .liveValue
      ))
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
        await supabase.auth.currentUser()
      },
      currentUserValue: {
        try await supabase.auth.user()
      }
    )
  }
}

private extension Supabase.AuthClient {
  @Sendable
  func currentUser() async -> AsyncStream<Supabase.User?> {
    AsyncStream { continuation in
      let task = Task {
        while !Task.isCancelled {
          await continuation.yield(try? user())
          
          for await value in authStateChanges {
            switch value.event {
              
            case .signedIn,
                .signedOut:
              await continuation.yield(try? user())
              
            default:
              break
            }
          }
        }
      }
      continuation.onTermination = { _ in task.cancel() }
    }
  }
}

private struct Secrets {
  static let openAIToken = "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"
  static let openAIOranizationID = "org-2f25G5CGOgTAI86UXv6Fz8st"
  static let supabaseURL = URL(string: "https://kurvhbcofynmofgailvb.supabase.co")!
  static let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt1cnZoYmNvZnlubW9mZ2FpbHZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTUzNjEyNTIsImV4cCI6MjAzMDkzNzI1Mn0.KFJPrWzDnQtbkKsMfkEBmT4zVO0F_u0CCe4XfD9RG60"
}


