import Combine
import SwiftUI

public struct VanillaMainView: View {
  @ObservedObject var store = ChatStore()
  let idProvider: () -> String = { UUID().uuidString }
  let dateProvider: () -> Date = { Date() }
  
  public var body: some View {
    NavigationSplitView {
      ListView(
        conversations: $store.conversations,
        selectedConversationId: Binding<Conversation.ID?>(
          get: { store.selectedConversationID },
          set: { newId in store.selectConversation(newId) }
        )
      )
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button(action: { store.createConversation() }) {
            Image(systemName: "plus")
          }
          .buttonStyle(.borderedProminent)
        }
      }
    } detail: {
      Text("Detail")
      if let conversation = store.selectedConversation {
        DetailView(
          conversation: conversation,
          error: store.conversationErrors[conversation.id],
          sendMessage: { message, selectedModel in
            Task {
              await store.sendMessage(
                Message(
                  id: idProvider(),
                  role: .user,
                  content: message,
                  createdAt: dateProvider()
                ),
                conversationId: conversation.id,
                model: selectedModel
              )
            }
          }
        )
      }
    }
  }
}
