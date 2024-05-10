import Foundation
import Supabase

extension JSONDecoder {
  static var liveValue: JSONDecoder {
    let rv = PostgrestClient.Configuration.jsonDecoder
    rv.keyDecodingStrategy = .convertFromSnakeCase
    return rv
  }
}
