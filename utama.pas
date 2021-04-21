unit utama;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, Math;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnStart: TButton;
    btnPause: TButton;
    btnExit: TButton;
    btnStop: TButton;
    txtTuner: TEdit;
    txtNon_Tuner: TEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Timer1: TTimer;
    procedure btnPauseClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    procedure Calc_Tuner(deg_tune: Double; y_tune: Integer);
    procedure gambar_tuner_depan(deg_tune: Double);
    procedure gambar_tuner_belakang(deg_tune: Double);
    procedure calc_pipa(deg_tune: Double; radius : double);
    procedure gambar_pipa_depan(deg_tune: Double);
    procedure gambar_pipa_belakang(deg_tune: Double);
    procedure clearCanvas();
    //function Location_Non_Tuner(non_tuner: Integer);

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }
type
  TPoint3D = record
      x_pos: Double;
      y_pos: Double;
      z_pos: Double;
      xp: Double;
      yp: Double;
  end;

var
  px: Integer;
  py: Integer;
  rad: Double;
  deg: Single;
  radius_tune: Single;
  //radius_pipe: Single;
  Pos: array[1..2,1..361] of TPoint3D;
  //Pipe: array[1..2,1..361] of TPoint3D;
  M: Double;
  deg_tune: array[1..12] of Double;
  y_tune: array[1..12] of Integer;
  y_non_tune: array[1..12] of Integer;
  tuner: Integer;
  non_tuner: Integer;
  pipa_radius : double;
  sudah_sampai: boolean;
  sudah_selesai: boolean;
  level : Integer;

procedure TForm1.FormShow(Sender: TObject);
begin
  px := Image1.Width div 2;
  py := Image1.Height div 2;
  M := 500;
  pipa_radius := 1;
  sudah_sampai := false;
  sudah_selesai := false;

  Image1.Canvas.Brush.Color := clWhite;
  Image1.Canvas.Pen.Color := clNone;
  Image1.Canvas.Rectangle(0,0,Image1.Width,Image1.Height);
  Image1.Canvas.Pen.Color := clRed;
  Image1.Canvas.Pen.Style := psDash;
  Image1.Canvas.MoveTo(px, 0);
  Image1.Canvas.LineTo(px, Image1.Height);
  Image1.Canvas.MoveTo(0, py);
  Image1.Canvas.LineTo(Image1.Width, py);
end;

procedure TForm1.btnStartClick(Sender: TObject);
var
  i: integer;
  step_y_tune: Integer;
  step_y_non_tune : Integer;
  str: String;
begin
  if sudah_selesai then
  begin
    btnStopClick(Sender);
  end;
  // input
  tuner := StrToInt(txtTuner.Text);
  non_tuner := StrToInt(txtNon_Tuner.Text);
  level := tuner + non_tuner;

  if (tuner >= 12) or (non_tuner >= 12) then
  begin
    str := 'Tuner level atau Non Tuner level tidak boleh lebih besar dari 11!';
    ShowMessage(str);
    btnStopClick(Sender);
  end
  else if level >= 13 then
  begin
    str := 'Jumlah dari Tuner dan Non Tuner tidak boleh lebih dari 12!';
    ShowMessage(str);
    btnStopClick(Sender);
  end
  else
  begin
    Timer1.Enabled := True;

    // Setup
    step_y_tune   := 50;
    step_y_non_tune := 50 + 10; // 10 adalah ukuran image tuner div 2

    // inisialisasi data
    y_tune[1] := -(tuner div 2)*step_y_tune + (Image1.Height - 50);
    y_non_tune[1] := -(non_tuner div 2)*step_y_non_tune - (Image1.Height - 50);
    for i:=2 to tuner do
    begin
      deg_tune[i] := 0;
      y_tune[i] := y_tune[i-1] + step_y_tune;
    end;
    for i:=2 to non_tuner do
    begin
      y_non_tune[i] := y_non_tune[i-1] + step_y_non_tune;
    end;
  end;
end;

procedure TForm1.btnPauseClick(Sender: TObject);
begin
  Timer1.Enabled := not Timer1.Enabled;
end;

procedure TForm1.btnStopClick(Sender: TObject);
begin
  Timer1.Enabled := false;
  clearCanvas();
  sudah_sampai := false;
  pipa_radius := 0;
  sudah_selesai := false;
end;

procedure TForm1.clearCanvas();
begin
  Image1.Canvas.Brush.Color := clWhite;
  Image1.Canvas.Pen.Color := clNone;
  Image1.Canvas.Rectangle(0,0,Image1.Width,Image1.Height);
  Image1.Canvas.Pen.Color := clRed;
  Image1.Canvas.Pen.Style := psDash;
  Image1.Canvas.MoveTo(px, 0);
  Image1.Canvas.LineTo(px, Image1.Height);
  Image1.Canvas.MoveTo(0, py);
  Image1.Canvas.LineTo(Image1.Width, py);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  i: Integer;
  half_tune: Integer;
  half_non_tune: Integer;
  bola: TPicture;
  card: TPicture;
begin
  half_tune := 1 + tuner div 2;
  half_non_tune := 1 + non_tuner div 2;

  // update
  if non_tuner < tuner then
  begin
    if y_tune[half_tune] > 0 then
    begin
      for i:=1 to tuner do
      begin
        y_tune[i] := y_tune[i] - 10;
      end;
    end;

    if y_non_tune[half_non_tune] < 0 then
    begin
      for i:=1 to non_tuner do
      begin
        y_non_tune[i] := y_non_tune[i] + 10;
      end;
    end
    else
    begin
      sudah_sampai := true;
      if pipa_radius < 72 then
      begin
        pipa_radius := pipa_radius + 2;
      end
      else
      begin
        sudah_selesai := true;
      end;
    end;
  end
  else
  begin
    if y_tune[half_tune] > 0 then
    begin
      for i:=1 to tuner do
      begin
        y_tune[i] := y_tune[i] - 10;
      end;
    end
    else
    begin
      sudah_sampai := true;
      if pipa_radius < 72 then
      begin
        pipa_radius := pipa_radius + 2;
      end
      else
      begin
        sudah_selesai := true;
      end;
    end;

    if y_non_tune[half_non_tune] < 0 then
    begin
      for i:=1 to non_tuner do
      begin
        y_non_tune[i] := y_non_tune[i] + 10;
      end;
    end
  end;

  for i:=1 to tuner do
  begin
    deg_tune[i] := deg_tune[i] + 5;
  end;

  // gambar
  clearCanvas();

  for i:=1 to tuner do
  begin
    Calc_Tuner(deg_tune[i], y_tune[i]);
    gambar_tuner_belakang(deg_tune[i]);
    if sudah_sampai then
    begin
      calc_pipa(deg_tune[i], pipa_radius);
      gambar_pipa_belakang(deg_tune[i]*0.2);
    end;
  end;

  for i:=1 to non_tuner do
  begin
    bola := TPicture.Create;
    bola.LoadFromFile('shape.png');
    Image1.Canvas.Draw(px - bola.Width div 2, py - y_non_tune[i], bola.Graphic);
    bola.Free;
  end;

  for i:=1 to tuner do
  begin
    Calc_Tuner(deg_tune[i], y_tune[i]);
    gambar_tuner_depan(deg_tune[i]);
    if sudah_sampai then
    begin
      calc_pipa(deg_tune[i], pipa_radius);
      gambar_pipa_depan(deg_tune[i]*0.2);
    end;
  end;

  //untuk melihat animasi tanpa interferensi dari kartu, bisa dibuat menjadi komentar dari line 291 sampai 382
  if sudah_selesai then
  begin
    card := TPicture.Create;
    if level = 2 then
    begin
      card.LoadFromFile('Compressed\level 2.png');
      clearCanvas();
      Image1.Canvas.Draw(px - card.Width div 2, py - card.Height div 2, card.Graphic);
      card.Free;
      Timer1.Enabled := not Timer1.Enabled;
    end
    else if level = 3 then
    begin
      card.LoadFromFile('Compressed\level 3.png');
      clearCanvas();
      Image1.Canvas.Draw(px - card.Width div 2, py - card.Height div 2, card.Graphic);
      card.Free;
      Timer1.Enabled := not Timer1.Enabled;
    end
    else if level = 4 then
    begin
      card.LoadFromFile('Compressed\level 4.png');
      clearCanvas();
      Image1.Canvas.Draw(px - card.Width div 2, py - card.Height div 2, card.Graphic);
      card.Free;
      Timer1.Enabled := not Timer1.Enabled;
    end
    else if level = 5 then
    begin
      card.LoadFromFile('Compressed\level 5.png');
      clearCanvas();
      Image1.Canvas.Draw(px - card.Width div 2, py - card.Height div 2, card.Graphic);
      card.Free;
      Timer1.Enabled := not Timer1.Enabled;
    end
    else if level = 6 then
    begin
      card.LoadFromFile('Compressed\level 6.png');
      clearCanvas();
      Image1.Canvas.Draw(px - card.Width div 2, py - card.Height div 2, card.Graphic);
      card.Free;
      Timer1.Enabled := not Timer1.Enabled;
    end
    else if level = 7 then
    begin
      card.LoadFromFile('Compressed\level 7.png');
      clearCanvas();
      Image1.Canvas.Draw(px - card.Width div 2, py - card.Height div 2, card.Graphic);
      card.Free;
      Timer1.Enabled := not Timer1.Enabled;
    end
    else if level = 8 then
    begin
      card.LoadFromFile('Compressed\level 8.png');
      clearCanvas();
      Image1.Canvas.Draw(px - card.Width div 2, py - card.Height div 2, card.Graphic);
      card.Free;
      Timer1.Enabled := not Timer1.Enabled;
    end
    else if level = 9 then
    begin
      card.LoadFromFile('Compressed\level 9.png');
      clearCanvas();
      Image1.Canvas.Draw(px - card.Width div 2, py - card.Height div 2, card.Graphic);
      card.Free;
      Timer1.Enabled := not Timer1.Enabled;
    end
    else if level = 10 then
    begin
      card.LoadFromFile('Compressed\level 10.png');
      clearCanvas();
      Image1.Canvas.Draw(px - card.Width div 2, py - card.Height div 2, card.Graphic);
      card.Free;
      Timer1.Enabled := not Timer1.Enabled;
    end
    else if level = 11 then
    begin
      card.LoadFromFile('Compressed\level 11.png');
      clearCanvas();
      Image1.Canvas.Draw(px - card.Width div 2, py - card.Height div 2, card.Graphic);
      card.Free;
      Timer1.Enabled := not Timer1.Enabled;
    end
    else if level = 12 then
    begin
      card.LoadFromFile('Compressed\level 12.png');
      clearCanvas();
      Image1.Canvas.Draw(px - card.Width div 2, py - card.Height div 2, card.Graphic);
      card.Free;
      Timer1.Enabled := not Timer1.Enabled;
    end
  end;
end;

procedure TForm1.Calc_Tuner(deg_tune: Double; y_tune: Integer);
var
  i: Integer;
  j: Integer;
  temp: Double;
begin
  radius_tune := 80;
  deg := 0;
  i := 1;

  //inisialisasi lingkaran 1
  repeat
    rad := deg * PI / 180.0;

    Pos[1,i].x_pos := 0 + cos(rad) * radius_tune;
    Pos[1,i].y_pos := 0;
    Pos[1,i].z_pos := 0 + sin(rad) * radius_tune;

    deg += 1;
    i += 1;
  until deg > 360;

  //inisialisasi lingkaran 2
  radius_tune := 73;
  deg := 0;
  i := 1;

  repeat
    rad := deg * PI / 180.0;

    Pos[2,i].x_pos := 0 + cos(rad) * radius_tune;
    Pos[2,i].y_pos := 0;
    Pos[2,i].z_pos := 0 + sin(rad) * radius_tune;

    deg += 1;
    i += 1;
  until deg > 360;

  //rotasi sumbu y
  for i:=1 to 2 do
  begin
    for j:=1 to 360 do
    begin
      temp:= Pos[i,j].x_pos;
      Pos[i,j].x_pos:= Pos[i,j].x_pos * Cos(degtorad(deg_tune)) - Pos[i,j].z_pos * Sin(degtorad(deg_tune));
      Pos[i,j].z_pos:= temp * Sin(degtorad(deg_tune)) + Pos[i,j].z_pos * Cos(degtorad(deg_tune));
      Pos[i,j].y_pos:= Pos[i,j].y_pos;
    end;
  end;

  //translasi y
  for i:=1 to 2 do
  begin
    for j:=1 to 360 do
    begin
      Pos[i,j].y_pos := Pos[i,j].y_pos + y_tune;
    end;
  end;

  //proyeksi perspektif
  M := 500;
  for i:=1 to 2 do
  begin
    for j:=1 to 360 do
    begin
      if Pos[i,j].z_pos < M then
        begin
          Pos[i,j].xp := (round(Pos[i,j].x_pos / (1 - Pos[i,j].z_pos/M)));
          Pos[i,j].yp := (round(Pos[i,j].y_pos / (1 - Pos[i,j].z_pos/M)));
        end;
    end;
  end;
end;

procedure TForm1.gambar_tuner_depan(deg_tune: Double);
var
  i: integer;
begin
  Image1.Canvas.Pen.Color := clLime;
  Image1.Canvas.Pen.Style := psSolid;
  Image1.Canvas.Pen.Width := 1;

  for i:=1 to 359 do
  begin
    if (Round(deg_tune + i) mod 360) < 180 then
    begin
      Image1.Canvas.MoveTo(px + round(Pos[1,i].xp), py - round(Pos[1,i].yp));
      Image1.Canvas.LineTo(px + round(Pos[1,i+1].xp), py -  round(Pos[1,i+1].yp));

      Image1.Canvas.MoveTo(px + round(Pos[2,i].xp), py - round(Pos[2,i].yp));
      Image1.Canvas.LineTo(px + round(Pos[2,i+1].xp), py - round(Pos[2,i+1].yp));
    end;
  end;

  if (deg_tune + i) < 180 then
  begin
    Image1.Canvas.MoveTo(px + round(Pos[1,360].xp), py - round(Pos[1,360].yp));
    Image1.Canvas.LineTo(px + round(Pos[1,1].xp), py - round(Pos[1,1].yp));

    Image1.Canvas.MoveTo(px + round(Pos[2,360].xp), py - round(Pos[2,360].yp));
    Image1.Canvas.LineTo(px + round(Pos[2,1].xp), py - round(Pos[2,1].yp));
  end;

  i:=1;
  repeat
    if (Round(deg_tune + i) mod 360) < 180 then
    begin
      Image1.Canvas.MoveTo(round(px + Pos[1,i].xp), round(py - Pos[1,i].yp));
      Image1.Canvas.LineTo(round(px + Pos[2,i].xp), round(py - Pos[2,i].yp));
    end;
    i += 6;
  until i >= 360;
end;

procedure TForm1.gambar_tuner_belakang(deg_tune: Double);
var
  i: integer;
begin
  Image1.Canvas.Pen.Color := clLime;
  Image1.Canvas.Pen.Style := psSolid;
  Image1.Canvas.Pen.Width := 1;

  for i:=1 to 359 do
  begin
    if (Round(deg_tune + i) mod 360) > 180 then
    begin
      Image1.Canvas.MoveTo(px + round(Pos[1,i].xp), py - round(Pos[1,i].yp));
      Image1.Canvas.LineTo(px + round(Pos[1,i+1].xp), py -  round(Pos[1,i+1].yp));

      Image1.Canvas.MoveTo(px + round(Pos[2,i].xp), py - round(Pos[2,i].yp));
      Image1.Canvas.LineTo(px + round(Pos[2,i+1].xp), py - round(Pos[2,i+1].yp));
    end;
  end;

  if (deg_tune > 180) then
  begin
    Image1.Canvas.MoveTo(px + round(Pos[1,360].xp), py - round(Pos[1,360].yp));
    Image1.Canvas.LineTo(px + round(Pos[1,1].xp), py - round(Pos[1,1].yp));

    Image1.Canvas.MoveTo(px + round(Pos[2,360].xp), py - round(Pos[2,360].yp));
    Image1.Canvas.LineTo(px + round(Pos[2,1].xp), py - round(Pos[2,1].yp));
  end;

  i:=1;
  repeat
    if (Round(deg_tune + i) mod 360) > 180 then
    begin
      Image1.Canvas.MoveTo(round(px + Pos[1,i].xp), round(py - Pos[1,i].yp));
      Image1.Canvas.LineTo(round(px + Pos[2,i].xp), round(py - Pos[2,i].yp));
    end;
    i += 6;
  until i >= 360;
end;

procedure TForm1.calc_pipa(deg_tune: Double; radius: double);
var
  i: Integer;
  j: Integer;
  temp: Double;
begin
  radius_tune := radius;
  deg := 0;
  i := 1;

  //inisialisasi lingkaran
  repeat
    rad := deg * PI / 180.0;

    Pos[1,i].x_pos := 0 + cos(rad) * radius_tune;
    Pos[1,i].y_pos := -Image1.Height;
    Pos[1,i].z_pos := 0 + sin(rad) * radius_tune;

    Pos[2,i].x_pos := 0 + cos(rad) * radius_tune;
    Pos[2,i].y_pos := Image1.Height;
    Pos[2,i].z_pos := 0 + sin(rad) * radius_tune;

    deg += 7;
    i += 1;
  until deg > 360;

  //rotasi sumbu y
  for i:=1 to 2 do
  begin
    for j:=1 to 360 do
    begin
      temp:= Pos[i,j].x_pos;
      Pos[i,j].x_pos:= Pos[i,j].x_pos * Cos(degtorad(deg_tune)) - Pos[i,j].z_pos * Sin(degtorad(deg_tune));
      Pos[i,j].z_pos:= temp * Sin(degtorad(deg_tune)) + Pos[i,j].z_pos * Cos(degtorad(deg_tune));
      Pos[i,j].y_pos:= Pos[i,j].y_pos;
    end;
  end;

  //proyeksi perspektif
  M := 500;
  for i:=1 to 2 do
  begin
    for j:=1 to 360 do
    begin
      if Pos[i,j].z_pos < M then
        begin
          Pos[i,j].xp := (round(Pos[i,j].x_pos / (1 - Pos[i,j].z_pos/M)));
          Pos[i,j].yp := (round(Pos[i,j].y_pos / (1 - Pos[i,j].z_pos/M)));
        end;
    end;
  end;
end;

procedure TForm1.gambar_pipa_depan(deg_tune: Double);
var
  i: integer;
begin
  Image1.Canvas.Pen.Color := clAqua;
  Image1.Canvas.Pen.Style := psSolid;
  Image1.Canvas.Pen.Width := 1;

  for i:=1 to 359 do
  begin
    if (Round(deg_tune + i) mod 360) < 180 then
    begin
      Image1.Canvas.MoveTo(px + round(Pos[1,i].xp), py - round(Pos[1,i].yp));
      Image1.Canvas.LineTo(px + round(Pos[2,i].xp), py - round(Pos[2,i].yp));
    end;
  end;
end;

procedure TForm1.gambar_pipa_belakang(deg_tune: Double);
var
  i: integer;
begin
  Image1.Canvas.Pen.Color := clAqua;
  Image1.Canvas.Pen.Style := psSolid;
  Image1.Canvas.Pen.Width := 1;

  for i:=1 to 359 do
  begin
    if (Round(deg_tune + i) mod 360) > 180 then
    begin
      Image1.Canvas.MoveTo(px + round(Pos[1,i].xp), py - round(Pos[1,i].yp));
      Image1.Canvas.LineTo(px + round(Pos[2,i].xp), py - round(Pos[2,i].yp));
    end;
  end;
end;

end.

