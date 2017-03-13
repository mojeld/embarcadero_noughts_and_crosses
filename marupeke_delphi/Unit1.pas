unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.ScrollBox, FMX.Memo, System.DateUtils,
  FMX.Objects, System.Generics.Collections, Unit2;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    SpeedButton8: TSpeedButton;
    SpeedButton9: TSpeedButton;
    SpeedButton10: TSpeedButton;
    SpeedButton11: TSpeedButton;
    SpeedButton12: TSpeedButton;
    Timer1: TTimer;
    Line1: TLine;
    Line2: TLine;
    Line3: TLine;
    Line4: TLine;
    procedure SpeedButton12Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    Marupeke1:  TMarupeke;
    procedure SpeedButtonsClick(Sender: TObject);
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);//フォーム作成時
var
  i:  Integer;
begin
  Marupeke1 := TMarupeke.Create(Timer1);  //TMarupekeインスタンスを作る
  for i := 0 to 8 do                      //1～9のボタンをTMarupekeにセット
    Marupeke1.Buttons.Add(
      TSpeedButton(Self.FindComponent(Format('SpeedButton%d', [i+1]))) );
  Timer1.Enabled          := False;
  SpeedButton10.IsPressed := True;
  Randomize;
  Marupeke1.game_clear(False, SpeedButton11.IsPressed, SpeedButtonsClick);
end;

procedure TForm1.FormDestroy(Sender: TObject);//フォーム終了時
begin
  Marupeke1.DisposeOf;  //TMarupeke捨てる
end;


procedure TForm1.SpeedButton12Click(Sender: TObject);
begin
  Marupeke1.game_clear(True, SpeedButton11.IsPressed, SpeedButtonsClick);
  Marupeke1.start_flg := True;
end;

procedure TForm1.SpeedButtonsClick(Sender: TObject);
begin
  ///三目９マスのボタンのクリックイベント
  with (Sender as TSpeedButton) do
  begin
    if Tag = 0 then
    begin
      IsPressed := True;
      Tag       := player;  ///Unit2の定数の値
      Text      := '〇';    ///プレーヤは先攻/後攻関係なく〇が入る
      if Marupeke1.triumph > 1 then
      begin  ///条件が揃ったらWinを出してゲームクリア
        ShowMessage('Win');
        Marupeke1.game_clear(False, SpeedButton11.IsPressed, SpeedButtonsClick);
      end;
      Timer1.Enabled  := True;  ///タイマーを使いコンピュータへターンを渡す
    end;
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  random_:    Integer;
  sp_button_: TSpeedButton;
  next_:      Boolean;
  dtStart:    TDateTime;
  kouho:      Integer;
  bflg:       Boolean;
  counts_:    TCounts;
begin
  Timer1.Enabled  := False;
  dtStart := IncSecond(Now, 1); ///タイムアウト用1秒以上経過するとタイムアウト処理
  next_   := False;
  kouho := -1;
  if Marupeke1.start_flg then
  begin
    bflg  := False;
    ///無名メソッドを使い次の手を考えさせます
    TMarupeke.line_list(procedure (line_: TLines) var i: Integer; begin
      counts_ := TCounts.Create(0,0);
      {************************************************************************}
      {     TLines配列に〇と×が何個入っているか調べる
            このコードではプレーヤ側のリーチだけを見ています。(保守的)
            Question: 自分(コンピュータ)のリーチ目を調べて自分から勝つコードを
                      追記修正してみてください。                               }
      {************************************************************************}
      for i:=0 to Length(line_)-1 do
      begin
        sp_button_  := TSpeedButton(Self.FindComponent(Format('SpeedButton%d', [line_[i]+1])));
        if sp_button_.Tag = player then
          Inc(counts_.count1);
        if sp_button_.Tag = computer then
          Inc(counts_.count2);

        if (sp_button_.Tag = 0) and (not bflg) then
        begin
          kouho := line_[i];//次の手の候補を選ぶ
        end;
      end;
      if (counts_.count1 >= 2) and (counts_ < TCounts.Create(3,0)) then
      begin //TLines配列に〇が2つある場合で配列が埋まっていない場合
        counts_ := TCounts.Create(0,0);
        bflg    := True;
      end;
    end);

    while (not next_)  do
    begin
      if kouho >= 0 then  //次の手があればそれを利用し
        random_ := kouho
      else                //手が何も無い場合randomで選ぶ
        random_ := Random(9);
      Sleep(100);
      sp_button_  := TSpeedButton(Self.FindComponent(Format('SpeedButton%d', [random_+1])));
      if sp_button_.Tag = 0 then
      begin ///ここでコンピュータ側の手を入れます。
        sp_button_.Tag        := computer;  ///定数
        sp_button_.Text       := '×';      ///コンピュータ側は先攻/後攻全て×
        sp_button_.IsPressed  := True;
        next_ := True;
      end
      else
        kouho := -1;

      if (dtStart < Now) then
      begin //無限ループしないようにタイムアウトを作る
        next_ := True;
        ShowMessage('draw');
      end;
    end;

    {*********************************************************************}
    {     triumphは三目並べれば1以上を返しています。
          Question: function TMarupeke.triumph: Integer;を変更し
                    Win/Loseを作ってみてください。                        }
    {*********************************************************************}
    if Marupeke1.triumph > 1 then
    begin //triumphで勝敗がついている場合
      ShowMessage('Win');
      Marupeke1.game_clear(False, SpeedButton11.IsPressed, SpeedButtonsClick);
    end;
  end;
end;

end.
