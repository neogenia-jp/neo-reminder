#pragma once

#include <string>
#include <sqlite/connection.hpp>

using namespace std;

namespace DBTool {
	
	class Migrator
	{
			
	public:
		Migrator();
		~Migrator();

	protected:
		sqlite::connection* conn;
		virtual void Open();

		virtual void Close();

	public:
		virtual void CreateDatabase(string name);

		virtual string GetCurrentDatabase();

		virtual void ChangeDatabase(string name);

		virtual void Status();

		virtual void Up();

		virtual void Down();

	};

}