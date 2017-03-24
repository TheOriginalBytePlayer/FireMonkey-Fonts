unit FireMonkeyTestForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, FMX.Canvas.D2D, Winapi.D2D1,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Platform.Win,
  WinAPI.Messages, FMX.Objects;

type
  TForm27 = class(TForm)
    FireMonkeyLabel: TLabel;
    CloseButton: TButton;
    procedure FormCreate(Sender: TObject);
    procedure CloseButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form27: TForm27;

implementation

{$R *.fmx}

uses WinAPI.Windows, FMXFontInstaller;


procedure TForm27.CloseButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TForm27.FormCreate(Sender: TObject);
begin
  if not IsKnownFont('Assimilate') then
     FireMonkeyLabel.Text := 'Assimilate Font was NOT found'
  else
     FireMonkeyLabel.Text := 'Assimilate WAS Font found... and USED?';
end;

end.
