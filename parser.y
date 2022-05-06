%{
    #include <iostream>
    #include <map>
  #include "parser.hpp"

    std::map<std::string, std::string> symbols;

    void yyerror(const char* err);
    extern int yylex();
    std::string new_program = "";
    std::string lastSymbol = "";
%}
%define api.push-pull push
%define api.pure full
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
%token <str> ERROR

%type <str> test
%type <str> comparison
%type <str> op
%type <str> terminal
%type <str> math
%type <str> expression
%type <str> assignmentStatement
%type <str> elseStatement
%type <str> elifStatement
%type <str> conditionalStatement
%type <str> whileStatement
%type <str> condition
%type <str> program
%type <str> buffer




%%
program
    : buffer {
        new_program += $1 ? *$1 : "" ;
    }
    ;
buffer
    : {$$=NULL;}
    | program test {
        std::string string = $1 ? *$1 : "NONE";
        //std::cout<<"HERE"<<string<<$2<<std::endl;
      $$ = $2;
    }
    ;
test
    : assignmentStatement
    | conditionalStatement
    | whileStatement
    ;
whileStatement
    : WHILE condition COLON NEWLINE INDENT assignmentStatement assignmentStatement assignmentStatement assignmentStatement conditionalStatement DEDENT{
        std::string * new_string = new std::string();
        *new_string = "while(" + *$2 + "){\n" + *$6 + *$7+ *$8+ *$9 + *$10 + "\n}\n";
        $$ = new_string;
    }
    ;
conditionalStatement
    : IF condition COLON NEWLINE INDENT assignmentStatement DEDENT elifStatement{
        std::string * new_string = new std::string("");
        std::string temp = "";
        std::string temp2 = "";
        if($8 != 0){
            temp = *$8;
        }
        if($6 != 0){
            temp2 = *$6;
        }
        *new_string = "if(" + *$2 + "){\n" + temp2 +"}\n" + temp;
      //  std::cout<<"COND "<< *new_string<<std::endl;
        $$ = new_string;
    }
    | IF condition COLON NEWLINE INDENT assignmentStatement conditionalStatement DEDENT elifStatement{
        std::string * new_string = new std::string("");
        std::string temp = "";
        std::string temp2 = "";
        std::string temp3 = "";
        if($9 != 0){
            temp = *$9;
        }
        if($6 != 0){
            temp2 = *$6;
        }
        if($7 != 0){
            temp3 = *$7;
        }
        *new_string = "if(" + *$2 + "){\n" + temp2 + temp3 + "}\n"+  temp;
     //   std::cout<<"COND2 "<< *new_string<<std::endl;

        $$ = new_string;
    }
    | IF condition COLON NEWLINE INDENT BREAK NEWLINE DEDENT{
        std::string * new_string = new std::string("");
        std::string temp = "";
        std::string temp2 = "";
        std::string temp3 = "";
        *new_string = "if(" + *$2 + "){\n" + "break;\n" + "}";
     //   std::cout<<"COND3 "<< *new_string<<std::endl;

        $$ = new_string;
    }
    ;
elifStatement
    : ELIF condition COLON NEWLINE INDENT assignmentStatement DEDENT elifStatement{
        std::string * new_string = new std::string("");
        std::string * new_string_piece = new std::string("");
        if($8 != 0){ *new_string_piece = *$8;}
        *new_string = "else if(" + *$2 + "){\n" + *$6 +"}\n" + *new_string_piece;
        $$ = new_string;
    }
    | {$$ = 0;}
    | elseStatement {
        std::string * new_string = new std::string(*$1);
        $$ = new_string;
    }
    ;
elseStatement
    : ELSE COLON NEWLINE INDENT assignmentStatement DEDENT{
        std::string * new_string = new std::string("");
        *new_string = "else {\n" + *$5 +"}\n";
        $$ = new_string;
    }
    ;
condition
    : terminal comparison terminal {
        std::string * new_string = new std::string("");
        *new_string = *$1 + *$2 + *$3;
        $$ = new_string;
    }
    | terminal op terminal comparison terminal{
        std::string * new_string = new std::string("");
        *new_string = *$1 + *$2 + *$3 + *$4 + *$5;
        $$ = new_string;
    }
    | terminal{
        std::string * new_string = new std::string("");
        *new_string = *$1;
        $$ = new_string;
    }
    ;

assignmentStatement
    : IDENTIFIER ASSIGN expression NEWLINE {
        std::string * new_string = new std::string("");
        *new_string = *$1 + "=" + *$3 + ";" + "\n";
        symbols[*$1] = *$1;
        lastSymbol = *$1;
        $$ = new_string;
    }
    ;
expression
    : math{
        std::string * new_string = new std::string(*$1);
        $$ = new_string;
    }
    ;
math
    : math op terminal{
        std::string * new_string = new std::string();
        *new_string = *$1 + *$2 + *$3;
        $$ = new_string;
    }
    | terminal{
        std::string * new_string = new std::string(*$1);
        $$ = new_string;
    }
    | LPAREN math RPAREN {
        std::string * new_string = new std::string();
        *new_string = "(" + *$2 + ")";
        $$ = new_string;
    }
    ;

terminal
    : IDENTIFIER {
        std::string * new_string = new std::string(*$1);
        symbols[*$1] = *$1;
        lastSymbol = *$1;
        $$ = new_string;
    }
    | FLOAT {
        std::string * new_string = new std::string(*$1);
        $$ = new_string;
    }
    | INTEGER {
        std::string * new_string = new std::string(*$1);
        $$ = new_string;
    }
    | TRUE {
        std::string * new_string = new std::string("true");
        $$ = new_string;
    }
    | FALSE {
        std::string * new_string = new std::string("false");
        $$ = new_string;
    }
    ;
op
    : PLUS {
        std::string * new_string = new std::string(*$1);
        $$ = new_string;
    }
    | MINUS {
        std::string * new_string = new std::string(*$1);
        $$ = new_string;
    }
    | TIMES {
        std::string * new_string = new std::string(*$1);
        $$ = new_string;
    }
    | DIVIDEDBY {
        std::string * new_string = new std::string(*$1);
        $$ = new_string;
    }
    ;
comparison
    : GT {
        std::string * new_string = new std::string(">");
        $$ = new_string;
    }
    | GTE {
        std::string * new_string = new std::string(">=");
        $$ = new_string;
    }
    | LT {
        std::string * new_string = new std::string("<");
        $$ = new_string;
    }
    | LTE {
        std::string * new_string = new std::string("<=");
        $$ = new_string;
    }
    | EQ {
        std::string * new_string = new std::string("==");
        $$ = new_string;
    }
    | NEQ {
        std::string * new_string = new std::string("!=");
        $$ = new_string;
    }
    ;
%%

void yyerror(const char* err) {
    std::cerr << "Error: " << err << std::endl;
    exit(1);
}

int main() {
    if (!yylex()) {
   //     std::cout << "MAIN"<< std::endl;
        std::string main_string = "#include <iostream>\n#include <cmath>\nint main() {\n";
        std::cout << main_string << std::endl;

        std::map<std::string, std::string>::iterator it;
        for (it = symbols.begin(); it != symbols.end(); it++) {
            std::cout <<"double "<< it->first << ";" << std::endl;
        }
        std::cout<<new_program<<std::endl;
        std::cout<<"std::cout  <<\""<< lastSymbol << ": \"<<" << lastSymbol <<"<<std::endl;\n" << std::endl;
        std::cout<<"}"<<std::endl;
        return 0;
    } else {
        std::cout << "ERROR MAIN"<< std::endl;
        return 1;
    }
}
