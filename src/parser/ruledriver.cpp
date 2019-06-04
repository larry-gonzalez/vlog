#include <cctype>
#include <fstream>
#include <cassert>

#include <parser/ruledriver.h>


void MC::RuleDriver::parse( std::string filename ) {
    assert( filename != "" );
    std::ifstream in_file( filename );
    parse_helper(in_file);
    return;
}

void MC::RuleDriver::parse( const char * filename ) {
    assert( filename != nullptr );
    std::ifstream in_file( filename );
    parse_helper(in_file);
    return;
}


void MC::RuleDriver::parse( std::istream &stream ) {
    if( ! stream.good()  && stream.eof() ) {
        return;
    }
    //else
    parse_helper( stream );
    return;
}


void MC::RuleDriver::parse_helper( std::istream &stream ) {
    delete(scanner);
    try {
       scanner = new MC::RuleScanner( &stream );
    }
    catch( std::bad_alloc &ba ) {
       std::cerr << "Failed to allocate scanner: (" <<
          ba.what() << "), exiting!!\n";
       exit( EXIT_FAILURE );
    }
    delete(parser);
    try {
       parser = new MC::RuleParser( (*scanner) /* scanner */,
                                   (*this) /* driver */ );
    }
    catch( std::bad_alloc &ba ) {
       std::cerr << "Failed to allocate parser: (" <<
          ba.what() << "), exiting!!\n";
       exit( EXIT_FAILURE );
    }
    const int accept( 0 );
    if( parser->parse() != accept ) {
       std::cerr << "Parse failed!!\n";
    }
    return;
}


void MC::RuleAST::print(int sep/*=0*/){
    print_indented("type: "  + type, sep);
    print_indented("first value: " + firstValue, sep);
    print_indented("second value: " + secondValue, sep);
    print_indented("first AST: ", sep);
    if (firstAST != NULL)
        firstAST->print(sep+4);
    else
        std::cout << std::endl;
    print_indented("second AST: ", sep);
    if (secondAST != NULL)
        secondAST->print(sep+4);
    else
        std::cout << std::endl;
}


void MC::RuleAST::print_indented(std::string to_indent, int spaces) {
    std::string ret = "";
    for (int i = 0; i < spaces; i++ )
        ret += " ";
    ret += to_indent;
    std::cout << ret << std::endl;
}


MC::RuleAST::~RuleAST() {
    if (firstAST !=NULL)
        delete(firstAST);
    if (secondAST !=NULL)
        delete(secondAST);
}

std::string MC::RuleAST::getType(){
    return type;
}

std::string MC::RuleAST::getFirstValue(){
    return firstValue;
}

std::string MC::RuleAST::getSecondValue(){
    return secondValue;
}

MC::RuleAST *MC::RuleAST::getFirstAST(){
    return firstAST;
}

MC::RuleAST *MC::RuleAST::getSecondAST(){
    return secondAST;
}
