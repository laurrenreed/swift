from __future__ import print_function
import json
import os
import sys
from collections import OrderedDict

"""
All the known base syntax kinds. These will all be considered non-final classes
and other types will be allowed to inherit from them.
"""
SYNTAX_BASE_KINDS = ['Decl', 'Expr', 'Pattern', 'Stmt',
                     'Syntax', 'SyntaxCollection', 'Type']

"""
All Syntax node definitions as Node objects.
"""
SYNTAX_NODES = []

"""
All Syntax token definitions as Token objects.
"""
SYNTAX_TOKENS = {}


def error(msg):
    """
    Prints the provided error to stderr and exits with a non-zero exit code.
    """
    print("error: %s" % msg, file=sys.stderr)
    sys.exit(-1)


class Child(object):
    """
    A child of a node, that may be declared optional or a token with a
    restricted subset of acceptable kinds or texts. 
    """
    def __init__(self, name, props, parent_name):
        self.name = name
        self.syntax_kind = props.get("kind")
        self.type_name = kind_to_type(self.syntax_kind)

        # If the child has "token" anywhere in the kind, it's considered
        # a token node. Grab the existing reference to that token from the
        # global list.
        self.token_kind = \
            self.syntax_kind if "Token" in self.syntax_kind else None
        self.token = SYNTAX_TOKENS.get(self.token_kind)

        self.is_optional = props.get("optional", False)

        # A restricted set of token kinds that will be accepted for this
        # child.
        self.token_choices = []
        if self.token:
            self.token_choices.append(self.token)
        for choice in props.get("choices", []):
            token = SYNTAX_TOKENS[choice]
            if not token:
                error("unknown token kind '%s' in child '%s' of node '%s'" %
                      (choice, name, parent_name))
            self.token_choices.append(token)

        # A list of valid text for tokens, if specified.
        # This will force validation logic to check the text passed into the
        # token against the choices.
        self.text_choices = props.get("text_choices", [])

    def is_token(self):
        """
        Returns true if this child has a token kind.
        """
        return self.token_kind is not None

    def main_token(self):
        """
        Returns the first choice from the token_choices if there are any,
        otherwise returns None.
        """
        if self.token_choices:
            return self.token_choices[0]
        return None


class Node(object):
    """
    A Syntax node, possibly with children.
    If the kind is "SyntaxCollection", then this node is considered a Syntax
    Collection that will expose itself as a typedef rather than a concrete
    subclass.
    """
    def __init__(self, kind, props):
        self.name = kind_to_type(kind)
        self.syntax_kind = kind

        self.children = [Child(list(child_dict.keys())[0],
                               list(child_dict.values())[0],
                               kind)
                         for child_dict in props.get("children", [])]
        self.base_kind = props.get("kind")
        self.base_type = kind_to_type(self.base_kind)
        self.comment = "\n".join(props.get("comment", []))

        if self.base_kind not in SYNTAX_BASE_KINDS:
            error("unknown base kind '%s' for node '%s'" % 
                  (self.base_kind, self.syntax_kind))

        self.collection_element = props.get("element", "")
        # If there's a preferred name for the collection element that differs
        # from its supertype, use that.
        self.collection_element_name = props.get("element_name",
                                                 self.collection_element)
        self.collection_element_type = kind_to_type(self.collection_element)

    def is_base(self):
        """
        Returns `True` if this node declares one of the base syntax kinds.
        """
        return self.syntax_kind in SYNTAX_BASE_KINDS

    def is_syntax_collection(self):
        """
        Returns `True` if this node is a subclass of SyntaxCollection.
        """
        return self.base_kind == "SyntaxCollection"

    def requires_validation(self):
        """
        Returns `True` if this node should have a `valitate` method associated.
        """
        return self.is_buildable()

    def is_unknown(self):
        """
        Returns `True` if this node is an `Unknown` syntax subclass.
        """
        return "Unknown" in self.syntax_kind

    def is_buildable(self):
        """
        Returns `True` if this node should have a builder associated.
        """
        return not self.is_base() and \
            not self.is_unknown() and \
            not self.is_syntax_collection()


class Token(object):
    """
    Represents the specification for a Token in the TokenSyntax file.
    """
    def __init__(self, name, props):
        self.name = name
        self.kind = props.get("kind")
        self.text = props.get("text", "")
        self.is_keyword = props.get("is_keyword", False)


def make_missing_child(child):
    """
    Generates a C++ call to make the raw syntax for a given Child object.
    """

    if child.is_token():
        token = child.main_token()
        tok_kind = "tok::" + token.kind if token else "tok::unknown"
        tok_text = token.text if token else ""
        return 'RawTokenSyntax::missingToken(%s, "%s")' % (tok_kind, tok_text)
    else:
        missing_kind = "Unknown" if child.syntax_kind == "Syntax" \
                       else child.syntax_kind
        return 'RawSyntax::missing(SyntaxKind::%s)' % missing_kind


def kind_to_type(kind):
    """
    Converts a SyntaxKind to a type name, checking to see if the kind is
    Syntax or SyntaxCollection first.
    A type name is the same as the SyntaxKind name with the suffix "Syntax"
    added.
    """
    if kind in ["Syntax", "SyntaxCollection"]:
        return kind
    if kind.endswith("Token"):
        return "TokenSyntax"
    return kind + "Syntax"


def json_path(kind):
    """
    Gets the path to the JSON file for the provided kind in
    include/swift/Syntax/
    """
    current_path = os.path.dirname(os.path.abspath(__file__))
    syntax_dir = os.path.join(current_path, "..", "include", "swift", "Syntax")
    return os.path.join(syntax_dir, "%sSyntax.json" % kind)


def load_syntax_tokens():
    """
    Loads a dictionary mapping the tokens in TokenSyntax.json to their names
    so nodes can look up requirements if they have declared specific token
    types for their children.
    """
    global SYNTAX_TOKENS
    with open(json_path("Token")) as tok_file:
        tok_dicts = json.load(tok_file, object_pairs_hook=OrderedDict)
        SYNTAX_TOKENS = {name + "Token": Token(name, props)
                         for (name, props) in tok_dicts.items()}


def load_all_syntax_nodes():
    """
    Loads all syntax nodes from all JSON files into an array.
    """
    names = [
        "Common", "Decl", "Expr", "Generic", 
        "Stmt", "Type", "Attribute", "Pattern"
    ]
    global SYNTAX_NODES
    for name in names:
        SYNTAX_NODES += load_syntax_json(json_path(name))


def load_syntax_json(path):
    """
    Loads all nodes from a single JSON file into an array.
    """
    with open(path) as json_file:
        node_dicts = json.load(json_file, object_pairs_hook=OrderedDict)
        return [Node(name, props) for (name, props) in node_dicts.items()]


def create_node_map():
    """
    Returns a lookup table that maps the syntax kind of a node to its
    definition. 
    """
    return {node.syntax_kind: node for node in SYNTAX_NODES}


load_syntax_tokens()
load_all_syntax_nodes()
