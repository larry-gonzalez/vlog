%{
/* C++ string header, for string ops below */
#include <string>
#include <iostream>

/* Implementation of yyFlexScanner */
#include <parser/rulescanner.h>
#undef  YY_DECL
#define YY_DECL int MC::RuleScanner::yylex( MC::RuleParser::semantic_type * const lval, MC::RuleParser::location_type *loc)

/* typedef to make the returns for the tokens shorter */
using token = MC::RuleParser::token;

/* define yyterminate as this instead of NULL */
#define yyterminate() return( token::END )

/* msvc2010 requires that we exclude this header file. */
#define YY_NO_UNISTD_H

/* update location on matching */
#define YY_USER_ACTION loc->step(); loc->columns(yyleng);

%}

%option debug
%option nodefault
%option yyclass="MC::RuleScanner"
%option noyywrap
%option c++

 /* See https://github.com/dajobe/raptor/blob/master/src/turtle_lexer.l */
 /* Tokens from Turtle 2013 spec - lex-ifyed to remove unicode ranges */
 /* See https://www.w3.org/TR/rdf-sparql-query/ */

HEX [0-9A-Fa-f]
UCHAR "\\u"{HEX}{HEX}{HEX}{HEX}|"\\U"{HEX}{HEX}{HEX}{HEX}{HEX}{HEX}{HEX}{HEX}
IRIREF "<"([^\x00-\x20<>\"{}\|^`\\]|{UCHAR})*">"

Var {VAR1}|{VAR2}
VAR1 "?"{VARNAME}
VAR2 "$"{VARNAME}
VARNAME ({PN_CHARS_U}|[0-9])({PN_CHARS_U}|[0-9]|\u00B7|['\u0300'-'\u036F']|['\u203F'-'\u2040'])*
PN_CHARS_U {PN_CHARS_BASE}|"_" 
PN_CHARS_BASE [A-Z]|[a-z]|['\u00C0'-'\u00D6']|['\u00D8'-'\u00F6']|['\u00F8'-'\u02FF']|['\u0370'-'\u037D']|['\u037F'-'\u1FFF']|['\u200C'-'\u200D']|['\u2070'-'\u218F']|['\u2C00'-'\u2FEF']|['\u3001'-'\uD7FF']|['\uF900'-'\uFDCF']|['\uFDF0'-'\uFFFD']|['\u10000'-'\uEFFFF']

PN_CHARS {PN_CHARS_U}|'-'|[0-9]|'\u00B7'|['\u0300'-'\u036F']|['\u203F'-'\u2040']
PN_PREFIX {PN_CHARS_BASE}(({PN_CHARS}|'.')*{PN_CHARS})?
PNAME_NS {PN_PREFIX}?":"


%%

%{          /** Code executed at the beginning of yylex **/
            yylval = lval;
%}

@base {
    std::cout << "LEXER TOKEN: BASE" << std::endl;
    return(token::BASE);
}
@BASE {
    std::cout << "LEXER TOKEN: BASE" << std::endl;
    return(token::BASE);
}

@prefix {
    std::cout << "LEXER TOKEN: PREFIX" << std::endl;
    return(token::PREFIX);
}

@PREFIX {
    std::cout << "LEXER TOKEN: PREFIX" << std::endl;
    return(token::PREFIX);
}

@RULES {
    std::cout << "LEXER TOKEN: RULES" << std::endl;
    return(token::RULES);
}

@rules {
    std::cout << "LEXER TOKEN: RULES" << std::endl;
    return(token::RULES);
}

@FACTS {
    std::cout << "LEXER TOKEN: FACTS" << std::endl;
    return(token::FACTS);
}

@facts {
    std::cout << "LEXER TOKEN: FACTS" << std::endl;
    return(token::FACTS);
}

@QUERIES {
    std::cout << "LEXER TOKEN: QUERIES" << std::endl;
    return(token::QUERIES);
}

@queries {
    std::cout << "LEXER TOKEN: QUERIES" << std::endl;
    return(token::QUERIES);
}

{PNAME_NS} {
    std::cout << "LEXER PNAME_NS: " << yytext << std::endl;
    yylval->build< std::string >( yytext );
    return(token::PNAME_NS);
}

{IRIREF} {
    std::cout << "LEXER IRIREF: " << yytext << std::endl;
    yylval->build< std::string >( yytext );
    return(token::IRIREF);
}

{Var} {
    std::cout << "LEXER Var: " << yytext << std::endl;
    //by definition, no '?' nor '$' are part of the variable name
    std::string variable(yytext);
    yylval->build< std::string >( variable.substr(1,variable.length()) );
    return(token::VARIABLE);
}

neg\_ {
    std::cout << "LEXER TOKEN: NOT" << std::endl;
    return(token::NEGATE);
}
~     {
    std::cout << "LEXER TOKEN: NOT" << std::endl;
    return(token::NEGATE);
}

([a-z]|[A-Z])[a-zA-Z0-9]* {
    yylval->build< std::string >( yytext );
    std::cout << "LEXER WORD: " << yytext << std::endl;
    return(token::WORD);
}

\"([^\"\\\n\r]|\\[^\n\r])*\"   {
    yylval->build< std::string >( yytext );
    std::cout << "LEXER WORD: " << yytext << std::endl;
    return(token::WORD);
}

\( {
    std::cout << "LEXER TOKEN: LEFT PAR" << std::endl;
    return(token::LEFTPAR);
}

\) {
    std::cout << "LEXER TOKEN: RIGHT PAR" << std::endl;
    return(token::RIGHTPAR);
}

\. {
    std::cout << "LEXER TOKEN: POINT" << std::endl;
    return(token::POINT);
}

, {
    std::cout << "LEXER TOKEN: COMMA" << std::endl;
    return(token::COMMA);
}


:- {
    std::cout << "LEXER TOKEN: ARROW" << std::endl;
    return(token::ARROW);
}

\n+ {
    std::cout << "LEXER TOKEN: NEWLINE" << std::endl;
    return(token::NEWLINE);
}

[\ \t\v\r]+  {;}                              /*ignore spaces and tabs*/

. {
    std::cout << "Lexer ERROR. Unrecognized character: " << yytext << std::endl;
    std::exit(1);
}

\%[^\r\n]*(\r\n|\r|\n) { /* # comment */ }
\%[^\r\n]*             { /* # comment on the last line with no terminating newline */}
%%

