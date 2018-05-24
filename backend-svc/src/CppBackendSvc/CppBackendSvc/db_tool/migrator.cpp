#include "migrator.h"
#include <sqlite/execute.hpp>
#include <sqlite/query.hpp>

using namespace DBTool;

	Migrator::Migrator()
	{
	}


	Migrator::~Migrator()
	{
	}

	void Migrator::CreateDatabase(string name) {

	}

	string Migrator::GetCurrentDatabase() {
		return "test";
	}

	void Migrator::ChangeDatabase(string name) {

	}

	void Migrator::Status() {

	}

	void Migrator::Up() {

	}

	void Migrator::Down() {

	}


	void Migrator::Open() {
        conn = new sqlite::connection("/mnt/CppBackendSvc/"+GetCurrentDatabase()+".db");
	}

	void Migrator::Close() {
		 delete conn;
		 conn = NULL;
	}
