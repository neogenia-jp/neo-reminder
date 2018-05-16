#pragma once

#include <iostream>
#include "picojson.h"

using namespace std;

enum CommandType {
	list = 1,	// �ꗗ�\��
	create,		// �V�K�쐬
	detail,		// �ڍו\��
	edit,		// �ҏW
	finish,		// ����
	delet,		// �폜
    clear,      // �N���A

	command_maxnum // �ő�R�}���h��
};
//
//enum DataType {
//	id,					// ID�ԍ�
//	title,				// �^�C�g��
//	term,				// ���t (ISO�`��)
//	status,				// �X�e�[�^�X�@(OK/Error)
//	message,			// ���b�Z�[�W
//	notify_datetime,	// ���t
//	memo,				// ����
//	finished_at,		// ������
//	created_at,			// �쐬��
//};


// �ꗗ�\���f�[�^
struct LIST_ST {
	short		id;				// ID�ԍ�
	string		title;			// �^�C�g��
	time_t		term;			// ���t (ISO�`��)
};

// �V�K�쐬�f�[�^
struct CREATE_ST {
	string		status;		// �X�e�[�^�X�@(OK/Error)
	string		message;	// ���b�Z�[�W
};

// �ڍו\���f�[�^
struct DETAIL_ST {
	short		id;					// ID�ԍ�
	string		title;				// �^�C�g��
	time_t		notify_datetime;	// ���t
	time_t		term;				// ���t (ISO�`��)
	string		memo;				// ����
	time_t		finished_at;		// ������
	time_t		created_at;			// �쐬��
};

// �ҏW�f�[�^
struct EDIT_ST {
	string		status;			// �X�e�[�^�X�@(OK/Error)
	string		message;		// ���b�Z�[�W
	time_t		created_at;		// �쐬��
};

// �����f�[�^
struct FINISH_ST {
	string		status;			// �X�e�[�^�X�@(OK/Error)
	string		message;		// ���b�Z�[�W
	time_t		finished_at;	// ������
};

// �폜�f�[�^
struct DELETE_ST {
	string		status;			// �X�e�[�^�X�@(OK/Error)
	string		message;		// ���b�Z�[�W
};


struct base_model {
    int id = 0;  //  1,
    virtual inline int save_or_update(sqlite::connection* conn) {
        if (id == 0) {
            return save(conn);
        }
        else {
            return update(conn);
        }
    }
    virtual int save(sqlite::connection* conn) = 0;
    virtual int update(sqlite::connection* conn) = 0;
};


struct reminder_element : base_model {
    string title ; //�gxxxxxx�h,
    string notify_datetime; // �g2018 - 03 - 20T19:32 : 00 + 0900�h
    string term; //�g2018 - 03 - 20T19:32 : 00 + 0900�h,  // ISO�`��
    string memo; //�gxxxxxxxxxxxxxxxxxxxxxxx�h,
    string finished_at; // �g2018-03-20T19:32:00+0900�h,  // ������
    string created_at; // �g2018-03-20T19:32:00+0900�h  // �쐬��

	template<class... A> static std::vector<reminder_element> select_all(sqlite::connection* conn, A... args) {
		std::vector<string> v = { "1=1" };

		for (auto i : std::initializer_list<const char*>{ args... }) {
			string str(i);
			v.push_back(str);
		}

		// �J���}��؂�̕�����ɂ���
		const std::string s = boost::algorithm::join(v, " AND ");

		string sql = "SELECT * FROM reminder_element WHERE ";
		sql += s;
		sqlite::query q(*conn, sql);

		boost::shared_ptr<sqlite::result> result = q.get_result();

		std::vector<reminder_element> list;
		while (result->next_row()) {
			reminder_element e;
			e.load(result);
			list.push_back(e);
		}
		return list;
	}

    /*
    * @brief �ڍו\��
    * @param (conn) DB Connection �I�u�W�F�N�g
    */
    static int select(sqlite::connection* conn, int id, reminder_element &e);

	void load(boost::shared_ptr<sqlite::result> result);

	/*
	* @brief �f�[�^�V�K�o�^
	* @param (conn) DB Connection �I�u�W�F�N�g
	* @return 0:�o�^����
	* @return 1:�o�^�G���[
	*/
	int save(sqlite::connection* conn);

	/*
	* @brief �f�[�^�X�V
	* @param (conn) DB Connection �I�u�W�F�N�g
	* @return 0:�o�^����
	* @return 1:�o�^�G���[
	*/
	int update(sqlite::connection* conn);

    /*
    * @brief �f�[�^�����X�V
    * @param (conn) DB Connection �I�u�W�F�N�g
    * @return 0:�X�V����
    * @return 1:�X�V�G���[
    */
	int finish(sqlite::connection* conn);

    /*
    * @brief �f�[�^�폜
    * @param (conn) DB Connection �I�u�W�F�N�g
    * @return 0:�폜����
    * @return 1:�폜�G���[
    */
	int dataDelete(sqlite::connection* conn);

    /*
    * @brief �f�[�^�ꊇ�폜
    * @param (conn) DB Connection �I�u�W�F�N�g
    * @return 0:�폜����
    * @return 1:�폜�G���[
    */
    vector<int> clear(sqlite::connection* conn, string option);
};

// �ꗗ�擾
void f_GetList(
	sqlite::connection* conn,
	picojson::object&	req,
	picojson::object&	result
);


// �o�^
void f_Regist(
	sqlite::connection* conn,
	picojson::object&	req,
	picojson::object&	result
);


// �ڍו\��
void f_DspDetail(
	sqlite::connection* conn,
	picojson::object&	req,
	picojson::object&	result
);


// �ڍוҏW
void f_EditDetail(
	sqlite::connection* conn,
	picojson::object&	req,
	picojson::object&	result
);

// ����
void f_Finish(
	sqlite::connection* conn,
	picojson::object&	req,
	picojson::object&	result
);

// �폜
void f_Delete(
	sqlite::connection* conn,
	picojson::object&	req,
	picojson::object&	result
);

// �ꊇ�폜
void f_Clear(
    sqlite::connection* conn,
    picojson::object&	req,
    picojson::object&	result
);



