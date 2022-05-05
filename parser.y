%{
    #include <iostream>
    #include <map>

    std::map<std::string, std::string> symbols;

    void yyerror(const char* err);
    extern int yylex();
    std::string new_program = std::string("");
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

%type <str> terminal
%type <str> program

%start program

%%
program 
    : terminal NEWLINE {
        std::cout<<"statement"<<*$1<<std::endl;
        $$ = $1;
    }
    | terminal NEWLINE program {
        std::string * new_string = new std::string(*$1+*$2+*$3);
       std::cout<<"program statement"<<*$1<<*$2<<std::endl;
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
        std::cout<<new_program<<std::endl;
        return 0;
    } else {
        std::cout << "ERROR MAIN"<< std::endl;
        return 1;
    }
}
