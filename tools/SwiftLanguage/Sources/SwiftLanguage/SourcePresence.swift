import Foundation

/// An indicator of whether a Syntax node was found or written in the source.
///
/// This does not mean, necessarily, that the source item is considered "implicit".
public enum SourcePresence: String, Codable {
  /// The syntax was authored by a human and found, or was generated.
  case present = "Present"

  /// The syntax was expected or optional, but not found in the source.
  case missing = "Missing"
}
