//---------------------------------------------------------------------------

#ifndef uMarupekeH
#define uMarupekeH
#include <array>
#include <random>
#include <functional>
//---------------------------------------------------------------------------
namespace tutorial2
{
	using inherited = System::TObject;
	using button_array = std::array<TSpeedButton* , 9>;
	constexpr unsigned int player 	= 1;
	constexpr unsigned int computer	= 2;
	struct TCounts
	{
		int count1{0},
			count2{0};
		TCounts(int i1,int i2)  {count1 = i1; count2 = i2;}
		TCounts(const TCounts& c) _ALWAYS_INLINE {count1 = c.count1; count2 = c.count2;}
		inline bool operator <(const TCounts& a) {
			if ((count1 + count2) < (a.count1 + a.count2)){
				return true;
			}
			else
				return false;
        }

    };
	class TMarupeke : public inherited
	{
	private:
		TTimer* f_main_timer;
		button_array f_buttons;
		std::random_device rnd_;
		std::mt19937 	randomize_{rnd_()};
		bool f_start_flg{false};
		button_array& __fastcall getButtons();
		int __fastcall triumph_row(int r[]);
	public:
		__fastcall TMarupeke(TTimer* tm );
		__fastcall virtual ~TMarupeke();
		///ゲームのクリア(ボタンなど初期化)
		void __fastcall game_clear(bool start, bool attacked, TNotifyEvent _event);
		///パターン用関数
		static void __fastcall line_list(std::function<void(int[])> _proc);
		///〇もしくは×揃った場合 return 2
		int __fastcall triumph();
		///ランダムで0～maxまでを返す
		unsigned int __fastcall select_random(const unsigned int max);

		///ボタン配列
		__property button_array& Buttons = {read = getButtons};
		///ゲームスタートflg
		__property bool start_flg = {read = f_start_flg, write = f_start_flg};
	};
}
#endif
