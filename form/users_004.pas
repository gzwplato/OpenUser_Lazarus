unit users_004;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ButtonPanel, ExtCtrls, StdCtrls,
    utilidades_forms_Filtrar, utilidades_general, DbCtrls, Buttons;

type

    { TForm_users_004 }

    TForm_users_004 = class(TForm)
        ButtonPanel1: TButtonPanel;
        ComboBox_Tipo_Permiso: TComboBox;
        DBCheckBox1: TDBCheckBox;
        DBCheckBox2: TDBCheckBox;
        DBEdit_Descripcion_Permiso: TDBEdit;
        DBEdit_Nick: TDBEdit;
        DBEdit_Nick1: TDBEdit;
        Label1: TLabel;
        Label3: TLabel;
        Label4: TLabel;
        Panel1: TPanel;
        Panel_Mantenimiento: TPanel;

        procedure ComboBox_Tipo_PermisoChange(Sender: TObject);
        procedure Presentar_Datos;
        procedure FormActivate(Sender: TObject);
        procedure no_Tocar;
        procedure CancelButtonClick(Sender: TObject);
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
    Form_users_004: TForm_users_004;

implementation

{$R *.lfm}

uses menu, users_000;

{ TForm_users_004 }

procedure TForm_users_004.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var var_msg : TStrings;
begin
    var_msg := TStringList.Create;

    if public_Pulso_Aceptar = true then
    begin
        with form_users_000.SQLQuery_Users_Menus_Permisos do
        begin
            if (ComboBox_Tipo_Permiso.Text) = '' then
                var_msg.Add( 'No has elegido el tipo de OPERACION.')
            else
                begin
                    if ComboBox_Tipo_Permiso.ItemIndex = 0 then FieldByName('Tipo_CRUD').Value := 'A';
                    if ComboBox_Tipo_Permiso.ItemIndex = 1 then FieldByName('Tipo_CRUD').Value := 'M';
                    if ComboBox_Tipo_Permiso.ItemIndex = 2 then FieldByName('Tipo_CRUD').Value := 'B';
                    if ComboBox_Tipo_Permiso.ItemIndex = 3 then FieldByName('Tipo_CRUD').Value := 'I';
                    if ComboBox_Tipo_Permiso.ItemIndex = 4 then
                    begin
                        if Trim(DBEdit_Descripcion_Permiso.Text) = '' then
                             var_msg.Add('Eligió la opción OTRAS, pero no introdujo la descripción')
                        else
                            begin
                                 FieldByName('Tipo_CRUD').Value := 'O';
                                 FieldByName('Descripcion').asString := AnsiUpperCase(FieldByName('Descripcion').asString);
                            end;
                    end;
                end;
        end;
    end;

    if private_Salir_OK = False then
        begin
          { ********************************************************************
            Intento BitBtn_SALIR de la aplicación de un modo no permitido.
            ********************************************************************
            Pero si desde el menu principal está a true la variable
            public_Salir_Ok, significa que hay que salir si o si pues se pulsó
            cancelar al preguntar otra vez por la contraseña
            ******************************************************************** }
            if form_Menu.public_Salir_OK = False then CloseAction := caNone;
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

procedure TForm_users_004.FormCreate(Sender: TObject);
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

      public_Record_Rgtro := UTI_Asignar_Fields_Usuarios_Menus_Permisos(form_users_000.SQLQuery_Users_Menus_Permisos);

      Presentar_Datos;
end;

procedure TForm_users_004.OKButtonClick(Sender: TObject);
begin
    private_Salir_OK     := True;
    public_Pulso_Aceptar := true;
end;

procedure TForm_users_004.CancelButtonClick(Sender: TObject);
begin
    private_Salir_OK     := True;
    public_Pulso_Aceptar := false;
end;

procedure TForm_users_004.no_Tocar;
begin
     Panel_Mantenimiento.Enabled := False;
end;

procedure TForm_users_004.FormActivate(Sender: TObject);
begin
    if public_Solo_Ver = true then no_Tocar;
end;

procedure TForm_users_004.Presentar_Datos;
begin
    // guardar por lo que pueda pasar
    with ComboBox_Tipo_Permiso.Items do
    begin
        Clear;
        Add('INSERTAR / CREAR');
        Add('MODIFICAR / EDITAR');
        Add('BORRAR / DAR DE BAJA');
        Add('IMPRIMIR');
        Add('OTROS');
    end;

    with form_users_000.SQLQuery_Users_Menus_Permisos do
    begin
         if FieldByName('Tipo_CRUD').Value = 'A' then ComboBox_Tipo_Permiso.ItemIndex := 0;
         if FieldByName('Tipo_CRUD').Value = 'M' then ComboBox_Tipo_Permiso.ItemIndex := 1;
         if FieldByName('Tipo_CRUD').Value = 'B' then ComboBox_Tipo_Permiso.ItemIndex := 2;
         if FieldByName('Tipo_CRUD').Value = 'I' then ComboBox_Tipo_Permiso.ItemIndex := 3;
         if FieldByName('Tipo_CRUD').Value = 'O' then ComboBox_Tipo_Permiso.ItemIndex := 4;
    end;
end;

procedure TForm_users_004.ComboBox_Tipo_PermisoChange(Sender: TObject);
begin
    if ComboBox_Tipo_Permiso.ItemIndex = 4 then
         DBEdit_Descripcion_Permiso.Visible := true
    else DBEdit_Descripcion_Permiso.Visible := false;
end;

end.

