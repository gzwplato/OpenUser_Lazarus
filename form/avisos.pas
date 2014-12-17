unit avisos;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, FileUtil, Forms, Controls, Graphics, StdCtrls,
    ExtCtrls, Buttons, ButtonPanel;

type

    { TForm_Avisos }

    TForm_Avisos = class(TForm)
        ButtonPanel_Avisos: TButtonPanel;
        Memo_Aviso: TMemo;

        procedure CancelButtonClick(Sender: TObject);
        procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
        procedure FormCreate(Sender: TObject);
        procedure Memo_AvisoMouseMove(Sender: TObject; Shift: TShiftState; X,
            Y: Integer);
        procedure OKButtonClick(Sender: TObject);
    private
        { private declarations }
        private_Salir_OK : Boolean;
    public
        { public declarations }
        public_Pulso_Aceptar : Boolean;
    end;

var
    Form_Avisos: TForm_Avisos;

implementation

{$R *.lfm}

{ TForm_Avisos }

procedure TForm_Avisos.FormCreate(Sender: TObject);
begin
  { ****************************************************************************
    Obligado en cada formulario para no olvidarlo
    **************************************************************************** }
    with Self do
    begin
        Position    := poScreenCenter;
        BorderIcons := [];
        BorderStyle := bsSingle;
    end;

    private_Salir_OK := false;
  { **************************************************************************** }
end;

procedure TForm_Avisos.Memo_AvisoMouseMove(Sender: TObject; Shift: TShiftState;
    X, Y: Integer);
begin
    Screen.Cursor := crHourGlass;
end;

procedure TForm_Avisos.OKButtonClick(Sender: TObject);
begin
    private_Salir_OK     := True;
    public_Pulso_Aceptar := true;
end;

procedure TForm_Avisos.CancelButtonClick(Sender: TObject);
begin
    private_Salir_OK     := True;
    public_Pulso_Aceptar := false;
end;

procedure TForm_Avisos.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
    if private_Salir_OK = False then
        begin
          { ********************************************************************
            Intento salir de la aplicación de un modo no permitido
            ******************************************************************** }
            CloseAction := caNone;
        end
    else
        begin
          { ********************************************************************
            Fue correcto el modo como quiere salir de la aplicación
            ******************************************************************** }
        end;
end;

end.

