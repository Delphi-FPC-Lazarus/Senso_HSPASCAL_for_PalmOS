unit Logo;

{$R LogoImagesC.ro}

interface

procedure DisplayFullScreenIntro(iWait:integer);
procedure DisplayClear;
procedure DisplayBlack;

implementation

uses Form, Rect, Window, Crt,
     BitmapUtil;

// ----------------------------------------------------

procedure DisplayFullScreenIntro(iWait:integer);
var n:integer;
    FullRect:    RectangleType;
begin
  RctSetRectangle(FullRect,0,0,160,160);
  WinDrawRectangle(FullRect,1);

  for n:= 1001 to 1069 do
  begin
    FullScreenBMP(n);
    delay(20);
  end;

  if iWait > 0 then
   delay(iWait);

  WinEraseRectangle(FullRect,1);
  FrmDrawForm(FrmGetActiveForm);

end;

// ----------------------------------------------------

procedure DisplayBlack;
var
    FullRect:    RectangleType;
begin
  RctSetRectangle(FullRect,0,0,160,160);
  WinDrawRectangle(FullRect,1);
end;

// ----------------------------------------------------

procedure DisplayClear;
var
    FullRect:    RectangleType;
begin
  RctSetRectangle(FullRect,0,0,160,160);
  WinEraseRectangle(FullRect,1);
end;

// ----------------------------------------------------


end.