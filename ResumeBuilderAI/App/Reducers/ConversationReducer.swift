import ComposableArchitecture
import SwiftUI
import OpenAI

@Reducer
struct ConversationReducer {
  @ObservableState
  struct State: Identifiable, Equatable {
    var id: Conversation.ID { self.conversation.id }
    let chatModel = Model.gpt3_5Turbo
    var conversation: Conversation
    var inputText = String()
    @Presents var destination: Destination.State?
    
    init() {
      @Dependency(\.uuid) var uuid
      self.conversation = Conversation(id: uuid().uuidString, messages: [])
    }
  }
  enum Action: ViewAction {
    case view(View)
    case destination(PresentationAction<Destination.Action>)
    case chatStreamResponse(Result<ChatStreamResult, Error>)
    
    enum View: BindableAction {
      case task
      case sendMessageButtonTapped
      case navigateToAccount
      case binding(BindingAction<State>)
    }
  }
  
  @Dependency(\.openAI) var openAI
  @Dependency(\.uuid) var uuid
  
  var body: some ReducerOf<Self> {
    BindingReducer(action: \.view)
    Reduce { state, action in
      switch action {
        
      case let .view(action):
        switch action {
          
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
          
        case .binding:
          return .none
          
        case .sendMessageButtonTapped:
          let message = Message(
            id: self.uuid().uuidString,
            role: .user,
            content: state.inputText.trimmingCharacters(in: .whitespacesAndNewlines),
            createdAt: Date()
          )
          
          guard !message.content.isEmpty else {
            return .none
          }
          state.inputText = ""
          state.conversation.messages.append(message)
          return .send(.view(.task))
          
        case .navigateToAccount:
          state.destination = .account(.init())
          return .none
        }
        
      case let .chatStreamResponse(.success(partialChatResult)):
        partialChatResult.choices.forEach { choice in
          let message = Message(
            id: partialChatResult.id,
            role: choice.delta.role ?? .assistant,
            content: choice.delta.content ?? "",
            createdAt: Date(timeIntervalSince1970: TimeInterval(partialChatResult.created))
          )
          
          guard let existingMessage = state.conversation.messages[id: partialChatResult.id] else {
            state.conversation.messages.append(message)
            return
          }
          
          // Meld into previous message
          let previousMessage = existingMessage
          state.conversation.messages[id: partialChatResult.id] = Message(
            id: message.id, // id stays the same for different deltas
            role: message.role,
            content: previousMessage.content + message.content,
            createdAt: message.createdAt
          )
        }
        return .none
        
      case .chatStreamResponse(.failure):
        return .none
        
      case .destination:
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination)
  }
  
  @Reducer(state: .equatable)
  enum Destination {
    case account(Account)
  }
}

// MARK: - SwiftUI

@ViewAction(for: ConversationReducer.self)
struct ConversationView: View {
  @Bindable var store: StoreOf<ConversationReducer>
  
  var body: some View {
    NavigationStack {
      ScrollViewReader { scrollViewProxy in
        VStack(spacing: 0) {
          Divider()
          content
          Divider().padding(.bottom)
          inputBar(scrollViewProxy: scrollViewProxy)
        }
      }
      .task { await send(.task).finish() }
      .sheet(item: $store.scope(
        state: \.destination?.account,
        action: \.destination.account
      )) { store in
        AccountSheet(store: store)
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Text("Resume Builder AI")
            .bold()
        }
        ToolbarItem(placement: .primaryAction) {
          Button(action: { send(.navigateToAccount) }) {
            Image(systemName: "person.circle.fill")
          }
        }
      }
    }
  }
  
  @MainActor private var content: some View {
    List {
      ForEach(store.conversation.messages) { message in
        ChatBubble(message: message)
      }
      .listRowSeparator(.hidden)
    }
    .listStyle(.plain)
    .animation(.default, value: store.conversation.messages)
  }
  
  @ViewBuilder private func inputBar(scrollViewProxy: ScrollViewProxy) -> some View {
    HStack {
//      TextEditor(text: $store.inputText)
      TextField("Message", text: $store.inputText)
        .padding(.vertical, -8)
        .padding(.horizontal, -4)
        .frame(minHeight: 22, maxHeight: 300)
        .foregroundColor(.primary)
        .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
        .background(
          RoundedRectangle(
            cornerRadius: 16,
            style: .continuous
          )
          .fill(Color(uiColor: UIColor.systemBackground))
          .overlay(
            RoundedRectangle(
              cornerRadius: 16,
              style: .continuous
            )
            .stroke(
              Color(uiColor: UIColor.systemGray5),
              lineWidth: 1
            )
          )
        )
        .fixedSize(horizontal: false, vertical: true)
        .onSubmit { send(.sendMessageButtonTapped) }
        .padding(.leading)
      
      Button(action: { send(.sendMessageButtonTapped) }) {
        Image(systemName: "paperplane")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 24, height: 24)
          .padding(.trailing)
      }
      .disabled(store.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    .padding(.bottom)
  }
}

private struct ChatBubble: View {
  let message: Message
  
  private let assistantBackgroundColor = Color(uiColor: UIColor.systemGray5)
  private let userForegroundColor = Color(uiColor: .white)
  private let userBackgroundColor = Color.accentColor
  
  var body: some View {
    HStack {
      switch message.role {
        
      case .assistant:
        Text(message.content)
          .padding(.horizontal, 16)
          .padding(.vertical, 12)
          .background(assistantBackgroundColor)
          .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        Spacer(minLength: 24)
        
      case .user:
        Spacer(minLength: 24)
        Text(message.content)
          .padding(.horizontal, 16)
          .padding(.vertical, 12)
          .foregroundColor(userForegroundColor)
          .background(userBackgroundColor)
          .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        
      case .tool:
        Text(message.content)
          .font(.footnote.monospaced())
          .padding(.horizontal, 16)
          .padding(.vertical, 12)
          .background(assistantBackgroundColor)
          .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        Spacer(minLength: 24)
        
      case .system:
        EmptyView()
      }
    }
  }
}

// MARK: - SwiftUI Previews

#Preview {
  ConversationView(store: Store(initialState: ConversationReducer.State()) {
    ConversationReducer()
  })
}

