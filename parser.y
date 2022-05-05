%{
    #include <iostream>
    #include <map>

    std::map<std::string, std::string> symbols;

    void yyerror(const char* err);
    extern int yylex();
    std::string * new_program = new std::string("");
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

%type <str> op
%type <str> terminal
%type <str> math
%type <str> expression
%type <str> condition
%type <str> comparison
%type <str> program
%type <str> statement
%type <str> assignmentStatement
%type <str> conditionalStatement
%type <str> elifStatement
%type <str> elseStatement
%type <str> whileStatement

%start program

%%
program
   : statement program{
       std::string * new_string = new std::string("");
       *new_string = *$1 + *$2;
       *new_program =*new_program +  *new_string;
       std::cout<<"program statement"<<*$1<<*$2<<std::endl;
       $$ = new_string;
   }
    | statement {
       std::string * new_string = new std::string("");
        *new_string = *$1;
       *new_program =*new_program +  *new_string;
        std::cout<<"statement"<<*$1<<std::endl;
        $$ = new_string;
    }
    ;
conditionalStatement
    : IF condition COLON NEWLINE INDENT program DEDENT elifStatement{
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
        $$ = new_string;
    }
    ;
elifStatement
    : ELIF condition COLON NEWLINE INDENT program DEDENT elifStatement{
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
    : ELSE COLON NEWLINE INDENT program DEDENT{
        std::string * new_string = new std::string("");
        *new_string = "else {\n" + *$5 +"}\n";
        $$ = new_string;
    }
    ;
statement
//   : statement assignmentStatement {
//       std::string * new_string = new std::string();
//       *new_string = *$1 + *$2;
//      $$ = new_string;
//   }
//   | statement conditionalStatement{
//       std::string * new_string = new std::string();
//       *new_string = *$1 + *$2;
//        std::cout<<"PRINT COND1"<< *$1 << *$2<<std::endl;
//
//       $$ = new_string;
//   }
//   | statement whileStatement{
//       std::string * new_string = new std::string();
//       *new_string = *$1 + *$2;
//       $$ = new_string;
//   }
    : conditionalStatement{
        std::string * new_string = new std::string(*$1);
        $$ = new_string;
    }
    | assignmentStatement{
        std::string * new_string = new std::string(*$1);
        std::cout<<"ASSIGNMENT"<<*new_string<<std::endl;
        $$ = new_string;
    }
    | whileStatement{
        std::string * new_string = new std::string(*$1);
        $$ = new_string;
    }
    | BREAK NEWLINE{
        std::string * new_string = new std::string("break;");
        $$ = new_string;
    }
    ;
whileStatement
    : WHILE condition COLON NEWLINE INDENT program DEDENT{
        std::string * new_string = new std::string();
        *new_string = "while(" + *$2 + "){\n" + *$6 +"}";
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
        std::cout<<"ASSIGNMENT "<<*new_string<<std::endl;
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
        std::string * new_string = new std::string(*$1);
        $$ = new_string;
    }
    | FALSE {
        std::string * new_string = new std::string(*$1);
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
}

int main() {
    if (!yylex()) {
        std::cout << "MAIN"<< std::endl;
        std::map<std::string, std::string>::iterator it;
        for (it = symbols.begin(); it != symbols.end(); it++) {
            std::cout <<"double "<< it->first << ";" << std::endl;
        }
        std::cout<<*new_program<<std::endl;
        return 0;
    } else {
        std::cout << "ERROR MAIN"<< std::endl;
        return 1;
    }
}
