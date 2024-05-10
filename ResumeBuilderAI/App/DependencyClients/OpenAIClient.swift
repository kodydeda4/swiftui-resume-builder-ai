import ComposableArchitecture
import OpenAI

/// OpenAI Documentation
/// https://platform.openai.com/docs/overview
/// https://github.com/MacPaw/OpenAI
@DependencyClient
struct OpenAIClient: DependencyKey {
  var chat: @Sendable () async -> AsyncThrowingStream<CompletionsResult, Error> = { .finished() }
  
  static var liveValue: Self {
    let openAI = OpenAI(configuration: OpenAI.Configuration(
      token: Secrets.openAIToken,
      organizationIdentifier: Secrets.openAIOranizationID,
      timeoutInterval: 60.0
    ))

    return Self(
      chat: {
        AsyncThrowingStream { continuation in
          let task = Task {
            while !Task.isCancelled {
              for try await value in openAI.completionsStream(
                query: .init(
                  model: .gpt3_5Turbo,
                  prompt: "Hi, I'm trying to build a resume."
                )
              ) {
                continuation.yield(value)
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
  var openAI: OpenAIClient {
    get { self[OpenAIClient.self] }
    set { self[OpenAIClient.self] = newValue }
  }
}
