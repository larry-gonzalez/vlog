%{
/* C++ string header, for string ops below */
#include <string>
#include <iostream>


std::string deletePrefixAndSufix(char *input, int prefixLength, int sufixLength) {
    std::string str = std::string(input);
    return str.substr(prefixLength, str.length()-prefixLength-sufixLength);
}
std::string deletePrefixAndSufix(std::string input, int prefixLength, int sufixLength) {
    return input.substr(prefixLength, input.length()-prefixLength-sufixLength);
}

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

UCHAR \\u{HEX}{HEX}{HEX}{HEX}|\\U{HEX}{HEX}{HEX}{HEX}{HEX}{HEX}{HEX}{HEX}
IRIREF <([^\x00-\x20<>\"{}\|^`\\]|{UCHAR})*>

Var {VAR1}|{VAR2}
VAR1 "?"{VARNAME}
VAR2 "$"{VARNAME}
VARNAME ({PN_CHARS_U}|[0-9])({PN_CHARS_U}|[0-9]|\u00B7|['\u0300'-'\u036F']|['\u203F'-'\u2040'])*
PN_CHARS_U {PN_CHARS_BASE}|"_" 
PN_CHARS_BASE [A-Z]|[a-z]|['\u00C0'-'\u00D6']|['\u00D8'-'\u00F6']|['\u00F8'-'\u02FF']|['\u0370'-'\u037D']|['\u037F'-'\u1FFF']|['\u200C'-'\u200D']|['\u2070'-'\u218F']|['\u2C00'-'\u2FEF']|['\u3001'-'\uD7FF']|['\uF900'-'\uFDCF']|['\uFDF0'-'\uFFFD']|['\u10000'-'\uEFFFF']

PN_CHARS {PN_CHARS_U}|'-'|[0-9]|'\u00B7'|['\u0300'-'\u036F']|['\u203F'-'\u2040']
PN_PREFIX {PN_CHARS_BASE}(({PN_CHARS}|'.')*{PN_CHARS})?
PNAME_NS {PN_PREFIX}?:

LANGTAG @[a-zA-Z]+(-[a-zA-Z0-9]+)*


 /*[17 turtle]*/
 /* String {STRING_LITERAL_QUOTE}|{STRING_LITERAL_SINGLE_QUOTE}|{STRING_LITERAL_LONG_SINGLE_QUOTE}|{STRING_LITERAL_LONG_QUOTE} */
 /*[135s turtle]*/
 /*iri {IRIREF}|{PrefixedName} */
 /*[22 turtle]*/
STRING_LITERAL_QUOTE \"([^\x22\x5C\xA\xD]|{ECHAR}|{UCHAR})*\"
 /*[23 turtle]*/
STRING_LITERAL_SINGLE_QUOTE \'([^\x27\x5C\xA\xD]|{ECHAR}|{UCHAR})*\'
 /*[24 turtle]*/
STRING_LITERAL_LONG_SINGLE_QUOTE '''((\'|\'\')?([^\'\\]|{ECHAR}|{UCHAR}))*'''
 /*[25 turtle]*/
STRING_LITERAL_LONG_QUOTE \"\"\"((\"|\"\")?([^\"\\]|{ECHAR}|{UCHAR}))*\"\"\"

 /*[159s turtle]*/
ECHAR \\[tbnrf\"'\\]
 /*[136s turtle]*/
 /*PrefixedName {PNAME_LN}|{PNAME_NS} */

 /*[140s turtle]*/
PNAME_LN {PNAME_NS}{PN_LOCAL}

 /*[168s turtle]*/
PN_LOCAL ({PN_CHARS_U}|:|[0-9]|{PLX})(({PN_CHARS}|\.|:|{PLX})*({PN_CHARS}|:|{PLX}))?
 /*[169s turtle]*/
PLX {PERCENT}|{PN_LOCAL_ESC}
 /*[170s turtle]*/
PERCENT %{HEX}{HEX}
 /*[171s turtle]*/
HEX [0-9]|[A-F]|[a-f]
 /*[172s turtle]*/
PN_LOCAL_ESC \\(_|~|.|-|!|$|&|'|\(|\)|\*|\+|,|;|=|\/|\?|#|@|%)

PREDNAME [a-zA-Z][a-zA-Z0-9]*


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

\'true\' {
    std::cout << "LEXER TOKEN: TRUE" << std::endl;
    return(token::TRUE);
}

\'false\' {
    std::cout << "LEXER TOKEN: TRUE" << std::endl;
    return(token::FALSE);
}

{STRING_LITERAL_LONG_QUOTE} {
    std::string str(yytext);
    std::cout << "LEXER TOKEN: STRING_LITERAL_LONG_QUOTE " << str << std::endl;
    str = deletePrefixAndSufix(str,3,3);
    std::cout << "LEXER TOKEN: STRING_LITERAL_LONG_QUOTE " << str << std::endl;
    yylval->build(str);
    return(token::STRING);
}

{STRING_LITERAL_LONG_SINGLE_QUOTE} {
    std::string str(yytext);
    std::cout << "LEXER TOKEN: STRING_LITERAL_LONG_SINGLE_QUOTE " << str << std::endl;
    str = deletePrefixAndSufix(str,3,3);
    std::cout << "LEXER TOKEN: STRING_LITERAL_LONG_SINGLE_QUOTE " << str << std::endl;
    yylval->build(str);
    return(token::STRING);
}

{STRING_LITERAL_QUOTE} {
    std::string str(yytext);
    std::cout << "LEXER TOKEN: STRING_LITERAL_QUOTE " << str << std::endl;
    str = deletePrefixAndSufix(str,1,1);
    std::cout << "LEXER TOKEN: STRING_LITERAL_QUOTE " << str << std::endl;
    yylval->build(str);
    return(token::STRING);
}

{STRING_LITERAL_SINGLE_QUOTE} {
    std::string str(yytext);
    std::cout << "LEXER TOKEN: STRING_LITERAL_SINGLE_QUOTE " << str << std::endl;
    str = deletePrefixAndSufix(str,1,1);
    std::cout << "LEXER TOKEN: STRING_LITERAL_SINGLE_QUOTE " << str << std::endl;
    yylval->build(str);
    return(token::STRING);
}

{IRIREF} {
    std::string str(yytext);
    std::cout << "LEXER IRIREF: " << str << std::endl;
    yylval->build(str);
    return(token::IRIREF);
}

{PNAME_LN} {
    std::string str(yytext);
    std::cout << "LEXER PNAME_LS: " << str << std::endl;
    yylval->build(str);
    return(token::PNAME_LN);
}

{PNAME_NS} {
    std::string str(yytext);
    std::cout << "LEXER PNAME_NS: " << str << std::endl;
    yylval->build(str);
    return(token::PNAME_NS);
}


{LANGTAG} {
    std::string str(yytext);
    std::cout << "LEXER LANGTAG: " << str << std::endl;
    yylval->build(str);
    return(token::LANGTAG);
}

{PREDNAME} {
    std::string str(yytext);
    std::cout << "LEXER PREDNAME: " << str << std::endl;
    yylval->build(str);
    return(token::PREDNAME);
}

{Var} {
    //by definition, no '?' nor '$' are part of the variable name
    std::string str(yytext);
    str = deletePrefixAndSufix(str,1,0);
    std::cout << "LEXER VARIABLE: " << str << std::endl;
    yylval->build(str);
    return(token::VARIABLE);
}

~ {
    std::cout << "LEXER TOKEN: NOT" << std::endl;
    return(token::NEGATE);
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

\^\^ {
    std::cout << "LEXER TOKEN: HATHAT" << std::endl;
    return(token::HATHAT);
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

