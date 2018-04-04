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

map<string, CommandType> commandMap{
	{ "list" , list },
{ "create", create },
{ "detail", detail },
{ "edit",edit },
{ "finish", finish },
{ "delet", delet }
};
