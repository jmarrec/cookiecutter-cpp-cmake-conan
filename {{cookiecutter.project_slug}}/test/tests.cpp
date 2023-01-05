{%- if cookiecutter.test_engine == "Catch2" -%}
#include <catch2/catch_all.hpp>
{%- elif cookiecutter.test_engine == "gtest" -%}
#include <gtest/gtest.h>
{%- endif %}

unsigned int Factorial(unsigned int number)// NOLINT(misc-no-recursion)
{
  return number <= 1 ? number : Factorial(number - 1) * number;
}

{% if cookiecutter.test_engine == "Catch2" -%}
TEST_CASE("Factorials are computed", "[factorial]")
{
  REQUIRE(Factorial(1) == 1);
  REQUIRE(Factorial(2) == 2);
  REQUIRE(Factorial(3) == 6);
  REQUIRE(Factorial(10) == 3628800);
}
{% elif cookiecutter.test_engine == "gtest" -%}
TEST(FactorialTest, Basic_Test) {
  EXPECT_EQ(1, Factorial(1));
  EXPECT_EQ(2, Factorial(2));
  EXPECT_EQ(3, Factorial(6));
  EXPECT_EQ(10, Factorial(3628800));
}
{% endif -%}
