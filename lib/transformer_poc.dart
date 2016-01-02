/// Proof of concept implementation for a transformer that detects and inlines
/// calls of the package-provided `verbose` function with string literal
/// arguments.
library verbose_regexp.transformer;

import 'package:analyzer/analyzer.dart';
import 'package:analyzer/src/generated/scanner.dart';
import 'dart:io';

import 'package:verbose_regexp/verbose_regexp.dart';

const String verbosePackageUrl = 'package:verbose_regexp/verbose_regexp.dart';

/// Scans this file, replaces all calls of `verbose()` with its result and
/// prints the resulting code.
///
/// This logic will later move into the `apply` method of a barback transformer.
main() {
  var source = new File('transformer_poc.dart').readAsStringSync();
  var ast = parseCompilationUnit(source,
      name: 'transformer_poc.dart', parseFunctionBodies: true);

  var importStatement = ast.directives.firstWhere(
      (directive) => directive is ImportDirective &&
          directive.uri.stringValue == verbosePackageUrl,
      orElse: () => null);
  if (importStatement == null) return;

  var visitor = new ExecuteVerboseVisitor();
  ast.visitChildren(visitor);

  if (!visitor.modifiedAst) return;
  print(ast);
}

/// This visitor traverses the AST to find `verbose` calls with compile-time
/// constant arguments. It executes these functions and replaces them with the
/// equally compile-time constant result.
class ExecuteVerboseVisitor extends RecursiveAstVisitor {
  bool _modifiedAst = false;

  /// Indicates whether at least one occurence of `verbose` was replaced.
  bool get modifiedAst => _modifiedAst;

  /// Used to extract the type of quotes from [SimpleStringLiteral]s. These are
  /// used to wrap the replaced string.
  ///
  /// Also this verbose call is the example that gets replaced when this file is
  /// executed.
  static final RegExp _quotesMatcher = new RegExp(verbose("""
    '(?:'')? # one or three single quotes
    |
    "(?:"")? # one or three double quotes
  """));

  /// Replace the [MethodInvocation] node with a [SimpleStringLiteral] if the
  /// called function is `verbose` and the argument is a [SimpleStringLiteral].
  @override
  visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);
    if (_isConstantVerboseCall(node)) {
      _replaceInvocationNode(node);
      _modifiedAst = true;
    }
  }

  bool _isConstantVerboseCall(MethodInvocation node) {
    // TODO: handle import aliasing
    if (node.methodName.name != 'verbose') return false;
    if (node.realTarget != null) return false;
    if (node.argumentList.arguments.length != 1) return false;
    var argument = node.argumentList.arguments[0];
    return argument is SimpleStringLiteral;
  }

  void _replaceInvocationNode(MethodInvocation invocation) {
    var argument = invocation.argumentList.arguments[0] as SimpleStringLiteral;
    var quotes = _quotesMatcher.matchAsPrefix(argument.literal.lexeme).group(0);
    var result = quotes + verbose(argument.stringValue) + quotes;
    var resultToken =
        new StringToken(TokenType.STRING, result, invocation.beginToken.offset);

    var replacement = new SimpleStringLiteral(resultToken, result);
    invocation.parent.accept(new NodeReplacer(invocation, replacement));
  }
}
