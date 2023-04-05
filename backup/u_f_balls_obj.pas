unit u_f_balls_obj;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  DateUtils;

type

  { TForm1 }

  vec2f = record
    x,y:real;
  end;

  vec2i = record
    x,y:integer;
  end;

  TFlyer = class
    protected
      pos:vec2i;
      rpos:vec2f;
      r:integer;
      speed:real;
      moveCoeff:vec2f;
      bColour:TColor;
      parentCanvas:TCanvas;
      procedure CheckCollisons(moveSpace:TRect);
    public
      constructor Create(coords:vec2i; ir:integer; colour:TColor; iSpeed:real; dir:vec2f; pCanvas:TCanvas);
      procedure Move(dt:real); Virtual; Abstract;
      procedure DrawThyself; Virtual; Abstract;
  end;

  TBall = class(TFlyer)
    public
      constructor Create(coords:vec2i; ir:integer; colour:TColor; iSpeed:real; dir:vec2f; pCanvas:TCanvas);
      procedure Move(dt:real); Override;
      procedure DrawThyself; Override;
  end;

  TRectBall = class(TFlyer)
    public
      constructor Create(coords:vec2i; ir:integer; colour:TColor; iSpeed:real; dir:vec2f; pCanvas:TCanvas);
      procedure Move(dt:real); Override;
      procedure DrawThyself; Override;
  end;

  TSinBall = class(TFlyer)
    private
      Ampl,Freq, BSLevel:real;
      pos_arr:array of vec2f;
      draw_tail:boolean;
    public
      constructor Create(coords:vec2i; ir:integer; colour:TColor; iSpeed:real; dir:vec2f; pCanvas:TCanvas; sbAmpl, sbFreq, sbLevel:real; bDrawTail:boolean);
      procedure Move(dt:real); Override;
      procedure DrawThyself; Override;
  end;

  TFlyersRenderer = class
    private
      arrObjs:array of TFlyer;
      parentCanvas:TCanvas;
      deltaTime:real;
      ts_before:TDateTime;
      ts_now:TDateTime;
      procedure RenderObjects;
      procedure MoveObjects;
      procedure GetDeltaTime;
      procedure PrepField;
    public
      constructor Create(canvasToWork:TCanvas);
      procedure AddObject(otp:integer);
      procedure PerfWork;
  end;

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Image1: TImage;
    Panel1: TPanel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure DoBallStuff;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  objManager:TFlyersRenderer;
  do_exit:boolean;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  do_exit:=false;
  objManager:=TFlyersRenderer.Create(Image1.Canvas);
end;

procedure TForm1.DoBallStuff;
begin
  while not do_exit do
  begin
    objManager.PerfWork;
    Application.ProcessMessages;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  DoBallStuff;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  objManager.AddObject(1);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  objManager.AddObject(2);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  objManager.AddObject(0);
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  do_exit:=True;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  Image1.Picture.Bitmap.Width:=Image1.Width;
  Image1.Picture.Bitmap.Height:=Image1.Height;
end;

procedure TForm1.FormShow(Sender: TObject);
begin

end;

constructor TFlyer.Create(coords:vec2i; ir:integer; colour:TColor; iSpeed:real; dir:vec2f; pCanvas:TCanvas);
begin
  //set coords
  rpos.x:=coords.x;
  rpos.y:=coords.y;
  pos.x:=coords.x;
  pos.y:=coords.y;
  //set r
  r:=ir;
  //set colour
  bColour:=colour;
  //set speed
  speed:=iSpeed;
  //set move coeffs
  moveCoeff:=dir;
  //set parent canvas
  parentCanvas:=pCanvas;
end;

procedure TFlyer.CheckCollisons(moveSpace:TRect);
begin
  //hitting wall conditions
  if (rpos.x < r) then
  begin
    moveCoeff.x:=moveCoeff.x * (-1);
    rpos.x:=r;
    pos.x:=round(rpos.x);
  end;
  if (rpos.x > (moveSpace.Width-r)) then
  begin
    moveCoeff.x:=moveCoeff.x * (-1);
    rpos.x:=moveSpace.Width-r;
    pos.x:=round(rpos.x);
  end;
  if (rpos.y < r) then
  begin
    moveCoeff.y:=moveCoeff.y * (-1);
    rpos.y:=r;
    pos.y:=round(rpos.y);
  end;
  if (rpos.y > (moveSpace.Height-r)) then
  begin
    moveCoeff.y:=moveCoeff.y * (-1);
    rpos.y:=moveSpace.Height-r;
    pos.y:=round(rpos.y);
  end;
end;

constructor TBall.Create(coords:vec2i; ir:integer; colour:TColor; iSpeed:real; dir:vec2f; pCanvas:TCanvas);
begin
  Inherited create(coords,ir,colour,iSpeed,dir,pCanvas);
end;

procedure TBall.Move(dt:real);
var dpos:vec2f;
begin
  dpos.x:=speed * dt * moveCoeff.x;
  dpos.y:=speed * dt * moveCoeff.y;

  rpos.x:=rpos.x + dpos.x;
  rpos.y:=rpos.y + dpos.y;

  pos.x:=Round(rpos.x);
  pos.y:=Round(rpos.y);

  CheckCollisons(rect(0,0,parentCanvas.Width,parentCanvas.Height));
end;


procedure TBall.DrawThyself;
begin
  with parentCanvas do
  begin
    Pen.Color:=clBlack;
    Brush.Color:=bColour;
    Ellipse(pos.x-r,pos.y-r,pos.x+r,pos.y+r);
  end;
end;


constructor TRectBall.Create(coords:vec2i; ir:integer; colour:TColor; iSpeed:real; dir:vec2f; pCanvas:TCanvas);
begin
  Inherited create(coords,ir,colour,iSpeed,dir,pCanvas);
end;

procedure TRectBall.Move(dt:real);
var dpos:vec2f;
begin
  dpos.x:=speed * dt * moveCoeff.x;
  dpos.y:=speed * dt * moveCoeff.y;

  rpos.x:=rpos.x + dpos.x;
  rpos.y:=rpos.y + dpos.y;

  pos.x:=Round(rpos.x);
  pos.y:=Round(rpos.y);

  CheckCollisons(rect(0,0,parentCanvas.Width,parentCanvas.Height));
end;


procedure TRectBall.DrawThyself;
begin
  with parentCanvas do
  begin
    Pen.Color:=clBlack;
    Brush.Color:=bColour;
    Rectangle(pos.x-r,pos.y-r,pos.x+r,pos.y+r);
  end;
end;


constructor TSinBall.Create(coords:vec2i; ir:integer; colour:TColor; iSpeed:real; dir:vec2f; pCanvas:TCanvas; sbAmpl, sbFreq, sbLevel:real; bDrawTail:boolean);
begin
  Inherited create(coords,ir,colour,iSpeed,dir,pCanvas);
  Ampl:=sbAmpl;
  Freq:=sbFreq;
  BSLevel:=sbLevel;
  draw_tail:=bDrawTail;
end;

procedure TSinBall.Move(dt:real);
var dpos:vec2f;
begin

  dpos.x:=speed * dt * moveCoeff.x;
  rpos.x:=rpos.x + dpos.x;
  rpos.y:=Ampl*sin(0.01*Freq*rpos.x*3.14/180) + BSLevel;

  if (draw_tail) then
  begin
    setlength(pos_arr,Length(pos_arr)+1);
    pos_arr[High(pos_arr)]:=rpos;
  end;

  pos.x:=Round(rpos.x);
  pos.y:=Round(rpos.y);

  CheckCollisons(rect(0,0,parentCanvas.Width,parentCanvas.Height));
end;


procedure TSinBall.DrawThyself;
var i,l:integer;
begin
  with parentCanvas do
  begin
    l:=Length(pos_arr);
    Pen.Color:=bColour;
    if l>1 then
    for i:=0 to l-2 do
    begin
      MoveTo(round(pos_arr[i].x),round(pos_arr[i].y));
      LineTo(round(pos_arr[i+1].x),round(pos_arr[i+1].y));
    end;

    Pen.Color:=clBlack;
    Brush.Color:=bColour;
    Ellipse(pos.x-r,pos.y-r,pos.x+r,pos.y+r);
  end;
end;


procedure TFlyersRenderer.AddObject(otp:integer);
var creationPos:vec2i;
    tr:integer;
    tc:TColor;
    tv:integer;
    tdir:vec2f;
    AA, FF, baselevel:real;
begin

  SetLength(arrObjs,length(arrObjs)+1);
  tr:=Random(10)+10;
  tc:=RGBToColor(random(255),random(255),random(255));
  tv:=random(100)+20;

  if (otp=0) then
  begin
    creationPos.x:=round(parentCanvas.Width/2);
    creationPos.y:=round(parentCanvas.Height/2);
    tdir.x:=random(2); if tdir.x=0 then tdir.x:=-1;
    tdir.y:=random(2); if tdir.y=0 then tdir.y:=-1;
    arrObjs[high(arrObjs)]:=TBall.Create(
        creationPos, tr, tc, tv, tdir, parentCanvas );
  end;

  if (otp=1) then
  begin
    creationPos.x:=random(parentCanvas.Width-2*tr)+tr;
    creationPos.y:=random(parentCanvas.Height-2*tr)+tr;
    if (random(2)=0) then
    begin
      tdir.x:=random(2); if tdir.x=0 then tdir.x:=-1;
      tdir.y:=0;
    end
    else
    begin
      tdir.x:=0;
      tdir.y:=random(2); if tdir.y=0 then tdir.y:=-1;
    end;
    arrObjs[high(arrObjs)]:=TRectBall.Create(
        creationPos, tr, tc, tv, tdir, parentCanvas );
  end;

  if (otp=2) then
  begin
    creationPos.x:=random(parentCanvas.Width-2*tr)+tr;
    creationPos.y:=random(parentCanvas.Height-2*tr)+tr;

    baselevel:=creationPos.y;

    if (baselevel<=parentCanvas.Height/2) then
    begin
      AA:=(baselevel-tr)*0.5;
    end
    else
    begin
      AA:=(parentCanvas.Height-tr-baselevel)*0.5;
    end;

    FF:=random(100)+1;

    tdir.x:=random(2); if tdir.x=0 then tdir.x:=-1;
    tdir.y:=0;

    arrObjs[high(arrObjs)]:=TSinBall.Create(
        creationPos, tr, tc, tv, tdir, parentCanvas, AA, FF, baselevel, false);
  end;

end;

constructor TFlyersRenderer.Create(canvasToWork:TCanvas);
begin
  parentCanvas:=canvasToWork;
  ts_before:=Now;
  ts_now:=Now;
end;

procedure TFlyersRenderer.GetDeltaTime;
VAR cdt:INTEGER;
begin
  ts_before:=ts_now;
  ts_now:=Now;

  cdt:=MilliSecondsBetween(ts_now,ts_before);

  deltaTime:=cdt/1000;
end;

procedure TFlyersRenderer.PrepField;
begin
  parentCanvas.Pen.Color:=clBlack;
  parentCanvas.Brush.Color:=clWhite;
  parentCanvas.Rectangle(0,0,parentCanvas.Width,parentCanvas.Height);
end;

procedure TFlyersRenderer.PerfWork;
begin
  GetDeltaTime;
  MoveObjects;
  PrepField;
  RenderObjects;
end;

procedure TFlyersRenderer.MoveObjects;
var i,l:integer;
begin
  l:=length(arrObjs);
  if (l>0) then
  for i:=0 to l-1 do
    arrObjs[i].move(deltaTime);
end;

procedure TFlyersRenderer.RenderObjects;
  var i,l:integer;
begin
  l:=length(arrObjs);
  if (l>0) then
  for i:=0 to l-1 do
    arrObjs[i].DrawThyself;
end;

end.

