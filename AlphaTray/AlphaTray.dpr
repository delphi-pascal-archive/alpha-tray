program AlphaTray;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  AlphaUtils in 'AlphaUtils.pas';

{$R *.res}
{$R WindowsXP.res}

begin
  Application.Initialize;
  Application.Title := 'AlphaTray';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
