import ComposableArchitecture
import OpenAI

// OpenAI Documentation
// https://platform.openai.com/docs/overview
// https://github.com/MacPaw/OpenAI

@DependencyClient
struct OpenAIClient: DependencyKey {
  var fetchBeginnerWords: @Sendable () async throws -> String
}

extension DependencyValues {
  var openAI: OpenAIClient {
    get { self[OpenAIClient.self] }
    set { self[OpenAIClient.self] = newValue }
  }
}

extension OpenAIClient {
  static var liveValue: Self {
    let openAI = OpenAI(configuration: OpenAI.Configuration(
      token: Secrets.openAIToken,
      organizationIdentifier: Secrets.openAIOranizationID,
      timeoutInterval: 60.0
    ))

    return Self(
      fetchBeginnerWords: {
        try await openAI.chats(
          query: ChatQuery(
            model: .gpt3_5Turbo,
            messages: [
              Chat(role: .user, content: "Hi, I'm trying to build a resume.")
            ]
          )
        )
        .choices
        .first?
        .message
        .content ?? ""
      }
    )
  }
}
