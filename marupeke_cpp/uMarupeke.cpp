//---------------------------------------------------------------------------

#pragma hdrstop

#include "uMarupeke.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)

using namespace tutorial2;
__fastcall TMarupeke::TMarupeke(TTimer* tm): inherited()
{
	///コンストラクター実装部
	f_main_timer = tm;
}


__fastcall TMarupeke::~TMarupeke()
{
	///デストラクター実装部

}

button_array& __fastcall TMarupeke::getButtons()
{
	return f_buttons;
}

void __fastcall TMarupeke::game_clear(bool start, bool attacked, TNotifyEvent _event)
{
	///ボタンなど初期クリア
	for (auto _btn : f_buttons)
	{
		_btn->IsPressed = false;  //プレス
		_btn->OnClick   = _event; //共通クリックイベントの設定
		_btn->Text      = "";
		_btn->Tag       = 0;
	  (start)? _btn->Enabled = true: _btn->Enabled = false;
	}
	f_main_timer->Enabled = attacked;   //タイマーを引数に合わせてセットする
}

void __fastcall TMarupeke::line_list(std::function<void(int[])> _proc)
{
	///斜めパターンの初期化
	std::array<std::array<int, 3> , 3> triumph_naname{
		{ {{0,4,8}},{{2,4,6}},{{0,0,0}} } };
	///縦横のパターンはループで作成
	int z[3]{0,0,0};
	for (int i1 = 0; i1 < 3; i1++)
		for (int i2 = 0; i2 < 3; i2++)
		{
			for (int i3 = 0; i3 < 3; i3++)
			{
				switch (i1)
				{
				case 0:
					z[i3] = i3 + (i2*3); break;
				case 1:
					z[i3] = (i3*3) + i2; break;
				case 2:
					z[i3] = triumph_naname[i2][i3]; break;
				default:
					;
				}
			}
			if (!((z[0] == 0) && (z[1] == 0) && (z[2] == 0))) {
				_proc(z);
			}
		}
}


int __fastcall TMarupeke::triumph_row(int r[])
{
	///勝敗判定その2
	int _answer{0};
	int tag_num{0}, temp_tag_num{0};
	for (int com_count = 0;com_count < 3; com_count++)
	{
		temp_tag_num = f_buttons[r[com_count]]->Tag;
		if (temp_tag_num != 0)
			((com_count != 0) && (tag_num == temp_tag_num))?
				_answer++: tag_num = temp_tag_num;
	}
	return _answer;
}

int __fastcall TMarupeke::triumph()
{
	///勝敗判定その1
	int _answer{0};
	line_list([this, &_answer](int z[3]){
		if ( (z[1] > 0) && (z[2] > 0) )
			_answer = triumph_row(z);  //三目揃ったか？

		if (_answer > 1)  //どちらかが三目揃った場合
		{
			f_start_flg = false;
			f_main_timer->Enabled = false;
		}
	});
	if (f_start_flg){
		return _answer;
	}
	else
		return 2;
}

unsigned int __fastcall TMarupeke::select_random(const unsigned int max)
{
    //0～maxまでのランダム作って返す
	std::uniform_int_distribution<int> randomm_( 0, max-1 ) ;
	return randomm_(randomize_);
}

