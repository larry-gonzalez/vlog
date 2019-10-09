#define CATCH_CONFIG_MAIN  // This tells Catch to provide a main() - only do this in one cpp file
#include <catch.hpp>
#include <vlog/concepts.h>


// VTerm

TEST_CASE(""){
    VTerm t1(-1,-1);
}

TEST_CASE("VTerm isVariable") {
    //remember, id==0 => constant, id!=0 => variable
    //do we need a method isConstant? what about other data types?
    VTerm t1(0,1);
    REQUIRE(!t1.isVariable());
    VTerm t2(1,1);
    REQUIRE(t2.isVariable());
}

TEST_CASE("VTerm getValue - setValue") {
    VTerm t1(0,1);
    REQUIRE(t1.getValue()==1);
    t1.setValue(5);
    REQUIRE(t1.getValue()==5);
    t1.setValue(10);
    REQUIRE(t1.getValue()==10);
}

TEST_CASE("VTerm getId - setId"){
    VTerm t1(0,1);
    REQUIRE(t1.getId()==0);
    t1.setId(1);
    REQUIRE(t1.getId()==1);
    t1.setId(10);
    REQUIRE(t1.getId()==10);
}

TEST_CASE("VTerm == and != operators") {
    VTerm t1(0,0);
    VTerm t2(0,0);
    VTerm t3(0,1);
    VTerm t4(1,0);
    VTerm t5(1,1);
    REQUIRE(t1==t1);
    REQUIRE(t1==t2);
    REQUIRE(t1!=t3);
    REQUIRE(t1!=t4);
    REQUIRE(t1!=t5);
    REQUIRE(t2==t1);
    REQUIRE(t2==t2);
    REQUIRE(t2!=t3);
    REQUIRE(t2!=t4);
    REQUIRE(t2!=t5);
}

// VTuple
TEST_CASE("VTuple size") {
    VTuple tuple(5);
    REQUIRE(tuple.getSize()==5);
}

TEST_CASE("VTuple == operator") {
    VTuple tuple1(3);
    VTuple tuple2(tuple1);
    REQUIRE(tuple1==tuple2);
    REQUIRE(tuple2==tuple1);

    VTerm t1(0,0);
    tuple1.set(t1,0);
    VTuple tuple3(tuple1);
    REQUIRE(tuple1==tuple3);
    REQUIRE(tuple3==tuple1);

    VTerm t2(0,0);
    tuple1.set(t2,1);
    VTuple tuple4(tuple1);
    REQUIRE(tuple1==tuple4);
    REQUIRE(tuple4==tuple1);

    VTerm t3(0,1);
    tuple1.set(t3,2);
    VTuple tuple5(tuple1);
    REQUIRE(tuple1==tuple5);
    REQUIRE(tuple5==tuple1);
}

TEST_CASE("VTuple get - set") {
    VTerm t1(0,0);
    VTerm t2(0,0);
    VTerm t3(0,1);
    VTerm t4(1,0);
    VTerm t5(1,1);
    VTuple tuple1(5);
    tuple1.set(t1,0);
    tuple1.set(t2,1);
    tuple1.set(t3,2);
    tuple1.set(t4,3);
    tuple1.set(t5,4);
    REQUIRE(tuple1.get(0)==t1);
    REQUIRE(tuple1.get(1)==t2);
    REQUIRE(tuple1.get(2)==t3);
    REQUIRE(tuple1.get(3)==t4);
    REQUIRE(tuple1.get(4)==t5);
}

TEST_CASE("VTuple replaceAll") {
    VTerm t1(0,0);
    VTerm t2(0,0);
    VTerm t3(0,1);
    VTerm t4(1,0);
    VTerm t5(1,1);
    VTuple tuple1(5);
    tuple1.set(t1,0);
    tuple1.set(t2,1);
    tuple1.set(t3,2);
    tuple1.set(t4,3);
    tuple1.set(t5,4);
    VTuple tuple2(tuple1);
    REQUIRE(tuple1==tuple2);
    tuple1.replaceAll(t5,t4);
    tuple2.set(t4,4);
    REQUIRE(tuple1==tuple2);
    tuple1.replaceAll(t1,t3);
    tuple2.set(t3,0);
    tuple2.set(t3,1);
    REQUIRE(tuple1==tuple2);
}


TEST_CASE("VTuple getRepeatedVars") {
    VTuple tuple1(5);
    std::vector<std::pair<uint8_t, uint8_t>> expected;
    REQUIRE(tuple1.getRepeatedVars()==expected);

    VTerm c1(0,1);
    tuple1.set(c1,0);
    tuple1.set(c1,1);
    REQUIRE(tuple1.getRepeatedVars()==expected);

    VTerm v1(1,0);
    tuple1.set(v1,2);
    REQUIRE(tuple1.getRepeatedVars()==expected);
    tuple1.set(v1,3);
    expected.push_back(std::make_pair(2,3));
    REQUIRE(tuple1.getRepeatedVars()==expected);

    tuple1.set(v1,4);
    expected.push_back(std::make_pair(2,4));
    expected.push_back(std::make_pair(3,4));
    REQUIRE(tuple1.getRepeatedVars()==expected);
}

