import ComposableArchitecture
import OpenAI
import Foundation

/// OpenAI Documentation
/// https://platform.openai.com/docs/overview
/// https://github.com/MacPaw/OpenAI
@DependencyClient
struct OpenAIClient: DependencyKey {
  var chat: @Sendable (Conversation, Model) async ->
  AsyncThrowingStream<ChatStreamResult, Error> = { _,_  in .finished() }

  static var liveValue: Self {
    let openAI = OpenAI(configuration: OpenAI.Configuration(
      token: Secrets.openAIToken,
      organizationIdentifier: Secrets.openAIOranizationID,
      timeoutInterval: 60.0
    ))

    return Self(
      chat: { conversation, model in
        openAI.chatsStream(
          query: ChatQuery(
            messages: conversation.messages.map { message in
              ChatQuery.ChatCompletionMessageParam(role: message.role, content: message.content)!
            },
            model: model
          )
        )
      }
    )
  }
}

struct Conversation: Equatable, Identifiable {
  let id: String
  var messages: IdentifiedArrayOf<Message>
}

struct Message: Equatable, Codable, Hashable, Identifiable {
  var id: String
  var role: ChatQuery.ChatCompletionMessageParam.Role
  var content: String
  var createdAt: Date
}

extension DependencyValues {
  var openAI: OpenAIClient {
    get { self[OpenAIClient.self] }
    set { self[OpenAIClient.self] = newValue }
  }
}
