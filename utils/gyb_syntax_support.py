import json
import os
import sys

SYNTAX_BASE_KINDS = ['DeclSyntax', 'ExprSyntax', 'PatternSyntax', 'StmtSyntax',
                     'Syntax', 'SyntaxCollection', 'TypeSyntax']

def error(msg):
    print("error: %s" % msg)
    sys.exit(-1)

class Child(object):
    def __init__(self, name, props):
        self.capital_name = name
        self.name = lowercase_first_word(self.capital_name)

        self.type_name = props.get("kind")
        self.capital_syntax_kind = strip_syntax_suffix(self.capital_name)
        self.syntax_kind = lowercase_first_word(self.capital_syntax_kind)
        if "Token" in self.type_name:
            self.token_kind = self.type_name
            self.type_name = "TokenSyntax"
        else:
            self.token_kind = None

        self.is_optional = props.get("optional", False)
        self.token_choices = props.get("choices", [])

class Node(object):
    """
    A Syntax node, possibly with children.
    If the kind is "SyntaxCollection", then this node is considered a Syntax
    Collection that will expose itself as a typedef rather than a concrete
    subclass.
    """
    def __init__(self, name, props):
        self.name = name
        self.children = [Child(list(child_dict.keys())[0],
                               list(child_dict.values())[0])
                            for child_dict in props.get("children", [])]
        self.kind = props.get("kind")
        self.comment = "\n".join(props.get("comment", []))

        self.capital_syntax_kind = strip_syntax_suffix(self.name)
        self.syntax_kind = lowercase_first_word(self.capital_syntax_kind)

        if self.kind not in SYNTAX_BASE_KINDS:
            error("unknown kind: '%s'" % self.kind)

        self.collection_element = props.get("element", "")
        self.collection_element_kind = \
            strip_syntax_suffix(self.collection_element)

    def is_syntax_collection(self):
        return self.kind == "SyntaxCollection"

    def has_children(self):
        return len(self.children) > 0

    def __repr__(self):
        return self.name

class Token(object):
    def __init__(self, name, props):
        self.name = name
        self.kind = props.get("kind")
        self.text = props.get("text")
        self.is_keyword = props.get("is_keyword", False)

def lowercase_first_word(name):
    word_index = 0
    threshold_index = 1
    for c in name:
        if c.islower():
            if word_index > threshold_index:
                word_index -= 1
            break
        word_index += 1
    if word_index == 0:
        return name
    return name[:word_index].lower() + name[word_index:]

def strip_syntax_suffix(string):
    return string.replace("Syntax", "")

def json_path(kind):
    current_path = os.path.dirname(os.path.abspath(__file__))
    syntax_dir = os.path.join(current_path, "..", "include", "swift", "Syntax")
    return os.path.join(syntax_dir, "%sSyntax.json" % kind)

def load_syntax_tokens():
    with open(json_path("Token")) as tok_file:
        tok_dicts = json.load(tok_file)
        return {name: Token(name, props) for (name, props) in tok_dicts.items()}

def load_all_syntax_nodes():
    names = [
      "Decl", "Expr", "Generic", "Stmt", "Type", "Attribute", "Pattern"
    ]
    nodes = []
    for name in names:
      nodes += load_syntax_json(json_path(name))
    return nodes

def load_syntax_json(path):
    with open(path) as json_file:
        node_dicts = json.load(json_file)
        return [Node(name, props) for (name, props) in node_dicts.items()]
