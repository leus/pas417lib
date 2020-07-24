{ *
  * Based on C code of Paulo Soares
  * Port to Delphi and create VCL control by Axe Lin
  * }

unit PDF417Barcode;

interface

uses
  Windows, SysUtils, Classes, Controls, Graphics, pdf417lib;

type
  Latin1String = type AnsiString(28591);

  TPDF417Option = (poAutoErrorLevel, poFixedColumn, poFixedRow);
  TPDF417Options = set of TPDF417Option;

  TPDF417BarcodeVCL = class(TGraphicControl)
  private
    FData: Latin1String;
    FOptions: TPDF417Options;
    FBitmap: TBitmap;
    FErrorLevel: Integer;
    FAutoSize: Boolean;
    FFixedColumn, FFixedRow: Integer;
    FLineHeight: Integer;
    FDotSize: Integer;

    FMemoryBitmap: TBitmap;

    procedure SetOptions(Value: TPDF417Options);
    function GetBitmap: TBitmap;
    procedure SetErrorLevel(Value: Integer);
    procedure SetFixedColumn(Value: Integer);
    procedure SetFixedRow(Value: Integer);
    procedure SetLineHeight(Value: Integer);
    procedure SetDotSize(Value: Integer);

    procedure UpdateBarcode;
    function GetBitmapHeight: Integer;
    function GetBitmapWidth: Integer;
    function getData: Latin1String;
    procedure setData(const Value: Latin1String);
  protected
    procedure SetAutoSize(Value: Boolean); override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Bitmap: TBitmap read GetBitmap;
    function DrawTo(DC: HDC; X, Y: Integer; Zoom: Integer;
      AutoZoom: Boolean): Boolean;
    function DrawToRect(DC: HDC; R: TRect; Zoom: Integer;
      AutoZoom: Boolean): Boolean;
  published
    property Data: Latin1String read getData write setData;
    property Options: TPDF417Options read FOptions write SetOptions
      default [poAutoErrorLevel];
    property ErrorLevel: Integer read FErrorLevel write SetErrorLevel default 3;
    property AutoSize: Boolean read FAutoSize write SetAutoSize default True;
    property FixedColumn: Integer read FFixedColumn write SetFixedColumn
      default 0;
    property FixedRow: Integer read FFixedRow write SetFixedRow default 0;
    property LineHeight: Integer read FLineHeight write SetLineHeight default 3;
    property DotSize: Integer read FDotSize write SetDotSize default 1;
    property BitmapWidth: Integer read GetBitmapWidth;
    property BitmapHeight: Integer read GetBitmapHeight;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Linasoft', [TPDF417BarcodeVCL]);
end;

{ TPDF417BarcodeVCL }

constructor TPDF417BarcodeVCL.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAutoSize := True;
  FErrorLevel := 3;
  FOptions := [poAutoErrorLevel];
  FFixedColumn := 0;
  FFixedRow := 0;
  FLineHeight := 3;
  FDotSize := 1;
  FMemoryBitmap := TBitmap.Create;
  FMemoryBitmap.PixelFormat := pf1bit;
  FBitmap := TBitmap.Create;
  FBitmap.PixelFormat := pf1bit;
  UpdateBarcode;
end;

destructor TPDF417BarcodeVCL.Destroy;
begin
  FMemoryBitmap.Free;
  FBitmap.Free;
  inherited Destroy;
end;

function TPDF417BarcodeVCL.GetBitmap: TBitmap;
begin
  if FBitmap = nil then
  begin
    FBitmap := TBitmap.Create;
    FBitmap.PixelFormat := pf1bit;
  end;
  FBitmap.Width := FMemoryBitmap.Width * FDotSize;
  FBitmap.Height := FMemoryBitmap.Height * FLineHeight * FDotSize;
  FBitmap.Canvas.StretchDraw(Rect(0, 0, FBitmap.Width, FBitmap.Height),
    FMemoryBitmap);
  Result := FBitmap;
end;

function TPDF417BarcodeVCL.GetBitmapHeight: Integer;
begin
  if FMemoryBitmap.Empty then
    Exit(1);
  Result := FMemoryBitmap.Height;
end;

function TPDF417BarcodeVCL.GetBitmapWidth: Integer;
begin
  if FMemoryBitmap.Empty then
    Exit(1);
  Result := FMemoryBitmap.Width;
end;

function TPDF417BarcodeVCL.getData: Latin1String;
begin
  Result := FData;
end;

procedure TPDF417BarcodeVCL.Paint;
var
  X, Y, w, h: Integer;
begin
  Canvas.Brush.Color := clWhite;
  Canvas.FillRect(ClientRect);
  if FMemoryBitmap.Empty then
    Exit;
  w := FMemoryBitmap.Width * FDotSize;
  h := FMemoryBitmap.Height * FLineHeight * FDotSize;
  if AutoSize then
  begin
    Width := w;
    Height := h;
  end;
  if (Width <= w) or (Height <= h) then
  begin
    X := 0;
    Y := 0;
  end
  else
  begin
    X := (Width - w) div 2;
    Y := (Height - h) div 2;
  end;
  Canvas.StretchDraw(Rect(X, Y, X + w, Y + h), FMemoryBitmap);
end;

procedure TPDF417BarcodeVCL.SetAutoSize(Value: Boolean);
begin
  FAutoSize := Value;
  if FAutoSize then
    Invalidate;
end;

procedure TPDF417BarcodeVCL.setData(const Value: Latin1String);
begin
  FData := Value;
  UpdateBarcode;
end;

procedure TPDF417BarcodeVCL.SetLineHeight(Value: Integer);
begin
  if (Value < 1) or (Value > 10) then
    Value := 3;
  FLineHeight := Value;
  Invalidate;
end;

procedure TPDF417BarcodeVCL.SetDotSize(Value: Integer);
begin
  if Value < 1 then
    Value := 1;
  FDotSize := Value;
  Invalidate;
end;

procedure TPDF417BarcodeVCL.SetErrorLevel(Value: Integer);
begin
  if (Value < 0) or (Value > 8) then
    Value := 0;
  FErrorLevel := Value;
  UpdateBarcode;
end;

procedure TPDF417BarcodeVCL.SetFixedColumn(Value: Integer);
begin
  if Value < 0 then
    Value := 0;
  FFixedColumn := Value;
  if poFixedColumn in FOptions then
    UpdateBarcode;
end;

procedure TPDF417BarcodeVCL.SetFixedRow(Value: Integer);
begin
  if Value < 0 then
    Value := 0;
  FFixedRow := Value;
  if poFixedColumn in FOptions then
    UpdateBarcode;
end;

procedure TPDF417BarcodeVCL.SetOptions(Value: TPDF417Options);
begin
  FOptions := Value;
  UpdateBarcode;
end;

procedure TPDF417BarcodeVCL.UpdateBarcode;
var
  p: pdf417param;
  cols: Integer;
  k, i: Integer;
  X, Y: Integer;
  pclr: TColor;
begin
  if FData = '' then
  begin
    FMemoryBitmap.Free;
    FMemoryBitmap := TBitmap.Create;
    FMemoryBitmap.PixelFormat := pf1bit;
    Invalidate;
    Exit;
  end;

  pdf417init(@p);
  p.text := PAnsiChar(FData);
  if poAutoErrorLevel in FOptions then
    p.Options := p.Options or PDF417_AUTO_ERROR_LEVEL and
      (not PDF417_USE_ERROR_LEVEL)
  else
  begin
    p.Options := p.Options or PDF417_USE_ERROR_LEVEL;
    p.ErrorLevel := FErrorLevel;
  end;

  p.codeColumns := FFixedColumn;
  p.codeRows := FFixedRow;
  if (poFixedColumn in FOptions) and (poFixedRow in FOptions) then
    p.Options := p.Options or PDF417_FIXED_RECTANGLE
  else if poFixedColumn in FOptions then
    p.Options := p.Options or PDF417_FIXED_COLUMNS
  else if poFixedRow in FOptions then
    p.Options := p.Options or PDF417_FIXED_ROWS;

  try
{$IFOPT R+}
{$R-}
{$DEFINE TOGGLE_ROFF}
{$ENDIF}
    paintCode(@p);
{$IFDEF TOGGLE_ROFF}
{$R+}
{$ENDIF}
    if p.error <> PDF417_ERROR_SUCCESS then
    begin
      case p.error of
        PDF417_ERROR_TEXT_TOO_BIG:
          raise Exception.Create('The text is too big');
      end;
    end
    else                                        
    begin
      FMemoryBitmap.Width := p.bitColumns;
      FMemoryBitmap.Height := p.codeRows;
      cols := p.bitColumns div 8;
      if p.bitColumns mod 8 <> 0 then
        Inc(cols);
      X := 0;
      Y := 0;
      for k := 0 to p.lenBits - 1 do
      begin
        if (k mod cols = 0) and (k <> 0) then
        begin
          X := 0;
          Inc(Y);
        end;
        for i := 0 to 7 do
        begin
          if Ord(p.outBits[k]) and (1 shl (7 - i)) <> 0 then
            pclr := clBlack
          else
            pclr := clWhite;
          FMemoryBitmap.Canvas.Pixels[X, Y] := pclr;
          Inc(X);
        end;
      end;
    end;
    Invalidate;
  finally
    pdf417free(@p);
  end;
end;

function TPDF417BarcodeVCL.DrawTo(DC: HDC; X, Y: Integer; Zoom: Integer;
  AutoZoom: Boolean): Boolean;
var
  ZoomX, ZoomY: Integer;
begin
  Result := False;

  if Zoom <= 0 then
    Exit;

  if AutoZoom then
  begin
    ZoomX := Round(GetDeviceCaps(DC, LOGPIXELSX) / 100);
    ZoomY := Round(GetDeviceCaps(DC, LOGPIXELSY) / 100);
    if ZoomX < 1 then
      ZoomX := 1;
    if ZoomY < 1 then
      ZoomY := 1;
  end
  else
  begin
    ZoomX := Zoom * FDotSize;
    ZoomY := ZoomX;
  end;
  Result := StretchBlt(DC, X, Y, FMemoryBitmap.Width * ZoomX,
    Y + FMemoryBitmap.Height * ZoomY, FMemoryBitmap.Canvas.Handle, 0, 0,
    FMemoryBitmap.Width, FMemoryBitmap.Height, SRCCOPY);
end;

function TPDF417BarcodeVCL.DrawToRect(DC: HDC; R: TRect; Zoom: Integer;
  AutoZoom: Boolean): Boolean;
var
  ZoomX, ZoomY: Integer;
  X, Y: Integer;
begin
  Result := False;

  if Zoom <= 0 then
    Exit;

  if AutoZoom then
  begin
    ZoomX := Round(GetDeviceCaps(DC, LOGPIXELSX) / 100);
    ZoomY := Round(GetDeviceCaps(DC, LOGPIXELSY) / 100);
    if ZoomX < 1 then
      ZoomX := 1;
    if ZoomY < 1 then
      ZoomY := 1;
  end
  else
  begin
    ZoomX := Zoom * FDotSize;
    ZoomY := ZoomX;
  end;
  X := (R.Right - R.Left - FMemoryBitmap.Width * ZoomX) div 2;
  Y := (R.Bottom - R.Top - FMemoryBitmap.Height * ZoomY) div 2;
  Result := StretchBlt(DC, X, Y, FMemoryBitmap.Width * ZoomX,
    Y + FMemoryBitmap.Height * ZoomY, FMemoryBitmap.Canvas.Handle, 0, 0,
    FMemoryBitmap.Width, FMemoryBitmap.Height, SRCCOPY);
end;

end.
