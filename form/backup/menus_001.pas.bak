unit menus_001;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ButtonPanel, StdCtrls, DbCtrls,
    utilidades_forms_Filtrar, utilidades_general;

type

    { TForm_menus_001 }

    TForm_menus_001 = class(TForm)
        ButtonPanel1: TButtonPanel;
        DBEdit_Codigo: TDBEdit;
        DBEdit_Descripcion: TDBEdit;
        Label1: TLabel;
        Label2: TLabel;

        procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
        procedure no_Tocar;
        procedure CancelButtonClick(Sender: TObject);
        procedure FormActivate(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure OKButtonClick(Sender: TObject);
        procedure Presentar_Datos;
    private
        { private declarations }
        private_Salir_OK : Boolean;
    public
        { public declarations }
        public_Solo_Ver      : Boolean;
        public_Menu_Worked   : Integer;
        public_Pulso_Aceptar : Boolean;
        public_Record_Rgtro  : TRecord_Rgtro_Comun;
    end;

var
    Form_menus_001: TForm_menus_001;

implementation

{$R *.lfm}

uses menus_000;

{ TForm_menus_001 }

procedure TForm_menus_001.FormCreate(Sender: TObject);
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

  { ****************************************************************************
    Solo para formularios que traten con datos
    **************************************************************************** }
    public_Solo_Ver := false;

    public_Record_Rgtro := UTI_Asignar_Fields_Menus(form_menus_000.SQLQuery_Menus);

    Presentar_Datos;
end;

procedure TForm_menus_001.CancelButtonClick(Sender: TObject);
begin
    private_Salir_OK     := True;
    public_Pulso_Aceptar := false;
end;

procedure TForm_menus_001.FormActivate(Sender: TObject);
begin
  if public_Solo_Ver = true then no_Tocar;
end;

procedure TForm_menus_001.OKButtonClick(Sender: TObject);
begin
    private_Salir_OK     := true;
    public_Pulso_Aceptar := true;
end;

procedure TForm_menus_001.Presentar_Datos;
begin
     /// guardar por lo que pueda pasar
end;

procedure TForm_menus_001.no_Tocar;
begin
     DBEdit_Codigo.Enabled := False;
end;

procedure TForm_menus_001.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var var_msg : TStrings;
begin
    var_msg := TStringList.Create;

    if public_Pulso_Aceptar = true then
    begin
        with form_menus_000.SQLQuery_Menus do
        begin
            if Trim(DBEdit_Codigo.Text) = '' then var_msg.Add( '* El código');

            if Trim(DBEdit_Descripcion.Text) <> '' then
                 FieldByName('Descripcion').asString := AnsiUpperCase(Trim(FieldByName('Descripcion').AsString))
            else var_msg.Add( '* La descripción');
        end;
    end;

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
            ********************************************************************
            Comprobaremos si no se generó algún error por falta de completar
            algun campo y si se salió con el botón Ok o Cancel
            ******************************************************************** }
            if (Trim(var_msg.Text) <> '') and (public_Pulso_Aceptar = true) then
                begin
                    UTI_GEN_Aviso(var_msg, 'FALTA POR COMPLETAR.-', True, False);
                    // var_msg.Free;
                    CloseAction := caNone;
                end
            else
                begin
                    // var_msg.Free;
                    CloseAction := caFree;
                end;
        end;

    var_msg.Free;
end;

end.

