unit Unit2;

interface
uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, FMX.StdCtrls,
  FMX.Types,  //TTimer用
  System.Generics.Collections;

const
  player    = 1;
  computer  = 2;

type
  TCounts = record
    count1:     Integer;
    count2:     Integer;
    constructor Create(c1, c2: Integer); overload;
    class operator LessThan(a: TCounts; b: TCounts): Boolean;
  end;
  TLines = array of Integer;
  TMarupeke = class(TObject)
    constructor Create(const tim_: TTimer);
    destructor Destroy; override;
  private
    Fstart_flg:     Boolean;
    FButtons:   TList<TSpeedButton>;  //1～9までのボタン
    FMainTimer: TTimer;               //メイン側のタイマー
    function getButtons: TList<TSpeedButton>;
  public
    ///<summary>ボタンを呼出すプロパティ</summary>
    property  Buttons: TList<TSpeedButton>  read getButtons;
    procedure game_clear(start, attacked: Boolean; event_: TNotifyEvent);
    class procedure line_list(proc: TProc<TLines>);
    function triumph: Integer;
    function triumph_row(r: TLines): Integer;
    property  start_flg: Boolean  read Fstart_flg write Fstart_flg;
  end;

implementation

{ TMarupeke }

constructor TMarupeke.Create(const tim_: TTimer);
begin
  inherited Create;
  Fstart_flg  := False;
  FButtons    := TList<TSpeedButton>.Create;
  FMainTimer  := tim_;
end;

destructor TMarupeke.Destroy;
begin
  FButtons.DisposeOf;
  inherited;
end;

procedure TMarupeke.game_clear(start, attacked: Boolean; event_: TNotifyEvent);
var
  btn_: TSpeedButton;
begin
  for btn_ in FButtons do  //FindComponentで1～9までのSpeedButtonを探す
    with btn_ do
    begin
      IsPressed := False;  //プレス
      OnClick   := event_; //共通クリックイベントの設定
      Text      := '';
      Tag       := 0;
      if start then
        Enabled := True
      else
        Enabled := False;
    end;
  FMainTimer.Enabled  := attacked;  //後攻ならCOMのターン
end;

function TMarupeke.getButtons: TList<TSpeedButton>;
begin
  Result  := FButtons;
end;

class procedure TMarupeke.line_list(proc: TProc<TLines>);
const
  triumph_naname: array[0..2, 0..2] of Integer = ((0,4,8),(2,4,6),(0,0,0));
var
  i: Integer;
  i1: Integer;
  i2: Integer;
  z:  TLines;
  zi: Integer;
begin
  SetLength(z, 3);
  for i := 0 to 2 do
    for i1 := 0 to 2 do
    begin
      for i2 := 0 to 2 do
      begin
        case i of
        0:z[i2] := i2 + (i1*3);
        1:z[i2] := (i2*3) + i1;
        2: begin
          z[i2] := triumph_naname[i1,i2];
        end;
        end;
      end;
      if not ((z[0] = 0) and (z[1] = 0) and (z[2] = 0)) then
        proc(z);
    end;
end;

function TMarupeke.triumph: Integer;
var
  answer_:  Integer;
begin
  answer_  := 0;
  line_list(procedure (z: TLines) begin
    if (z[1] > 0) and (z[2] > 0) then
      answer_ := triumph_row(z);  //三目揃ったか？

    if answer_ >1 then  //どちらかが三目揃った場合
    begin
      Fstart_flg := False;
      FMainTimer.Enabled  := False;
    end
  end);
  if not Fstart_flg then
    Result  := 2
  else
    Result  := answer_;
end;

function TMarupeke.triumph_row(r: TLines): Integer;
var
  com_count: Integer;
  iTag, temp_tag:       Integer;
  answer_: Integer;
begin
  answer_   := 0;
  iTag      := -1;
  for com_count := 0 to Length(r)-1 do
  begin
    temp_tag  := FButtons[r[com_count]].Tag;
    if not(temp_tag = 0) then
      if (not(com_count=0) and (temp_tag = iTag)) then
        Inc(answer_)
      else
        iTag  := temp_tag;
  end;
  Result  := answer_;
end;

{ TCounts }

constructor TCounts.Create(c1, c2: Integer);
begin
  count1  := c1;
  count2  := c2;
end;

class operator TCounts.LessThan(a, b: TCounts): Boolean;
begin
  if (a.count1 + a.count2) < (b.count1 + b.count2) then
    Result  := True
  else
    Result  := False;
end;

end.
