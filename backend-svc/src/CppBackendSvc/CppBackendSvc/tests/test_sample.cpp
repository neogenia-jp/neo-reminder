#include <boost/test/unit_test.hpp>

BOOST_AUTO_TEST_SUITE(sample2)

BOOST_AUTO_TEST_CASE(hoge2)
{
	BOOST_CHECK_EQUAL(2*2, 4);
}

BOOST_AUTO_TEST_CASE(fuga2)
{
	BOOST_CHECK_EQUAL(2*3, 6);
}

BOOST_AUTO_TEST_SUITE_END()
