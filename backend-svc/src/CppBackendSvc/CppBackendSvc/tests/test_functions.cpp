#include <boost/test/unit_test.hpp>
#include "../main.h"

BOOST_AUTO_TEST_SUITE(functions)

BOOST_AUTO_TEST_CASE(save)
{
	auto conn = init_db("test");
	reminder_element elem;

	elem.clear(conn, "");

	elem.id = 1;
	elem.title = "test";

	elem.save(conn);

	auto result = reminder_element::select_all(conn);
	BOOST_CHECK_EQUAL(1, result.size());
	BOOST_CHECK_EQUAL(1, result[0].id);
	BOOST_CHECK_EQUAL("test", result[0].title);
	//BOOST_CHECK(result[0].created_at.length > 0);  // TODO やりかた調べる
}

BOOST_AUTO_TEST_CASE(delet)
{
    // FIXME
}

BOOST_AUTO_TEST_SUITE_END()
