#include "Error_proc.h"
#include <boost/algorithm/string/join.hpp>

using namespace std;


// TODO:�G���[���b�Z�[�W�\���̂�Ԃ��֐�

// TODO:�G���[�������̓��b�Z��Ԃ��Ƌ��Ƀ��O���o�͂���


// �G���[�̕\�����@��
// �@�e�֐��ɂ����ď����X�e�[�^�X��Ԃ��i�]���ʂ�j
// �A�X�e�[�^�X�R�[�h�ɂ��G���[���b�Z�[�W�̍\��(f_�֐�����Error_proc��p����)
// �B�G���[���b�Z�\������JSON�֍ĕҁA�t�����g�֓n��

struct Error_obj {
    string message;     // �G���[���e�i�l�Ԃ��ǂ�ŗ����ł�����e�j
    string reason;      // �G���[���e�i�J���҂��ǂ�ŗ����ł�����e�B�f�o�b�O�p�j
    string file;        // �G���[�������̃t�@�C������N���X���Ȃ�
    string line;        // �s�ԍ�
};

//�G���[�R�[�h�ɉ�����
void Get_ErrorObj(int err_code){
    



}
