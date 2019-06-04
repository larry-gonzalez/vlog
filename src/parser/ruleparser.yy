%skeleton "lalr1.cc"
%require  "3.0"
%debug 
%defines 
%define api.namespace {MC}
%define parser_class_name {RuleParser}

%code requires{
   namespace MC {
      class RuleAST;
      class RuleDriver;
      class RuleScanner;
   }

// The following definitions is missing when %locations isn't used
# ifndef YY_NULLPTR
#  if defined __cplusplus && 201103L <= __cplusplus
#   define YY_NULLPTR nullptr
#  else
#   define YY_NULLPTR 0
#  endif
# endif

}

%parse-param { RuleScanner &scanner }
%parse-param { RuleDriver  &driver  }

%code{
   #include <iostream>
   #include <cstdlib>
   #include <fstream>
   
   /* include for all driver functions */
   #include <parser/ruledriver.h>
   void print_error_and_exit(std::string error){
      std::cerr << "              " << error << std::endl;
      exit(1);
   }

#undef yylex
#define yylex scanner.yylex
}

%define api.value.type variant
%define parse.assert

%token               END       0  "end of file"
%token <std::string> UPPERWORD
%token <std::string> LOWERWORD
%token <std::string> WORD 
%token               RULES
%token               FACTS
%token               QUERIES
%token <std::string> VARIABLE
%token               LEFTPAR
%token               RIGHTPAR
%token               POINT
%token               COMMA
%token               ARROW
%token               NEWLINE
%token               BASE
%token               PREFIX
%token               NEGATE
%token <std::string> IRIREF
%token <std::string> PNAME_NS

%type <MC::RuleAST*> list_of_sections
%type <MC::RuleAST*> section
%type <MC::RuleAST*> list_of_rules
%type <MC::RuleAST*> list_of_facts
%type <MC::RuleAST*> list_of_queries
%type <MC::RuleAST*> rule
%type <MC::RuleAST*> head_literals
%type <MC::RuleAST*> body_literals
%type <MC::RuleAST*> positive_literal
%type <MC::RuleAST*> negative_literal
%type <MC::RuleAST*> term
%type <MC::RuleAST*> list_of_terms
%type <MC::RuleAST*> ground_term
%type <MC::RuleAST*> list_of_ground_terms
%type <MC::RuleAST*> fact


%locations

%%
list_of_sections : section                  { $$ = new MC::RuleAST("LISTOFSECTIONS",    "", "", $1,   NULL);  driver.set_root($$);}
                 | section list_of_sections { $$ = new MC::RuleAST("LISTOFSECTIONS",    "", "", $1,   $2  );  driver.set_root($$);};

section : BASE IRIREF POINT NEWLINE                 { $$ = new MC::RuleAST("BASE",       $2,     "", NULL,   NULL);}
        | PREFIX PNAME_NS IRIREF POINT NEWLINE      { $$ = new MC::RuleAST("PREFIX",     $2,    $3,  NULL,   NULL);}
        | RULES   NEWLINE list_of_rules             { $$ = new MC::RuleAST("RULESECTION",       "", "", $3,   NULL);}
        | FACTS   NEWLINE list_of_facts             { $$ = new MC::RuleAST("FACTSECTION",       "", "", $3,   NULL);}
        | QUERIES NEWLINE list_of_queries           { $$ = NULL;};

/* RULES */
list_of_rules : rule                                { $$ = new MC::RuleAST("LISTOFRULES",    "",  "", $1,   NULL); }
              | rule list_of_rules                  { $$ = new MC::RuleAST("LISTOFRULES",    "", "", $1,   $2  ); }
              | %empty                              { $$ = NULL; };

rule : head_literals ARROW body_literals POINT NEWLINE { $$ = new MC::RuleAST("RULE",        "",  "", $1,   $3  );}
     | head_literals ARROW body_literals NEWLINE       { std::cerr << "rule error: missing point."; exit(1);}

 /* list of positive literals*/
head_literals : positive_literal                     { $$ = new MC::RuleAST("LISTOFLITERALS", "", "", $1,   NULL); }
              | positive_literal COMMA head_literals { $$ = new MC::RuleAST("LISTOFLITERALS", "", "", $1,   $3  ); };

 /* list of positive or negative literals*/
body_literals : positive_literal                     { $$ = new MC::RuleAST("LISTOFLITERALS", "", "", $1,   NULL); }
              | negative_literal                     { $$ = new MC::RuleAST("LISTOFLITERALS", "", "", $1,   NULL); }
              | positive_literal COMMA body_literals { $$ = new MC::RuleAST("LISTOFLITERALS", "", "", $1,   $3  ); }
              | negative_literal COMMA body_literals { $$ = new MC::RuleAST("LISTOFLITERALS", "", "", $1,   $3  ); };

positive_literal : WORD LEFTPAR list_of_terms RIGHTPAR      { $$ = new MC::RuleAST("POSITIVELITERAL",     $1, "", $3,   NULL); } 
                 | IRIREF LEFTPAR list_of_terms RIGHTPAR    { $$ = new MC::RuleAST("POSITIVELITERAL",     $1, "", $3,   NULL); }
                 | error                                    { yyerrok;  print_error_and_exit("Not valid positive literal."); };

negative_literal : NEGATE WORD LEFTPAR list_of_terms RIGHTPAR   { $$ = new MC::RuleAST("NEGATIVELITERAL",     $2, "", $4,   NULL); }
                 | NEGATE IRIREF LEFTPAR list_of_terms RIGHTPAR { $$ = new MC::RuleAST("NEGATIVELITERAL",     $2, "", $4,   NULL); }
                 | error                                        { yyerrok;  print_error_and_exit("Not valid negative literal."); };

list_of_terms : term                                 { $$ = new MC::RuleAST("LISTOFTERMS",    "", "", $1, NULL); }
              | term COMMA list_of_terms             { $$ = new MC::RuleAST("LISTOFTERMS",    "", "", $1, $3); }
              | error                                { yyerrok;  print_error_and_exit("Not valid list of terms."); };

term : WORD                                          { $$ = new MC::RuleAST("WORD",        $1, "", NULL, NULL); }
     | IRIREF                                        { $$ = new MC::RuleAST("IRIREF",      $1, "", NULL, NULL); }
     | VARIABLE                                      { $$ = new MC::RuleAST("VARIABLE",    $1, "", NULL, NULL); }
     | error                                         { yyerrok;  print_error_and_exit("Term is not valid"); };

/* FACTS */
list_of_facts : fact                                { $$ = new MC::RuleAST("LISTOFFACTS", "", "", $1, NULL); }
              | fact list_of_facts                  { $$ = new MC::RuleAST("LISTOFFACTS", "", "", $1, $2); }
              | %empty                              { $$ = NULL; };

fact : WORD   LEFTPAR list_of_ground_terms RIGHTPAR POINT NEWLINE   { $$ = new MC::RuleAST("FACT",     $1, "", $3,   NULL); } 
     | IRIREF LEFTPAR list_of_ground_terms RIGHTPAR POINT NEWLINE   { $$ = new MC::RuleAST("FACT",     $1, "", $3,   NULL); }
     | error                                           { yyerrok;  print_error_and_exit("Not valid fact."); };


list_of_ground_terms : ground_term                             { $$ = new MC::RuleAST("LISTOFTERMS",    "", "", $1, NULL); }
                     | ground_term COMMA list_of_ground_terms  { $$ = new MC::RuleAST("LISTOFTERMS",    "", "", $1, $3); }
                     | error                                   { yyerrok;  print_error_and_exit("Not valid list of ground terms."); };

ground_term : WORD                                           { $$ = new MC::RuleAST("WORD",        $1, "", NULL, NULL); }
            | IRIREF                                         { $$ = new MC::RuleAST("IRIREF",      $1, "", NULL, NULL); }
            | error                                          { yyerrok;  print_error_and_exit("Not valid ground term."); };



 /* QUERIES */
list_of_queries : query                             { }
                | query list_of_queries             { }
                | %empty                            { };

query : positive_literal { };

%%


/*There is a bug in the line number.*/
void MC::RuleParser::error( const location_type &l, const std::string &err_message ) {
   //std::cerr << "Parser Error: " << err_message << " at " << l << "\n";
   std::cerr << "Parser Error: " << std::endl;
   std::cerr << "Parser Error: " << err_message << std::endl;
}

