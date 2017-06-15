public enum TokenKind: Codable {
  case identifier(String)
  case integer_literal(String)
  case floating_literal(String)
  case oper_binary_unspaced(String)
  case oper_binary_spaced(String)
  case oper_postfix(String)
  case oper_prefix(String)
  case dollarident(String)
  case string_literal(String)
  case comment(String)
  case eof
  case kw_associatedtype
  case kw_class
  case kw_deinit
  case kw_enum
  case kw_extension
  case kw_func
  case kw_import
  case kw_init
  case kw_inout
  case kw_let
  case kw_operator
  case kw_precedencegroup
  case kw_protocol
  case kw_struct
  case kw_subscript
  case kw_typealias
  case kw_var
  case kw_fileprivate
  case kw_internal
  case kw_private
  case kw_public
  case kw_static
  case kw_defer
  case kw_if
  case kw_guard
  case kw_do
  case kw_repeat
  case kw_else
  case kw_for
  case kw_in
  case kw_while
  case kw_return
  case kw_break
  case kw_continue
  case kw_fallthrough
  case kw_switch
  case kw_case
  case kw_default
  case kw_where
  case kw_catch
  case kw_as
  case kw_Any
  case kw_false
  case kw_is
  case kw_nil
  case kw_rethrows
  case kw_super
  case kw_self
  case kw_Self
  case kw_throw
  case kw_true
  case kw_try
  case kw_throws
  case kw___FILE__
  case kw___LINE__
  case kw___COLUMN__
  case kw___FUNCTION__
  case kw___DSO_HANDLE__
  case kw__
  case l_paren
  case r_paren
  case l_brace
  case r_brace
  case l_square
  case r_square
  case l_angle
  case r_angle
  case period
  case period_prefix
  case comma
  case colon
  case semi
  case equal
  case at_sign
  case pound
  case amp_prefix
  case arrow
  case backtick
  case backslash
  case exclaim_postfix
  case question_postfix
  case question_infix
  case sil_dollar
  case sil_exclamation
  case l_square_lit
  case r_square_lit
  case pound_if
  case pound_else
  case pound_elseif
  case pound_endif
  case pound_keyPath
  case pound_line
  case pound_sourceLocation
  case pound_selector
  case pound_available
  case pound_fileLiteral
  case pound_imageLiteral
  case pound_colorLiteral
  case pound_file
  case pound_column
  case pound_function
  case pound_dsohandle
  
  var text: String {
    switch self {
    case .identifier(let text): return text
    case .integer_literal(let text): return text
    case .floating_literal(let text): return text
    case .oper_binary_unspaced(let text): return text
    case .oper_binary_spaced(let text): return text
    case .oper_postfix(let text): return text
    case .oper_prefix(let text): return text
    case .dollarident(let text): return text
    case .string_literal(let text): return text
    case .comment(let text): return text
    case .eof: return "eof"
    case .kw_associatedtype: return "associatedtype"
    case .kw_class: return "class"
    case .kw_deinit: return "deinit"
    case .kw_enum: return "enum"
    case .kw_extension: return "extension"
    case .kw_func: return "func"
    case .kw_import: return "import"
    case .kw_init: return "init"
    case .kw_inout: return "inout"
    case .kw_let: return "let"
    case .kw_operator: return "operator"
    case .kw_precedencegroup: return "precedencegroup"
    case .kw_protocol: return "protocol"
    case .kw_struct: return "struct"
    case .kw_subscript: return "subscript"
    case .kw_typealias: return "typealias"
    case .kw_var: return "var"
    case .kw_fileprivate: return "fileprivate"
    case .kw_internal: return "internal"
    case .kw_private: return "private"
    case .kw_public: return "public"
    case .kw_static: return "static"
    case .kw_defer: return "defer"
    case .kw_if: return "if"
    case .kw_guard: return "guard"
    case .kw_do: return "do"
    case .kw_repeat: return "repeat"
    case .kw_else: return "else"
    case .kw_for: return "for"
    case .kw_in: return "in"
    case .kw_while: return "while"
    case .kw_return: return "return"
    case .kw_break: return "break"
    case .kw_continue: return "continue"
    case .kw_fallthrough: return "fallthrough"
    case .kw_switch: return "switch"
    case .kw_case: return "case"
    case .kw_default: return "default"
    case .kw_where: return "where"
    case .kw_catch: return "catch"
    case .kw_as: return "as"
    case .kw_Any: return "Any"
    case .kw_false: return "false"
    case .kw_is: return "is"
    case .kw_nil: return "nil"
    case .kw_rethrows: return "rethrows"
    case .kw_super: return "super"
    case .kw_self: return "self"
    case .kw_Self: return "Self"
    case .kw_throw: return "throw"
    case .kw_true: return "true"
    case .kw_try: return "try"
    case .kw_throws: return "throws"
    case .kw___FILE__: return "__FILE__"
    case .kw___LINE__: return "__LINE__"
    case .kw___COLUMN__: return "__COLUMN__"
    case .kw___FUNCTION__: return "__FUNCTION__"
    case .kw___DSO_HANDLE__: return "__DSO_HANDLE__"
    case .kw__: return "_"
    case .l_paren: return "("
    case .r_paren: return ")"
    case .l_brace: return "{"
    case .r_brace: return "}"
    case .l_square: return "["
    case .r_square: return "]"
    case .l_angle: return "<"
    case .r_angle: return ">"
    case .period: return "."
    case .period_prefix: return "."
    case .comma: return ","
    case .colon: return ":"
    case .semi: return ";"
    case .equal: return "="
    case .at_sign: return "@"
    case .pound: return "#"
    case .amp_prefix: return "&"
    case .arrow: return "->"
    case .backtick: return "`"
    case .backslash: return "\\"
    case .exclaim_postfix: return "!"
    case .question_postfix: return "?"
    case .question_infix: return "?"
    case .sil_dollar: return "$"
    case .sil_exclamation: return "!"
    case .l_square_lit: return "[#"
    case .r_square_lit: return "#]"
    case .pound_if: return "if"
    case .pound_else: return "else"
    case .pound_elseif: return "elseif"
    case .pound_endif: return "endif"
    case .pound_keyPath: return "keyPath"
    case .pound_line: return "line"
    case .pound_sourceLocation: return "sourceLocation"
    case .pound_selector: return "selector"
    case .pound_available: return "available"
    case .pound_fileLiteral: return "fileLiteral"
    case .pound_imageLiteral: return "imageLiteral"
    case .pound_colorLiteral: return "colorLiteral"
    case .pound_file: return "file"
    case .pound_column: return "column"
    case .pound_function: return "function"
    case .pound_dsohandle: return "dsohandle"
    }
  }
  
  enum CodingKeys: String, CodingKey {
    case kind, text
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let kind = try container.decode(String.self, forKey: .kind)
    switch kind {
    case "eof": self = .eof
    case "kw_associatedtype": self = .kw_associatedtype
    case "kw_class": self = .kw_class
    case "kw_deinit": self = .kw_deinit
    case "kw_enum": self = .kw_enum
    case "kw_extension": self = .kw_extension
    case "kw_func": self = .kw_func
    case "kw_import": self = .kw_import
    case "kw_init": self = .kw_init
    case "kw_inout": self = .kw_inout
    case "kw_let": self = .kw_let
    case "kw_operator": self = .kw_operator
    case "kw_precedencegroup": self = .kw_precedencegroup
    case "kw_protocol": self = .kw_protocol
    case "kw_struct": self = .kw_struct
    case "kw_subscript": self = .kw_subscript
    case "kw_typealias": self = .kw_typealias
    case "kw_var": self = .kw_var
    case "kw_fileprivate": self = .kw_fileprivate
    case "kw_internal": self = .kw_internal
    case "kw_private": self = .kw_private
    case "kw_public": self = .kw_public
    case "kw_static": self = .kw_static
    case "kw_defer": self = .kw_defer
    case "kw_if": self = .kw_if
    case "kw_guard": self = .kw_guard
    case "kw_do": self = .kw_do
    case "kw_repeat": self = .kw_repeat
    case "kw_else": self = .kw_else
    case "kw_for": self = .kw_for
    case "kw_in": self = .kw_in
    case "kw_while": self = .kw_while
    case "kw_return": self = .kw_return
    case "kw_break": self = .kw_break
    case "kw_continue": self = .kw_continue
    case "kw_fallthrough": self = .kw_fallthrough
    case "kw_switch": self = .kw_switch
    case "kw_case": self = .kw_case
    case "kw_default": self = .kw_default
    case "kw_where": self = .kw_where
    case "kw_catch": self = .kw_catch
    case "kw_as": self = .kw_as
    case "kw_Any": self = .kw_Any
    case "kw_false": self = .kw_false
    case "kw_is": self = .kw_is
    case "kw_nil": self = .kw_nil
    case "kw_rethrows": self = .kw_rethrows
    case "kw_super": self = .kw_super
    case "kw_self": self = .kw_self
    case "kw_Self": self = .kw_Self
    case "kw_throw": self = .kw_throw
    case "kw_true": self = .kw_true
    case "kw_try": self = .kw_try
    case "kw_throws": self = .kw_throws
    case "kw___FILE__": self = .kw___FILE__
    case "kw___LINE__": self = .kw___LINE__
    case "kw___COLUMN__": self = .kw___COLUMN__
    case "kw___FUNCTION__": self = .kw___FUNCTION__
    case "kw___DSO_HANDLE__": self = .kw___DSO_HANDLE__
    case "kw__": self = .kw__
    case "l_paren": self = .l_paren
    case "r_paren": self = .r_paren
    case "l_brace": self = .l_brace
    case "r_brace": self = .r_brace
    case "l_square": self = .l_square
    case "r_square": self = .r_square
    case "l_angle": self = .l_angle
    case "r_angle": self = .r_angle
    case "period": self = .period
    case "period_prefix": self = .period_prefix
    case "comma": self = .comma
    case "colon": self = .colon
    case "semi": self = .semi
    case "equal": self = .equal
    case "at_sign": self = .at_sign
    case "pound": self = .pound
    case "amp_prefix": self = .amp_prefix
    case "arrow": self = .arrow
    case "backtick": self = .backtick
    case "backslash": self = .backslash
    case "exclaim_postfix": self = .exclaim_postfix
    case "question_postfix": self = .question_postfix
    case "question_infix": self = .question_infix
    case "sil_dollar": self = .sil_dollar
    case "sil_exclamation": self = .sil_exclamation
    case "l_square_lit": self = .l_square_lit
    case "r_square_lit": self = .r_square_lit
    case "pound_if": self = .pound_if
    case "pound_else": self = .pound_else
    case "pound_elseif": self = .pound_elseif
    case "pound_endif": self = .pound_endif
    case "pound_keyPath": self = .pound_keyPath
    case "pound_line": self = .pound_line
    case "pound_sourceLocation": self = .pound_sourceLocation
    case "pound_selector": self = .pound_selector
    case "pound_available": self = .pound_available
    case "pound_fileLiteral": self = .pound_fileLiteral
    case "pound_imageLiteral": self = .pound_imageLiteral
    case "pound_colorLiteral": self = .pound_colorLiteral
    case "pound_file": self = .pound_file
    case "pound_column": self = .pound_column
    case "pound_function": self = .pound_function
    case "pound_dsohandle": self = .pound_dsohandle
    case "identifier":
      let text = try container.decode(String.self, forKey: .text)
      self = .identifier(text)
    case "integer_literal":
      let text = try container.decode(String.self, forKey: .text)
      self = .integer_literal(text)
    case "floating_literal":
      let text = try container.decode(String.self, forKey: .text)
      self = .floating_literal(text)
    case "oper_binary_unspaced":
      let text = try container.decode(String.self, forKey: .text)
      self = .oper_binary_unspaced(text)
    case "oper_binary_spaced":
      let text = try container.decode(String.self, forKey: .text)
      self = .oper_binary_spaced(text)
    case "oper_postfix":
      let text = try container.decode(String.self, forKey: .text)
      self = .oper_postfix(text)
    case "oper_prefix":
      let text = try container.decode(String.self, forKey: .text)
      self = .oper_prefix(text)
    case "dollarident":
      let text = try container.decode(String.self, forKey: .text)
      self = .dollarident(text)
    case "string_literal":
      let text = try container.decode(String.self, forKey: .text)
      self = .string_literal(text)
    case "comment":
      let text = try container.decode(String.self, forKey: .text)
      self = .comment(text)
    default: fatalError("unknown token kind \(kind)")
    }
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(kind, forKey: .kind)
    try container.encode(text, forKey: .text)
  }
  
  var kind: String {
    switch self {
    case .eof: return "eof"
    case .kw_associatedtype: return "kw_associatedtype"
    case .kw_class: return "kw_class"
    case .kw_deinit: return "kw_deinit"
    case .kw_enum: return "kw_enum"
    case .kw_extension: return "kw_extension"
    case .kw_func: return "kw_func"
    case .kw_import: return "kw_import"
    case .kw_init: return "kw_init"
    case .kw_inout: return "kw_inout"
    case .kw_let: return "kw_let"
    case .kw_operator: return "kw_operator"
    case .kw_precedencegroup: return "kw_precedencegroup"
    case .kw_protocol: return "kw_protocol"
    case .kw_struct: return "kw_struct"
    case .kw_subscript: return "kw_subscript"
    case .kw_typealias: return "kw_typealias"
    case .kw_var: return "kw_var"
    case .kw_fileprivate: return "kw_fileprivate"
    case .kw_internal: return "kw_internal"
    case .kw_private: return "kw_private"
    case .kw_public: return "kw_public"
    case .kw_static: return "kw_static"
    case .kw_defer: return "kw_defer"
    case .kw_if: return "kw_if"
    case .kw_guard: return "kw_guard"
    case .kw_do: return "kw_do"
    case .kw_repeat: return "kw_repeat"
    case .kw_else: return "kw_else"
    case .kw_for: return "kw_for"
    case .kw_in: return "kw_in"
    case .kw_while: return "kw_while"
    case .kw_return: return "kw_return"
    case .kw_break: return "kw_break"
    case .kw_continue: return "kw_continue"
    case .kw_fallthrough: return "kw_fallthrough"
    case .kw_switch: return "kw_switch"
    case .kw_case: return "kw_case"
    case .kw_default: return "kw_default"
    case .kw_where: return "kw_where"
    case .kw_catch: return "kw_catch"
    case .kw_as: return "kw_as"
    case .kw_Any: return "kw_Any"
    case .kw_false: return "kw_false"
    case .kw_is: return "kw_is"
    case .kw_nil: return "kw_nil"
    case .kw_rethrows: return "kw_rethrows"
    case .kw_super: return "kw_super"
    case .kw_self: return "kw_self"
    case .kw_Self: return "kw_Self"
    case .kw_throw: return "kw_throw"
    case .kw_true: return "kw_true"
    case .kw_try: return "kw_try"
    case .kw_throws: return "kw_throws"
    case .kw___FILE__: return "kw___FILE__"
    case .kw___LINE__: return "kw___LINE__"
    case .kw___COLUMN__: return "kw___COLUMN__"
    case .kw___FUNCTION__: return "kw___FUNCTION__"
    case .kw___DSO_HANDLE__: return "kw___DSO_HANDLE__"
    case .kw__: return "kw__"
    case .l_paren: return "l_paren"
    case .r_paren: return "r_paren"
    case .l_brace: return "l_brace"
    case .r_brace: return "r_brace"
    case .l_square: return "l_square"
    case .r_square: return "r_square"
    case .l_angle: return "l_angle"
    case .r_angle: return "r_angle"
    case .period: return "period"
    case .period_prefix: return "period_prefix"
    case .comma: return "comma"
    case .colon: return "colon"
    case .semi: return "semi"
    case .equal: return "equal"
    case .at_sign: return "at_sign"
    case .pound: return "pound"
    case .amp_prefix: return "amp_prefix"
    case .arrow: return "arrow"
    case .backtick: return "backtick"
    case .backslash: return "backslash"
    case .exclaim_postfix: return "exclaim_postfix"
    case .question_postfix: return "question_postfix"
    case .question_infix: return "question_infix"
    case .sil_dollar: return "sil_dollar"
    case .sil_exclamation: return "sil_exclamation"
    case .l_square_lit: return "l_square_lit"
    case .r_square_lit: return "r_square_lit"
    case .pound_if: return "pound_if"
    case .pound_else: return "pound_else"
    case .pound_elseif: return "pound_elseif"
    case .pound_endif: return "pound_endif"
    case .pound_keyPath: return "pound_keyPath"
    case .pound_line: return "pound_line"
    case .pound_sourceLocation: return "pound_sourceLocation"
    case .pound_selector: return "pound_selector"
    case .pound_available: return "pound_available"
    case .pound_fileLiteral: return "pound_fileLiteral"
    case .pound_imageLiteral: return "pound_imageLiteral"
    case .pound_colorLiteral: return "pound_colorLiteral"
    case .pound_file: return "pound_file"
    case .pound_column: return "pound_column"
    case .pound_function: return "pound_function"
    case .pound_dsohandle: return "pound_dsohandle"
    case .identifier(_): return "identifier"
    case .integer_literal(_): return "integer_literal"
    case .floating_literal(_): return "floating_literal"
    case .oper_binary_unspaced(_): return "oper_binary_unspaced"
    case .oper_binary_spaced(_): return "oper_binary_spaced"
    case .oper_postfix(_): return "oper_postfix"
    case .oper_prefix(_): return "oper_prefix"
    case .dollarident(_): return "dollarident"
    case .string_literal(_): return "string_literal"
    case .comment(_): return "comment"
    }
  }
}

extension TokenKind: Equatable {
  public static func ==(lhs: TokenKind, rhs: TokenKind) -> Bool {
    switch (lhs, rhs) {
    case (.eof, .eof): return true
    case (.kw_associatedtype, .kw_associatedtype): return true
    case (.kw_class, .kw_class): return true
    case (.kw_deinit, .kw_deinit): return true
    case (.kw_enum, .kw_enum): return true
    case (.kw_extension, .kw_extension): return true
    case (.kw_func, .kw_func): return true
    case (.kw_import, .kw_import): return true
    case (.kw_init, .kw_init): return true
    case (.kw_inout, .kw_inout): return true
    case (.kw_let, .kw_let): return true
    case (.kw_operator, .kw_operator): return true
    case (.kw_precedencegroup, .kw_precedencegroup): return true
    case (.kw_protocol, .kw_protocol): return true
    case (.kw_struct, .kw_struct): return true
    case (.kw_subscript, .kw_subscript): return true
    case (.kw_typealias, .kw_typealias): return true
    case (.kw_var, .kw_var): return true
    case (.kw_fileprivate, .kw_fileprivate): return true
    case (.kw_internal, .kw_internal): return true
    case (.kw_private, .kw_private): return true
    case (.kw_public, .kw_public): return true
    case (.kw_static, .kw_static): return true
    case (.kw_defer, .kw_defer): return true
    case (.kw_if, .kw_if): return true
    case (.kw_guard, .kw_guard): return true
    case (.kw_do, .kw_do): return true
    case (.kw_repeat, .kw_repeat): return true
    case (.kw_else, .kw_else): return true
    case (.kw_for, .kw_for): return true
    case (.kw_in, .kw_in): return true
    case (.kw_while, .kw_while): return true
    case (.kw_return, .kw_return): return true
    case (.kw_break, .kw_break): return true
    case (.kw_continue, .kw_continue): return true
    case (.kw_fallthrough, .kw_fallthrough): return true
    case (.kw_switch, .kw_switch): return true
    case (.kw_case, .kw_case): return true
    case (.kw_default, .kw_default): return true
    case (.kw_where, .kw_where): return true
    case (.kw_catch, .kw_catch): return true
    case (.kw_as, .kw_as): return true
    case (.kw_Any, .kw_Any): return true
    case (.kw_false, .kw_false): return true
    case (.kw_is, .kw_is): return true
    case (.kw_nil, .kw_nil): return true
    case (.kw_rethrows, .kw_rethrows): return true
    case (.kw_super, .kw_super): return true
    case (.kw_self, .kw_self): return true
    case (.kw_Self, .kw_Self): return true
    case (.kw_throw, .kw_throw): return true
    case (.kw_true, .kw_true): return true
    case (.kw_try, .kw_try): return true
    case (.kw_throws, .kw_throws): return true
    case (.kw___FILE__, .kw___FILE__): return true
    case (.kw___LINE__, .kw___LINE__): return true
    case (.kw___COLUMN__, .kw___COLUMN__): return true
    case (.kw___FUNCTION__, .kw___FUNCTION__): return true
    case (.kw___DSO_HANDLE__, .kw___DSO_HANDLE__): return true
    case (.kw__, .kw__): return true
    case (.l_paren, .l_paren): return true
    case (.r_paren, .r_paren): return true
    case (.l_brace, .l_brace): return true
    case (.r_brace, .r_brace): return true
    case (.l_square, .l_square): return true
    case (.r_square, .r_square): return true
    case (.l_angle, .l_angle): return true
    case (.r_angle, .r_angle): return true
    case (.period, .period): return true
    case (.period_prefix, .period_prefix): return true
    case (.comma, .comma): return true
    case (.colon, .colon): return true
    case (.semi, .semi): return true
    case (.equal, .equal): return true
    case (.at_sign, .at_sign): return true
    case (.pound, .pound): return true
    case (.amp_prefix, .amp_prefix): return true
    case (.arrow, .arrow): return true
    case (.backtick, .backtick): return true
    case (.backslash, .backslash): return true
    case (.exclaim_postfix, .exclaim_postfix): return true
    case (.question_postfix, .question_postfix): return true
    case (.question_infix, .question_infix): return true
    case (.sil_dollar, .sil_dollar): return true
    case (.sil_exclamation, .sil_exclamation): return true
    case (.l_square_lit, .l_square_lit): return true
    case (.r_square_lit, .r_square_lit): return true
    case (.pound_if, .pound_if): return true
    case (.pound_else, .pound_else): return true
    case (.pound_elseif, .pound_elseif): return true
    case (.pound_endif, .pound_endif): return true
    case (.pound_keyPath, .pound_keyPath): return true
    case (.pound_line, .pound_line): return true
    case (.pound_sourceLocation, .pound_sourceLocation): return true
    case (.pound_selector, .pound_selector): return true
    case (.pound_available, .pound_available): return true
    case (.pound_fileLiteral, .pound_fileLiteral): return true
    case (.pound_imageLiteral, .pound_imageLiteral): return true
    case (.pound_colorLiteral, .pound_colorLiteral): return true
    case (.pound_file, .pound_file): return true
    case (.pound_column, .pound_column): return true
    case (.pound_function, .pound_function): return true
    case (.pound_dsohandle, .pound_dsohandle): return true
    case let (.identifier(lhsText), .identifier(rhsText)): return lhsText == rhsText
    case let (.integer_literal(lhsText), .integer_literal(rhsText)): return lhsText == rhsText
    case let (.floating_literal(lhsText), .floating_literal(rhsText)): return lhsText == rhsText
    case let (.oper_binary_unspaced(lhsText), .oper_binary_unspaced(rhsText)): return lhsText == rhsText
    case let (.oper_binary_spaced(lhsText), .oper_binary_spaced(rhsText)): return lhsText == rhsText
    case let (.oper_postfix(lhsText), .oper_postfix(rhsText)): return lhsText == rhsText
    case let (.oper_prefix(lhsText), .oper_prefix(rhsText)): return lhsText == rhsText
    case let (.dollarident(lhsText), .dollarident(rhsText)): return lhsText == rhsText
    case let (.string_literal(lhsText), .string_literal(rhsText)): return lhsText == rhsText
    case let (.comment(lhsText), .comment(rhsText)): return lhsText == rhsText
    default: return false
    }
  }
}
