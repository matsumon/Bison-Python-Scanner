/*
 * Lexer definition for simplified Python syntax.
 */

/*
 * Since we're only parsing 1 file, we don't need to have yywrap() (plus,
 * having it included messes up compilation).
 */


%{
  #include <iostream>
  #include <stack>
  #include <cstdlib>
  #include "parser.hpp"
  /*
  * We'll use this stack to keep track of indentation level, as described in
  * the Python docs:
  *
  * https://docs.python.org/3/reference/lexical_analysis.html#indentation
  */
  std::stack<int> _indent_stack;
  YYSTYPE lexeme;
  yypstate* parserState = yypstate_new();
%}
%option noyywrap

%option yylineno
%%

%{
  /*
   * These lines go at the top of the lexing function yylex().  We only want
   * to initialize the indentation level stack once by pushing a 0 onto it
   * (the indentation stack should never be empty, except immediately after
   * it is created).
   */
  if (_indent_stack.empty()) {
    _indent_stack.push(0);
  }
%}

^[ \t]*\r?\n  /* Skip blank lines */

^[ \t]*#.*\r?\n  /* Skip whole-line comments. */

#.*$  /* Skip comments on the same line as a statement. */

^[ \t]+ {
  /*
   * Handle indentation as described in Python docs linked above. Note that
   * this rule's pattern treats leading spaces and leading tabs equivalently,
   * which could cause some unexpected behavior (compared to normal Python
   * indentation behavior) if they're combined in a single line.  For the
   * purposes of this project, that's OK.
   */
  if (_indent_stack.top() < yyleng) {
    /*
     * If the current indentation level is greater than the previous indentation
     * level (stored at the top of the stack), then emit an INDENT and push the
     * new indentation level onto the stack.
     */
    // std::cout << "INDENT" << std::endl;

    int status = yypush_parse(parserState, INDENT, NULL );
    if (status != YYPUSH_MORE) {
      yypstate_delete(parserState);
      return status;
    }
    _indent_stack.push(yyleng);
  } else {
    /*
     * If the current indentation level is less than or equal to the previous
     * indentation level, pop indentation levels off the stack until the top is
     * equal to the current indentation level.  Emit a DEDENT for each element
     * popped from the stack.
     */
    while (!_indent_stack.empty() && _indent_stack.top() != yyleng) {
      _indent_stack.pop();
      // std::cout << "DEDENT" << std::endl;
      
      int status = yypush_parse(parserState, DEDENT, NULL );
      if (status != YYPUSH_MORE) {
        yypstate_delete(parserState);
        return status;
      }
    }

    /*
     * If we popped everything off the stack, that means the current
     * indentation level didn't match any on the stack, which is an indentation
     * error.
     */
    if (_indent_stack.empty()) {
      std::cerr << "Error: Incorrect indentation on line " << yylineno
        << std::endl;
      
      lexeme.str = new std::string(yytext, yyleng);
      yypush_parse(parserState, yytext[0], &lexeme);
      // return 1;
    }
  }
}

^[^ \t\r\n]+ {
  /*
   * If we find a line that's not indented (i.e. a line that begins with
   * non-whitespace characters), pop all indentation levels off the stack,
   * and emit a DEDENT for each one.  Then, call REJECT, so the next rule
   * matching this token (i.e. the one at the beginning of the line) is also
   * applied.
   */
  while (_indent_stack.top() != 0) {
    _indent_stack.pop();
    // std::cout << "DEDENT" << std::endl;
    
    int status = yypush_parse(parserState, DEDENT, NULL );
    if (status != YYPUSH_MORE) {
      yypstate_delete(parserState);
      return status;
    }
  }
  REJECT;
}

\r?\n {
  /*
   * This rule will apply only to endlines that come after a statement.
   * Endlines associated with empty lines and comments are handled above.
   * This rule handles both Unix-style and Windows-style line endings.
   */
  // std::cout << "NEWLINE" << std::endl;
  
  int status = yypush_parse(parserState, NEWLINE, NULL );
  if (status != YYPUSH_MORE) {
    yypstate_delete(parserState);
    return status;
  }
}

<<EOF>> {
  /*
   * If we reach the end of the file, pop all indentation levels off the stack
   * and emit a DEDENT for each one.
   */
  while(_indent_stack.top() != 0) {
    _indent_stack.pop();
    // std::cout << "DEDENT" << std::endl;
    
    int status = yypush_parse(parserState, DEDENT, NULL);
    if (status != YYPUSH_MORE) {
      yypstate_delete(parserState);
      return status;
    }
  }
  yyterminate();
}

[ \t]  /* Ignore spaces that haven't been handled above. */

"and" {
  // std::cout << "AND\t\t" << yytext << std::endl;
  
  lexeme.str = new std::string(yytext, yyleng);
  int status = yypush_parse(parserState, AND, &lexeme );
  if (status != YYPUSH_MORE) {
    yypstate_delete(parserState);
    return status;
  }
}

"break" {
  // std::cout << "BREAK\t\t" << yytext << std::endl;
  
  lexeme.str = new std::string(yytext, yyleng);
  int status = yypush_parse(parserState, BREAK, &lexeme );
  if (status != YYPUSH_MORE) {
    yypstate_delete(parserState);
    return status;
  }
}

"def" {
  // std::cout << "DEF\t\t" << yytext << std::endl;
  
  lexeme.str = new std::string(yytext, yyleng);
  int status = yypush_parse(parserState, DEF, &lexeme );
  if (status != YYPUSH_MORE) {
    yypstate_delete(parserState);
    return status;
  }
}

"elif" {
  // std::cout << "ELIF\t\t" << yytext << std::endl;
  
  lexeme.str = new std::string(yytext, yyleng);
  int status = yypush_parse(parserState, ELIF, &lexeme );
  if (status != YYPUSH_MORE) {
    yypstate_delete(parserState);
    return status;
  }
}

"else" {
  // std::cout << "ELSE\t\t" << yytext << std::endl;
  
  lexeme.str = new std::string(yytext, yyleng);
  int status = yypush_parse(parserState, ELSE, &lexeme );
  if (status != YYPUSH_MORE) {
    yypstate_delete(parserState);
    return status;
  }
}

"for" {
  // std::cout << "FOR\t\t" << yytext << std::endl;
  
  lexeme.str = new std::string(yytext, yyleng);
  int status = yypush_parse(parserState, FOR, &lexeme );
  if (status != YYPUSH_MORE) {
    yypstate_delete(parserState);
    return status;
  }
}

"if" {
  // std::cout << "IF\t\t" << yytext << std::endl;
  
  lexeme.str = new std::string(yytext, yyleng);
  int status = yypush_parse(parserState, IF, &lexeme );
  if (status != YYPUSH_MORE) {
    yypstate_delete(parserState);
    return status;
  }
}

"not" {
  // std::cout << "NOT\t\t" << yytext << std::endl;
  
  lexeme.str = new std::string(yytext, yyleng);
  int status = yypush_parse(parserState, NOT, &lexeme );
  if (status != YYPUSH_MORE) {
    yypstate_delete(parserState);
    return status;
  }
}

"or" {
  // std::cout << "OR\t\t" << yytext << std::endl;
  
  lexeme.str = new std::string(yytext, yyleng);
  int status = yypush_parse(parserState, OR, &lexeme );
  if (status != YYPUSH_MORE) {
    yypstate_delete(parserState);
    return status;
  }
}

"return" {
  // std::cout << "RETURN\t\t" << yytext << std::endl;
  
  lexeme.str = new std::string(yytext, yyleng);
  int status = yypush_parse(parserState, RETURN, &lexeme );
  if (status != YYPUSH_MORE) {
    yypstate_delete(parserState);
    return status;
  }
}

"while" {
  // std::cout << "WHILE\t\t" << yytext << std::endl;
  
  lexeme.str = new std::string(yytext, yyleng);
  int status = yypush_parse(parserState, WHILE, &lexeme );
  if (status != YYPUSH_MORE) {
    yypstate_delete(parserState);
    return status;
  }
}

"True" {
  // std::cout << "BOOLEAN\t\t" << true << std::endl;
  
  lexeme.str = new std::string(yytext, yyleng);
  int status = yypush_parse(parserState, TRUE, &lexeme );
  if (status != YYPUSH_MORE) {
    yypstate_delete(parserState);
    return status;
  }
}

"False" {
  // std::cout << "BOOLEAN\t\t" << false << std::endl;
  
  lexeme.str = new std::string(yytext, yyleng);
  int status = yypush_parse(parserState, FALSE, &lexeme );
  if (status != YYPUSH_MORE) {
    yypstate_delete(parserState);
    return status;
  }
}

[a-zA-Z_][a-zA-Z0-9_]* {
  /*
   * This rule handling identifiers must come after all the keyword rules above,
   * since each keyword would otherwise be treated as a valid identifier.
   */
  // std::cout << "IDENTIFIER\t" << yytext << std::endl;
  
  lexeme.str = new std::string(yytext, yyleng);
  int status = yypush_parse(parserState, IDENTIFIER, &lexeme );
  if (status != YYPUSH_MORE) {
    yypstate_delete(parserState);
    return status;
  }
}

[0-9]*"."[0-9]+ {
  // std::cout << "FLOAT\t\t" << atof(yytext) << std::endl;
  
  lexeme.str = new std::string(yytext, yyleng);
  int status = yypush_parse(parserState, FLOAT, &lexeme );
  if (status != YYPUSH_MORE) {
    yypstate_delete(parserState);
    return status;
  }
}

[0-9]+ {
  // std::cout << "INTEGER\t\t" << atoi(yytext) << std::endl;
  
  lexeme.str = new std::string(yytext, yyleng);
  int status = yypush_parse(parserState, INTEGER, &lexeme );
  if (status != YYPUSH_MORE) {
    yypstate_delete(parserState);
    return status;
  }
}

"=" {
  // std::cout << "ASSIGN\t\t" << yytext << std::endl;
  
  lexeme.str = new std::string(yytext, yyleng);
  int status = yypush_parse(parserState, ASSIGN, &lexeme );
  if (status != YYPUSH_MORE) {
    yypstate_delete(parserState);
    return status;
  }
}

"+" {
  // std::cout << "PLUS\t\t" << yytext << std::endl;
  
  lexeme.str = new std::string(yytext, yyleng);
  int status = yypush_parse(parserState, PLUS, &lexeme );
  if (status != YYPUSH_MORE) {
    yypstate_delete(parserState);
    return status;
  }
}

"-" {
  // std::cout << "MINUS\t\t" << yytext << std::endl;
  
  lexeme.str = new std::string(yytext, yyleng);
  int status = yypush_parse(parserState, MINUS, &lexeme );
  if (status != YYPUSH_MORE) {
    yypstate_delete(parserState);
    return status;
  }
}

"*" {
  // std::cout << "TIMES\t\t" << yytext << std::endl;
  
  lexeme.str = new std::string(yytext, yyleng);
  int status = yypush_parse(parserState, TIMES, &lexeme );
  if (status != YYPUSH_MORE) {
    yypstate_delete(parserState);
    return status;
  }
}

"/" {
  // std::cout << "DIVIDEDBY\t" << yytext << std::endl;
  
  lexeme.str = new std::string(yytext, yyleng);
  int status = yypush_parse(parserState, DIVIDEDBY, &lexeme );
  if (status != YYPUSH_MORE) {
    yypstate_delete(parserState);
    return status;
  }
}

"==" {
  // std::cout << "EQ\t\t" << yytext << std::endl;
  
  lexeme.str = new std::string(yytext, yyleng);
  int status = yypush_parse(parserState, EQ, &lexeme );
  if (status != YYPUSH_MORE) {
    yypstate_delete(parserState);
    return status;
  }
}

"!=" {
  // std::cout << "NEQ\t\t" << yytext << std::endl;
  
  lexeme.str = new std::string(yytext, yyleng);
  int status = yypush_parse(parserState, NEQ, &lexeme );
  if (status != YYPUSH_MORE) {
    yypstate_delete(parserState);
    return status;
  }
}

">"  {
  // std::cout << "GT\t\t" << yytext << std::endl;
  
  lexeme.str = new std::string(yytext, yyleng);
  int status = yypush_parse(parserState, GT, &lexeme );
  if (status != YYPUSH_MORE) {
    yypstate_delete(parserState);
    return status;
  }
}

">=" {
  // std::cout << "GTE\t\t" << yytext << std::endl;
  
  lexeme.str = new std::string(yytext, yyleng);
  int status = yypush_parse(parserState, GTE, &lexeme );
  if (status != YYPUSH_MORE) {
    yypstate_delete(parserState);
    return status;
  }
}

"<" {
  // std::cout << "LT\t\t" << yytext << std::endl;
  
  lexeme.str = new std::string(yytext, yyleng);
  int status = yypush_parse(parserState, LT, &lexeme );
  if (status != YYPUSH_MORE) {
    yypstate_delete(parserState);
    return status;
  }
}

"<=" {
  // std::cout << "LTE\t\t" << yytext << std::endl;
  
  lexeme.str = new std::string(yytext, yyleng);
  int status = yypush_parse(parserState, LTE, &lexeme );
  if (status != YYPUSH_MORE) {
    yypstate_delete(parserState);
    return status;
  }
}

"(" {
  // std::cout << "LPAREN\t\t" << yytext << std::endl;
  
  lexeme.str = new std::string(yytext, yyleng);
  int status = yypush_parse(parserState, LPAREN, &lexeme );
  if (status != YYPUSH_MORE) {
    yypstate_delete(parserState);
    return status;
  }
}

")" {
  // std::cout << "RPAREN\t\t" << yytext << std::endl;
  
  lexeme.str = new std::string(yytext, yyleng);
  int status = yypush_parse(parserState, RPAREN, &lexeme );
  if (status != YYPUSH_MORE) {
    yypstate_delete(parserState);
    return status;
  }
}

"," {
  // std::cout << "COMMA\t\t" << yytext << std::endl;
  
  lexeme.str = new std::string(yytext, yyleng);
  int status = yypush_parse(parserState, COMMA, &lexeme );
  if (status != YYPUSH_MORE) {
    yypstate_delete(parserState);
    return status;
  }
}

":" {
  // std::cout << "COLON\t\t" << yytext << std::endl;
  
  lexeme.str = new std::string(yytext, yyleng);
  int status = yypush_parse(parserState, COLON, &lexeme );
  if (status != YYPUSH_MORE) {
    yypstate_delete(parserState);
    return status;
  }
}

. {
  std::cerr << "Unrecognized token on line " << yylineno << ": " << yytext
    << std::endl;
  // lexeme.str = std::string(yytext[0]);
  // yypush_parse(parserState, yytext[0], &lexeme);
}

%%

/*int main() {
  return yylex();
}*/