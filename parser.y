%{
    #include <iostream>
    #include <map>

    std::map<std::string, float> symbols;

    void yyerror(const char* err);
    extern int yylex();
%}
%define api.pure full
%define api.push-pull push
%define parse.error verbose
%union {
    std::string* str;
}

%token <str> IDENTIFIER
%token <str> INTEGER
%token <str> FLOAT
%token <str> COLON
%token <str> OPERATOR
%token <str> ASSIGN
%token <str> INDENT
%token <str> DEDENT
%token <str> IF
%token <str> ELIF
%token <str> ELSE
%token <str> LPAREN
%token <str> RPAREN
%token <str> NEWLINE
%token <str> WHILE
%token <str> PLUS
%token <str> MINUS
%token <str> TIMES
%token <str> DIVIDEDBY
%token <str> GT
%token <str> LT
%token <str> GTE
%token <str> LTE
%token <str> EQ
%token <str> NEQ
%token <str> BOOLEAN
%token <str> AND
%token <str> BREAK
%token <str> TRUE
%token <str> FALSE
%token <str> FOR
%token <str> NOT
%token <str> OR
%token <str> DEF
%token <str> RETURN
%token <str> COMMA

%type <str> expression
%type <str> assignmentStatement

%start program

%%

program
    : assignmentStatement
    ;

assignmentStatement
    : IDENTIFIER ASSIGN expression NEWLINE { 
        std::string new_string = "";
        new_string.append(*$1);
        new_string.append("=");
        new_string.append(*$2);
        new_string.append("\n");
        std::cout<<"ASSIGNMENT "<<*$1<<*$2<<*$3<<std::endl; $$ = &new_string; 
    } 
    ;
expression
    : IDENTIFIER { 
        std::cout<<"IDENTIFIER "<<*$1<<std::endl; $$ = *$1; 
    } 
    ;
%%

void yyerror(const char* err) {
    std::cerr << "Error: " << err << std::endl;
}

int main() {
    if (!yylex()) {
        std::map<std::string, float>::iterator it;
        for (it = symbols.begin(); it != symbols.end(); it++) {
            std::cout << it->first << " : " << it->second << std::endl;
        }
        return 0;
    } else {
        std::cout << "HERE"<< std::endl;
        return 1;
    }
}