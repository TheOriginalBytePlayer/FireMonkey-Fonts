unit FMXFontInstaller;
interface

{$IFNDEF MSWINDOWS}
   {$MESSAGE ERROR 'Windows Only Unit'}
{$ENDIF}

uses System.SysUtils, System.Classes, WinAPI.Windows, Winapi.Messages;

{.$R FontResource.res}
{$R 'AssimilateFont.res'}

function IsKnownFont(const FontFamily:String):boolean;
procedure GetLoadedFonts(const ToList:TStrings);

implementation

uses FMX.Canvas.D2D, FMX.Platform.win;


var
  TempPath:String;
  AddedFonts:TStringList;

function EnumFontsProc(var LogFont: TLogFont; var TextMetric: TTextMetric;
  FontType: Integer; Data: Pointer): Integer; stdcall;
var
  S: TStrings;
  Temp: string;
begin
  S := TStrings(Data);
  Temp := LogFont.lfFaceName;
  if (S.Count = 0) or (AnsiCompareText(S[S.Count - 1], Temp) <> 0) then
    S.Add(Temp);
  Result := 1;
end;


procedure CollectFonts(FontList: TStringList);
var
  DC: WinAPI.Windows.HDC;
  LFont: TLogFont;
begin
  DC := GetDC(0);
  FillChar(LFont, sizeof(LFont), 0);
  LFont.lfCharset := DEFAULT_CHARSET;
  EnumFontFamiliesEx(DC, LFont, @EnumFontsProc,
    WinAPI.Windows.LPARAM(FontList), 0);
  ReleaseDC(0, DC);
end;

function IsKnownFont(const FontFamily:String):boolean;
var
  AvailableFonts: TStringList;
begin
  AvailableFonts := TStringList.Create;
  CollectFonts(AvailableFonts);
  result:=AvailableFonts.IndexOf(FontFamily) > -1;
  AvailableFonts.Free;
end;

function LoadTemporaryFonts:Boolean;
var
  FontID: Integer;
  ResStream: tResourceStream;

function GetTempFileNameWithExt(WithExtension: String): String;
var
  XCount: Integer;
  ResultPath: String;
begin
  ResultPath := TempPath + 'tempFile';
  XCount := 99;
  repeat
    Inc(XCount);
    Result := ResultPath + IntToHex(XCount, 3) + WithExtension;
  until not FileExists(Result);
end;

begin
  result:=false;
  if not assigned(AddedFonts) then
    AddedFonts := TStringList.Create;
  FontID := 1;
  While FindResource(hinstance, PChar(FontID), RT_FONT) <> 0 do
  begin
    ResStream := tResourceStream.CreateFromID(hinstance, FontID, RT_FONT);
    AddedFonts.Add(GetTempFileNameWithExt('.ttf'));
    ResStream.SaveToFile(AddedFonts[AddedFonts.Count - 1]);
    Result:=(AddFontResource(PChar(AddedFonts[AddedFonts.Count - 1])) <> 0) or Result;
    ResStream.Free;
    Inc(FontID);
  end;

  if not Result then
     exit;

  //I don't think these are needed but it seems like good form
  PostMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0);
 //Went even more specific and sent it directly to the application
  PostMessage(ApplicationHWnd, WM_FONTCHANGE, 0, 0);

  UnregisterCanvasClasses;
  RegisterCanvasClasses;
end;

procedure UnloadTemporaryFonts;
var
  sr:TSearchRec;
begin
  if FindFirst(TempPath+'Temp*.ttf',faAnyFile,sr)=0 then
  repeat
     if (Copy(sr.Name,1,1)='.') or (sr.Attr and faDirectory = faDirectory) then
      Continue;
     RemoveFontResource(PWideChar(TempPath+sr.Name));
     DeleteFile(PWideChar(TempPath+sr.Name));
  until FindNext(sr) <> 0;
  System.SysUtils.FindClose(sr);
  while AddedFonts.Count > 0 do
   begin
      RemoveFontResource(PWideChar(AddedFonts[0]));
      AddedFonts.Delete(0);
   end;
  PostMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0);
 //Went even more specific and sent it directly to the application
  PostMessage(ApplicationHWnd, WM_FONTCHANGE, 0, 0);
  FreeAndNil(AddedFonts);
end;


procedure GetLoadedFonts(const ToList:TStrings);
begin
   if Assigned(AddedFonts) then
     ToList.Assign(AddedFonts);
end;

initialization
   SetLength(TempPath, 256);
   SetLength(TempPath, GetTempPath(256, @TempPath[1]));
   if (TempPath <> '') and (TempPath[Length(TempPath)] <> '\') then
     TempPath:=TempPath+'\';
   LoadTemporaryFonts;

finalization
   UnloadTemporaryFonts;
end.
