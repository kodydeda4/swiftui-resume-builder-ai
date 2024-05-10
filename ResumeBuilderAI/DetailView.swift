import UIKit
import OpenAI
import SwiftUI

struct DetailView: View {
  @State var inputText: String = ""
  
  var conversation: Conversation
  var error: Error?
  var sendMessage: (String, Model) -> Void
  
  private let chatModel: Model = .gpt3_5Turbo
  private let fillColor = Color(uiColor: UIColor.systemBackground)
  private let strokeColor = Color(uiColor: UIColor.systemGray5)
  
  var body: some View {
    NavigationStack {
      ScrollViewReader { scrollViewProxy in
        VStack {
          List {
            ForEach(conversation.messages) { message in
              ChatBubble(message: message)
            }
            .listRowSeparator(.hidden)
          }
          .listStyle(.plain)
          .animation(.default, value: conversation.messages)
          
          if let error = error {
            errorMessage(error: error)
          }
          
          inputBar(scrollViewProxy: scrollViewProxy)
        }
      }
    }
  }
  
  @ViewBuilder private func errorMessage(error: Error) -> some View {
    Text(error.localizedDescription)
      .font(.caption)
      .foregroundColor(Color(uiColor: .systemRed))
      .padding(.horizontal)
  }
  
  @ViewBuilder private func inputBar(scrollViewProxy: ScrollViewProxy) -> some View {
    HStack {
      TextEditor(
        text: $inputText
      )
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
        .fill(fillColor)
        .overlay(
          RoundedRectangle(
            cornerRadius: 16,
            style: .continuous
          )
          .stroke(
            strokeColor,
            lineWidth: 1
          )
        )
      )
      .fixedSize(horizontal: false, vertical: true)
      .onSubmit {
        tapSendMessage(scrollViewProxy: scrollViewProxy)
      }
      .padding(.leading)
      
      Button(action: { tapSendMessage(scrollViewProxy: scrollViewProxy) }) {
        Image(systemName: "paperplane")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 24, height: 24)
          .padding(.trailing)
      }
      .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    .padding(.bottom)
  }
  
  private func tapSendMessage(scrollViewProxy: ScrollViewProxy) {
    let message = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
    
    if message.isEmpty {
      return
    }
    
    sendMessage(message, chatModel)
    inputText = ""
  }
}

struct ChatBubble: View {
  let message: Message
  
  private let assistantBackgroundColor = Color(uiColor: UIColor.systemGray5)
  private let userForegroundColor = Color(uiColor: .white)
  private let userBackgroundColor = Color(uiColor: .systemBlue)
  
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
