#include <catch2/catch_all.hpp>

constexpr unsigned int Factorial(unsigned int number)// NOLINT(misc-no-recursion)
{
  return number <= 1 ? number : Factorial(number - 1) * number;
}

TEST_CASE("Factorials are computed with constexpr", "[factorial]")
{
  STATIC_REQUIRE(Factorial(1) == 1);
  STATIC_REQUIRE(Factorial(2) == 2);
}
