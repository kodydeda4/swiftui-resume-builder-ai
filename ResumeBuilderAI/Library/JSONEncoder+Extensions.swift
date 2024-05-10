import Foundation
import Supabase

extension JSONEncoder {
  static var liveValue: JSONEncoder {
    let rv = PostgrestClient.Configuration.jsonEncoder
    rv.keyEncodingStrategy = .convertToSnakeCase
    return rv
  }
}
