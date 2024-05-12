# SwiftUI Resume Builder AI

<img width="50" src="https://github.com/kodydeda4/swiftui-resume-builder-ai/assets/45678211/6eeb1ca6-4d7f-4de4-91d9-409e733f7bf2"> <img width="50" src="https://static.vecteezy.com/system/resources/previews/021/059/825/non_2x/chatgpt-logo-chat-gpt-icon-on-green-background-free-vector.jpg"> <img width="50" src="https://miro.medium.com/v2/resize:fit:1400/0*QzPzYLTNRX7p5Rsl"> <img width="50" src="https://github.com/kodydeda4/swiftui-resume-builder-ai/assets/45678211/6fcfd313-c589-4ec6-b5b8-d02524299480">

App demo that uses `SwiftUI`, `Supabase`, `OpenAI`, and `ComposableArchitecture` API's to create an ai chat experience.

## Overview

<img width="175" src="https://github.com/kodydeda4/swiftui-resume-builder-ai/assets/45678211/8ce58ad2-4a96-4377-838d-c6230ca12ba3">
<img width="175" src="https://github.com/kodydeda4/swiftui-resume-builder-ai/assets/45678211/66d9d175-9041-4336-be0e-0189edb72495">
<img width="175" src="https://github.com/kodydeda4/swiftui-resume-builder-ai/assets/45678211/1c42f091-048f-431c-bd9e-a1530393008c">
<img width="175" src="https://github.com/kodydeda4/swiftui-resume-builder-ai/assets/45678211/cd47d17d-ac43-4026-853c-0437e1c27863">
<img width="175" src="https://github.com/kodydeda4/swiftui-resume-builder-ai/assets/45678211/d48eb07f-b61e-4759-9758-895576285a00">

## 1. Third Party APIs

* [Supabase](https://supabase.com/) open source Firebase alternative
* [OpenAI](https://platform.openai.com/) ChatGPT
* [ComposableArchitecture](https://github.com/pointfreeco/swift-composable-architecture) A library for building applications in a consistent and understandable way.

## 2. Features

* Apple Sign In
* OpenAI Chat
* Dependency Injection

## 3. Code Snippets

`ChatReducer` listens for changes to the `openai` dependency `chat` endpoint:

```swift
case .task:
  return .run { [conversation = state.conversation, chatModel = state.chatModel] send in
    await withThrowingTaskGroup(of: Void.self) { taskGroup in
      taskGroup.addTask {
        for try await value in await openAI.chat(conversation, chatModel) {
          await send(.chatStreamResponse(Result { value }))
        }
      }
    }
  }
```

## 4. 🚨 Warning

OpenAI will automatically detect public api keys and delete them. You will have to [create your own OpenAI api key](https://platform.openai.com/docs/overview) to get this running and update `Secrets.swift`
