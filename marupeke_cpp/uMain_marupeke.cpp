//---------------------------------------------------------------------------

#include <fmx.h>
#pragma hdrstop

#include "uMain_marupeke.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.fmx"
TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
	: TForm(Owner)
{

}
//---------------------------------------------------------------------------
void __fastcall TForm1::FormCreate(TObject *Sender)
{
	marupeke1 = new tutorial2::TMarupeke(Timer1);
	for (int i = 0; i < marupeke1->Buttons.size(); i++)
	{
		///9個の〇×用SpeedButtonの参照をコピー
		marupeke1->Buttons[i] = static_cast<TSpeedButton* >(
			this->FindComponent(Format("SpeedButton%d", ARRAYOFCONST((i + 1)))) );
	//	marupeke1->Buttons[i]->Text = Format("%d",ARRAYOFCONST((i+1)));
	}
	Timer1->Enabled = false;
	SpeedButton10->IsPressed = true;
	///初期ボタンクリア(このgame_clearは他でも呼ぶ)
	marupeke1->game_clear(false, SpeedButton11->IsPressed, SpeedButtonsClick);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormDestroy(TObject *Sender)
{
	delete marupeke1;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::SpeedButtonsClick(TObject *Sender)
{
	///プレーヤーのボタンをクリックした場合のイベント(〇側)
	auto _btn = static_cast<TSpeedButton* >(Sender);
	if (_btn->Tag == 0)
	{
		_btn->IsPressed	= true;
		_btn->Tag			= tutorial2::player;
		_btn->Text		= L"〇";
		if (marupeke1->triumph() > 1)
		{
			ShowMessage("Win");
			marupeke1->game_clear(false, SpeedButton11->IsPressed, SpeedButtonsClick);
		}
		Timer1->Enabled	= true;
	}
}

void __fastcall TForm1::SpeedButton12Click(TObject *Sender)
{
	///ゲームスタートボタンクリック
	marupeke1->game_clear(true, SpeedButton11->IsPressed, SpeedButtonsClick);
    marupeke1->start_flg = true;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Timer1Timer(TObject *Sender)
{
	using namespace std::chrono;
	Timer1->Enabled = false;
	auto dt_start = system_clock::now() + seconds(1); //タイムアウト用1秒後
	int kouho{-1};
	bool bflg{false};
	if (marupeke1->start_flg)
	{
		tutorial2::TMarupeke::line_list([this, &bflg, &kouho](int _line[3]){
		/************************************************************************/
		/*     TLines配列に〇と×が何個入っているか調べる
			このコードではプレーヤ側のリーチ目だけを見ています。(保守的)
			Question: 自分(コンピュータ)のリーチ目を調べて自分から勝つコードを
					  追記修正してみてください。                              */
		/************************************************************************/
			tutorial2::TCounts _counts{0,0};
			for (int i=0; i < 3;i++)
			{
				auto _btn = static_cast<TSpeedButton*>(
					this->FindComponent(Format("SpeedButton%d", ARRAYOFCONST((_line[i]+1)) )));
				if (_btn->Tag == tutorial2::player)		_counts.count1++;
				if (_btn->Tag == tutorial2::computer) 	_counts.count2++;

				if ((_btn->Tag == 0) && (!bflg) )
					kouho = _line[i]; //次の手の候補を選ぶ
			}

			tutorial2::TCounts temp{3,0};
			if ((_counts.count1 >= 2) && (_counts < temp))
			{
				_counts = tutorial2::TCounts{0,0};
				bflg    = true;
			}

		});
		bool _next{false};  //ループ用
		while (! _next)
		{
			std::this_thread::sleep_for(microseconds(100));
			unsigned int _random{0};
			(kouho >= 0)?	//次の手があればそれを利用し
							//手が何も無い場合randomで選ぶ
				_random = kouho: _random = marupeke1->select_random(9);

			auto _btn = static_cast<TSpeedButton*>(
				this->FindComponent(Format("SpeedButton%d", ARRAYOFCONST((_random+1)) )));
			if (_btn->Tag == 0)
			{
				_btn->Tag        = tutorial2::computer;
				_btn->Text       = "×";   //COMが×を入れる
				_btn->IsPressed  = true;
				_next = true;
			}
			else
				kouho = -1;

			if (dt_start <= system_clock::now()) //無限ループしないようにタイムアウトを作る
			{
				_next = true;
				ShowMessage("draw");
			}
		}

		/*********************************************************************/
		/*     triumphは三目並べれば1以上を返しています。
			  Question: function TMarupeke::triumph: Integer;を変更し
						Win/Loseを作ってみてください。                       */
		/*********************************************************************/
		if (marupeke1->triumph() > 1) //triumphで勝敗がついている場合
		{
			ShowMessage("Win");
			marupeke1->game_clear(false, SpeedButton11->IsPressed, SpeedButtonsClick);
		}

	}
}
//---------------------------------------------------------------------------

