#pragma once
#include "main.h"


//�������ʃX�e�[�^�X�R�[�h
#define _ERROR      0   // �ُ�
#define _SUCCESS    1   // ����



//�G���[���e�i�l�Ԃ��ǂ�ŗ����ł�����e�j
#define Error_Message_DB_Error "�f�[�^�x�[�X�̃A�N�Z�X�Ɏ��s���܂���" 

//�G���[���e�i�J���҂��ǂ�ŗ����ł�����e�B�f�o�b�O�p�j
#define Error_Reason_DB_Error "DB�A�N�Z�X�ُ�" 

// �G���[�ꗗ
enum ErrorType {




};

//struct errorInfo{
//    string status;  // �X�e�[�^�X�R�[�h
//    string message; // �G���[���e�i�l�Ԃ��ǂ�ŗ����ł�����e�j
//    string reason;  // �G���[���e�i�J���҂��ǂ�ŗ����ł�����e�B�f�o�b�O�p�j
//    string file;    // �G���[�������̃t�@�C������N���X���Ȃ�
//    string line;    // �s�ԍ�
//};

//
///*
//* @brief �G���[����
//* @param (commandName) �������R�}���h��
//* @return ���ʃG���[�I�u�W�F�N�g
//*/
//void error_proc(CommandType commandName, picojson::object obj) {
//
//    // �X�e�[�^�X�R�[�h
//    obj.insert(std::make_pair("status", picojson::value("error")));
//
//    // �G���[���e�i�l�Ԃ��ǂ�ŗ����ł�����e�j
//    string message = "";
//    obj.insert(std::make_pair("message", picojson::value(message)));
//
//    // �G���[���e�i�J���҂��ǂ�ŗ����ł�����e�B�f�o�b�O�p
//    string reason = "";
//
//    obj.insert(std::make_pair("reason", picojson::value(reason)));
//
//    // �G���[�������̃t�@�C������N���X���Ȃ�
//    obj.insert(std::make_pair("message", picojson::value(message)));
//
//
//}
