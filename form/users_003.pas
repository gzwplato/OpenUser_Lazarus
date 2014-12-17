unit users_003;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ButtonPanel, ExtCtrls, DbCtrls,
    db, utilidades_forms_Filtrar, utilidades_general, StdCtrls, EditBtn, maskedit, Buttons;

type

    { TForm_users_003 }

    TForm_users_003 = class(TForm)
        Boton_Elegir_Modulo: TBitBtn;
        ButtonPanel1: TButtonPanel;
        DBCheckBox1: TDBCheckBox;
        DBCheckBox_Obligar_Motivo: TDBCheckBox;
        DBEdit_Nick: TDBEdit;
        Edit_Descripcion_Modulo: TEdit;
        Label1: TLabel;
        Label2: TLabel;
        Panel1: TPanel;
        Panel_Mantenimiento: TPanel;

        procedure Boton_Elegir_ModuloClick(Sender: TObject);
        procedure Edit_Descripcion_ModuloClick(Sender: TObject);
        procedure Presentar_Datos;
        procedure CancelButtonClick(Sender: TObject);
        procedure FormActivate(Sender: TObject);
        procedure no_Tocar;

        procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
        procedure FormCreate(Sender: TObject);
        procedure OKButtonClick(Sender: TObject);
    private
        { private declarations }
        private_Salir_OK : Boolean;
    public
        { public declarations }
        public_Menu_Worked   : Integer;
        public_Solo_Ver      : Boolean;
        public_Pulso_Aceptar : Boolean;
        public_Record_Rgtro  : TRecord_Rgtro_Comun;
    end;

var
    Form_users_003: TForm_users_003;

implementation

{$R *.lfm}

uses users_000;

{ TForm_users_003 }

procedure TForm_users_003.FormClose(Sender: TObject; var CloseAction: TCloseAction);
    var var_msg : TStrings;
begin
    var_msg := TStringList.Create;

    if public_Pulso_Aceptar = true then
    begin
        with form_users_000.SQLQuery_Users_Menus do
        begin
            if Trim(FieldByName('Id_Menus').AsString) = '' then var_msg.Add( '* El módulo / menú');
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

procedure TForm_users_003.FormCreate(Sender: TObject);
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
  { **************************************************************************** }

    public_Record_Rgtro := UTI_Asignar_Fields_Usuarios_Menus(form_users_000.SQLQuery_Users_Menus);

    Presentar_Datos;
end;

procedure TForm_users_003.OKButtonClick(Sender: TObject);
begin
    private_Salir_OK     := True;
    public_Pulso_Aceptar := true;
end;

procedure TForm_users_003.CancelButtonClick(Sender: TObject);
begin
    private_Salir_OK     := True;
    public_Pulso_Aceptar := false;
end;

procedure TForm_users_003.no_Tocar;
begin
     Panel_Mantenimiento.Enabled := False;
end;

procedure TForm_users_003.FormActivate(Sender: TObject);
begin
    if public_Solo_Ver = true then no_Tocar;
end;

procedure TForm_users_003.Presentar_Datos;
begin
     Edit_Descripcion_Modulo.Text := form_users_000.SQLQuery_Users_Menus.FieldByName('OT_Descripcion_Menu').AsString;
end;

procedure TForm_users_003.Boton_Elegir_ModuloClick(Sender: TObject);
var var_Registro : TRecord_Rgtro_Comun;
begin
    var_Registro := UTI_Abrir_Form( true, true, '', 40 );
    if var_Registro.Id <> '' then
    begin
         Form_Users_000.SQLQuery_Users_Menus.FieldByName('Id_Menus').AsString := Trim(var_Registro.Id);
         Edit_Descripcion_Modulo.Text := var_Registro.MENUS_Descripcion;
    end;
end;

procedure TForm_users_003.Edit_Descripcion_ModuloClick(Sender: TObject);
var var_msg : TStrings;
begin
    var_msg := TStringList.Create;
    var_msg.Add('¿QUITAMOS el MODULO / MENU');
    if UTI_GEN_Aviso(var_msg, '¿SEGURO?', True, True) = True then
    begin
         Form_Users_000.SQLQuery_Users_Menus.FieldByName('Id_Menus').Clear;
         Edit_Descripcion_Modulo.Text := '';
    end;
    FreeAndNil(var_msg);
end;

end.

