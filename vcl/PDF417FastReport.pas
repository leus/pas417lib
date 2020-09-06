unit PDF417FastReport;

interface

uses frxClass, Graphics, PDF417Barcode, Classes;

type
  Latin1String = type AnsiString(28591);

  TfrxPDF417 = class(TfrxView)
  private
    FBarcode: TPDF417BarcodeVCL;
    FHAlign: TfrxHAlign;
    procedure setHAlign(const Value: TfrxHAlign);
    procedure setBarcodeData(const Value: String);
    function getBarcodeData: String;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX,
      OffsetY: Extended); override;
    procedure GetData; override;
    class function GetDescription: String; override;
  published
    property Data: String read getBarcodeData write setBarcodeData;
    property Font;
    property HorizontalAlign: TfrxHAlign read FHAlign write setHAlign;
    property DataSet;
    property DataField;
  end;

implementation

uses frxDsgnIntf, Types, Math, Variants;

{ TfrxPDF417 }

constructor TfrxPDF417.Create(AOwner: TComponent);
begin
  inherited;
  FBarcode := TPDF417BarcodeVCL.Create(nil);
  FBarcode.AutoSize := false;
  FBarcode.ErrorLevel := 5;
  FBarcode.Options := [];
end;

destructor TfrxPDF417.Destroy;
begin
  FBarcode.Free;
  inherited;
end;

procedure TfrxPDF417.Draw(Canvas: TCanvas;
  ScaleX, ScaleY, OffsetX, OffsetY: Extended);
var
  HLineSize, VLineSize, DotSize: Integer;
begin
  BeginDraw(Canvas, ScaleX, ScaleY, OffsetX, OffsetY);
  DrawBackground;
  DrawFrame;

  // DX is the target width in pixels.
  FBarcode.DotSize := 1;
  FBarcode.AutoSize := true;
  FBarcode.Invalidate;

  // Width equals the number of vert lines
  HLineSize := FDX div FBarcode.BitmapWidth;
  VLineSize := FDY div FBarcode.BitmapHeight;

  DotSize := Min(HLineSize, VLineSize);

  if DotSize = 0 then
    DotSize := 1;

  FBarcode.DotSize := DotSize;
  FCanvas.StretchDraw(Rect(FX, FY, FX1, FY1), FBarcode.Bitmap);
end;

function TfrxPDF417.getBarcodeData: String;
begin
  Result := FBarcode.Data;
end;

procedure TfrxPDF417.GetData;
var
  TmpStr: Latin1String;
begin
  inherited;
  if IsDataField then
  begin
    TmpStr := Latin1String(VarToStr(DataSet.Value[DataField]));
    FBarcode.Data := TmpStr;
  end;
end;

class function TfrxPDF417.GetDescription: String;
begin
  Result := 'PDF 417 Barcode object';
end;

procedure TfrxPDF417.setBarcodeData(const Value: String);
begin
  FBarcode.Data := Latin1String(Value);
end;


procedure TfrxPDF417.setHAlign(const Value: TfrxHAlign);
begin
  FHAlign := Value;
end;

{ registration }

initialization

frxObjects.RegisterObject(TfrxPDF417, nil, '');

finalization

{ delete component from list of available ones }
frxObjects.Unregister(TfrxPDF417);

end.
