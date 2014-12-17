unit arrancar;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs;

type

    { TForm_Arrancar }

    TForm_Arrancar = class(TForm)
        procedure FormCreate(Sender: TObject);
    private
        { private declarations }
    public
        { public declarations }
    end;

var
    Form_Arrancar: TForm_Arrancar;

implementation

{$R *.lfm}

uses menu;

{ TForm_Arrancar }

procedure TForm_Arrancar.FormCreate(Sender: TObject);
begin
    Application.CreateForm(TForm_Menu, Form_Menu);
    Form_Menu.ShowModal;
    FreeAndNil(Form_Menu);
end;

end.

