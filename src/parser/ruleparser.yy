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

    #undef yylex
    #define yylex scanner.yylex

    void printAndExit(std::string error){
        std::cerr << "    " << error << std::endl;
        exit(1);
    }
}

%define api.value.type variant
%define parse.assert

%token               END       0  "end of file"
%token               BASE
%token               PREFIX

%token               RULES
%token               FACTS
%token               QUERIES

%token <std::string> STRING
%token <std::string> VARIABLE
%token <std::string> IRIREF
%token <std::string> PNAME_NS
%token <std::string> PNAME_LN
%token <std::string> LANGTAG
%token <std::string> PREDNAME

%token               TRUE
%token               FALSE
%token               LEFTPAR
%token               RIGHTPAR
%token               POINT
%token               COMMA
%token               ARROW
%token               NEWLINE
%token               NEGATE
%token               HATHAT

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
%type <MC::RuleAST*> iri
%type <MC::RuleAST*> predname
%type <MC::RuleAST*> variable
%type <MC::RuleAST*> base
%type <MC::RuleAST*> prefix
%type <MC::RuleAST*> rdf_literal

%locations



%%
list_of_sections : section                          { $$ = new MC::RuleAST("LISTOFSECTIONS",    "", "", $1,   NULL);  driver.set_root($$);}
                 | section list_of_sections         { $$ = new MC::RuleAST("LISTOFSECTIONS",    "", "", $1,   $2  );  driver.set_root($$);}
                 | %empty                           {printAndExit("Rule File seems to be empty.");};

section : base                                      { $$ = new MC::RuleAST("BASEDEFINITION",     "", "", $1,   NULL);}
        | prefix                                    { $$ = new MC::RuleAST("PREFIXDEFINITION",   "", "", $1, NULL);}
        | RULES   NEWLINE list_of_rules             { $$ = new MC::RuleAST("RULESECTION",       "", "", $3,   NULL);}
        | FACTS   NEWLINE list_of_facts             { $$ = new MC::RuleAST("FACTSECTION",       "", "", $3,   NULL);}
        | QUERIES NEWLINE list_of_queries           { $$ = NULL;};

base: BASE IRIREF POINT NEWLINE                     { $$ = new MC::RuleAST("BASE",       $2,     "", NULL,   NULL);}
    | BASE NEWLINE                                  { yyerrok; printAndExit("Bad base definition syntax. IRIREF and point expected.");}
    | BASE POINT NEWLINE                            { yyerrok; printAndExit("Bad base definition syntax. IRIREF expected.");}
    | BASE IRIREF NEWLINE                           { yyerrok; printAndExit("Bad base definition syntax. Point expected.");};

prefix: PREFIX PNAME_NS IRIREF POINT NEWLINE        { $$ = new MC::RuleAST("PREFIX",       $2,  $3, NULL,   NULL);}
      | PREFIX NEWLINE                              { yyerrok; printAndExit("Bad prexif definition syntax. Use: PREFIX PNAME_NS IRIREF POINT NEWLINE.");}
      | PREFIX PNAME_NS NEWLINE                     { yyerrok; printAndExit("Bad prexif definition syntax. Use: PREFIX PNAME_NS IRIREF POINT NEWLINE.");}
      | PREFIX IRIREF NEWLINE                       { yyerrok; printAndExit("Bad prexif definition syntax. Use: PREFIX PNAME_NS IRIREF POINT NEWLINE.");}
      | PREFIX POINT NEWLINE                        { yyerrok; printAndExit("Bad prexif definition syntax. Use: PREFIX PNAME_NS IRIREF POINT NEWLINE.");}
      | PREFIX IRIREF POINT NEWLINE                 { yyerrok; printAndExit("Bad prexif definition syntax. Use: PREFIX PNAME_NS IRIREF POINT NEWLINE.");}
      | PREFIX PNAME_NS POINT NEWLINE               { yyerrok; printAndExit("Bad prexif definition syntax. Use: PREFIX PNAME_NS IRIREF POINT NEWLINE.");}
      | PREFIX PNAME_NS IRIREF NEWLINE              { yyerrok; printAndExit("Bad prexif definition syntax. Use: PREFIX PNAME_NS IRIREF POINT NEWLINE.");};

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

positive_literal : iri LEFTPAR list_of_terms RIGHTPAR        { $$ = new MC::RuleAST("POSITIVELITERAL",    "", "",  $1, $3); }
                 | predname LEFTPAR list_of_terms RIGHTPAR   { $$ = new MC::RuleAST("POSITIVELITERAL",    "", "",  $1, $3); };

negative_literal : NEGATE iri LEFTPAR list_of_terms RIGHTPAR      { $$ = new MC::RuleAST("NEGATIVELITERAL",    "", "",  $2, $4); }
                 | NEGATE predname LEFTPAR list_of_terms RIGHTPAR { $$ = new MC::RuleAST("NEGATIVELITERAL",    "", "",  $2, $4); };

list_of_terms : term                                 { $$ = new MC::RuleAST("LISTOFTERMS",    "", "", $1, NULL); }
              | term COMMA list_of_terms             { $$ = new MC::RuleAST("LISTOFTERMS",    "", "", $1, $3); };

term : iri                                           { $$ = new MC::RuleAST("TERM",      "", "", $1, NULL); }
     | rdf_literal                                   { $$ = new MC::RuleAST("TERM",      "", "", $1, NULL); }
     | variable                                      { $$ = new MC::RuleAST("TERM",      "", "", $1, NULL); }
     | error                                         { yyerrok;  printAndExit("Term is not valid"); };

/* FACTS */
list_of_facts : fact                                 { $$ = new MC::RuleAST("LISTOFFACTS", "", "", $1, NULL); }
              | fact list_of_facts                   { $$ = new MC::RuleAST("LISTOFFACTS", "", "", $1, $2); }
              | %empty                               { $$ = NULL; };

fact : iri LEFTPAR list_of_ground_terms RIGHTPAR POINT NEWLINE      { $$ = new MC::RuleAST("FACT",     "", "", $1,   $3); }
     | error                                                        { yyerrok;  printAndExit("Not valid fact."); };


list_of_ground_terms : ground_term                             { $$ = new MC::RuleAST("LISTOFTERMS",    "", "", $1, NULL); }
                     | ground_term COMMA list_of_ground_terms  { $$ = new MC::RuleAST("LISTOFTERMS",    "", "", $1, $3); }
                     | error                                   { yyerrok;  printAndExit("Not valid list of ground terms."); };

ground_term : iri                                              { $$ = new MC::RuleAST("TERM",      "", "", $1, NULL); }
            | rdf_literal                                      { $$ = new MC::RuleAST("TERM",      "", "", $1, NULL); }
            | error                                            { yyerrok;  printAndExit("Not valid ground term."); };

 /* Queries */
list_of_queries : query                                        { printAndExit("Queries not implemented yet.");}
                | query list_of_queries                        { printAndExit("Queries not implemented yet.");}
                | %empty                                       { printAndExit("Queries not implemented yet.");};

query : positive_literal                                       { printAndExit("Queries not implemented yet.");};

 /* RDFLiteral */
rdf_literal : STRING                                            { $$ = new MC::RuleAST("RDFLITERAL", $1, "", NULL, NULL); }
            | STRING LANGTAG                                    { $$ = new MC::RuleAST("RDFLITERAL", $1, $2, NULL, NULL); }
            | STRING HATHAT iri                                 { $$ = new MC::RuleAST("RDFLITERAL", $1, "", $3,   NULL); };

 /* iris */
iri : IRIREF                                                   { $$ = new MC::RuleAST("IRI",      $1, "", NULL, NULL); }
    | PNAME_NS                                                 { $$ = new MC::RuleAST("IRI",      $1, "", NULL, NULL); }
    | PNAME_LN                                                 { $$ = new MC::RuleAST("IRI",      $1, "", NULL, NULL); };

variable: VARIABLE                                             { $$ = new MC::RuleAST("VARIABLE",      $1, "", NULL, NULL); };
predname: PREDNAME                                             { $$ = new MC::RuleAST("PREDNAME",      $1, "", NULL, NULL); };

%%

/*There is a bug in the line number.*/
void MC::RuleParser::error( const location_type &l, const std::string &err_message ) {
   //std::cerr << "Parser Error: " << err_message << " at " << l << "\n";
   std::cerr << "Parser Error: " << std::endl;
   std::cerr << "Parser Error: " << err_message << std::endl;
}


