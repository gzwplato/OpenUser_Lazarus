unit users_002;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, DbCtrls, ButtonPanel,
    utilidades_forms_Filtrar, utilidades_general, ExtCtrls, Buttons, maskedit, EditBtn;

type

    { TForm_users_002 }

    TForm_users_002 = class(TForm)
        ButtonPanel1: TButtonPanel;
        DateEdit_Dia_Fin: TDateEdit;
        DateEdit_Dia_Inicio: TDateEdit;
        DBCheckBox1: TDBCheckBox;
        DBCheckBox2: TDBCheckBox;
        DBCheckBox3: TDBCheckBox;
        DBEdit_Nick: TDBEdit;
        DBEdit_pwd: TDBEdit;
        GroupBox2: TGroupBox;
        Label1: TLabel;
        Label3: TLabel;
        Label_Fecha: TLabel;
        Label_Fecha1: TLabel;
        MaskEdit_Hora_Fin: TMaskEdit;
        MaskEdit_Hora_Inicio: TMaskEdit;
        Panel1: TPanel;
        Panel_Mantenimiento: TPanel;

        procedure Presentar_Datos;
        procedure ComprobarFechas_2( param_msg : TStrings );
        procedure ComprobarFechas( param_msg : TStrings );
        procedure Actualizar_Campos_Fecha_Hora;
        procedure no_Tocar;

        procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
        procedure CancelButtonClick(Sender: TObject);
        procedure FormActivate(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure OKButtonClick(Sender: TObject);
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
    Form_users_002: TForm_users_002;

implementation

{$R *.lfm}

uses menu, users_000;

{ TForm_users_002 }

procedure TForm_users_002.FormCreate(Sender: TObject);
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

    public_Record_Rgtro := UTI_Asignar_Fields_Usuarios_Passwords(form_users_000.SQLQuery_Users_Passwords);

    Presentar_Datos;
end;

procedure TForm_users_002.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var var_msg : TStrings;
begin
    var_msg := TStringList.Create;

    if public_Pulso_Aceptar = true then
    begin
        with form_users_000.SQLQuery_Users_Passwords do
        begin
            if Trim(FieldByName('Password').AsString) = '' then var_msg.Add( '* La contraseña');

            if Trim(FieldByName('Password_Expira_SN').AsString) = 'S' then
                ComprobarFechas(var_msg)
            else
                begin
                    FieldByName('Password_Expira_Inicio').Clear;
                    FieldByName('Password_Expira_Fin').Clear;
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

procedure TForm_users_002.Actualizar_Campos_Fecha_Hora;
var var_Fecha_Hora : ShortString;
begin
    WITH Form_users_000.SQLQuery_Users_Passwords DO
    BEGIN
        // INICIO
        var_Fecha_Hora := '';
        if DateEdit_Dia_Inicio.Text <> '  /  /    ' then var_Fecha_Hora := DateEdit_Dia_Inicio.Text;

        if MaskEdit_Hora_Inicio.Text <> '  :  :  '     then
        begin
            if var_Fecha_Hora <> '' then
                 var_Fecha_Hora := var_Fecha_Hora + ' ' + MaskEdit_Hora_Inicio.Text
            else var_Fecha_Hora := MaskEdit_Hora_Inicio.Text;
        end;

        if var_Fecha_Hora <> '' then FieldByName('Password_Expira_Inicio').AsString := var_Fecha_Hora;

        // FIN
        var_Fecha_Hora := '';
        if DateEdit_Dia_Fin.Text <> '  /  /    ' then var_Fecha_Hora := DateEdit_Dia_Fin.Text;

        if MaskEdit_Hora_Fin.Text <> '  :  :  ' then
        begin
            if var_Fecha_Hora <> '' then
                 var_Fecha_Hora := var_Fecha_Hora + ' ' + MaskEdit_Hora_Fin.Text
            else var_Fecha_Hora := MaskEdit_Hora_Fin.Text;
        end;

        if var_Fecha_Hora <> '' then FieldByName('Password_Expira_Fin').AsString := var_Fecha_Hora;
    END;
end;

procedure TForm_users_002.ComprobarFechas( param_msg : TStrings );
begin
    if (DateEdit_Dia_Inicio.Text <> '  /  /    ') and
       (DateEdit_Dia_Fin.Text <> '  /  /    ')    and
       (MaskEdit_Hora_Inicio.Text <> '  :  :  ')  and
       (MaskEdit_Hora_Fin.Text <> '  :  :  ')     then
        begin
            Actualizar_Campos_Fecha_Hora;

            ComprobarFechas_2( param_msg );
        end
    else
        begin
            if DateEdit_Dia_Inicio.Text  = '  /  /    ' then param_msg.Add( '* El día de inicio de etapa' );
            if DateEdit_Dia_Fin.Text     = '  /  /    ' then param_msg.Add( '* El día de fin de etapa' );
            if MaskEdit_Hora_Inicio.Text = '  :  :  '   then param_msg.Add( '* La hora de inicio de etapa' );
            if MaskEdit_Hora_Fin.Text    = '  :  :  '   then param_msg.Add( '* La hora de fin de etapa' );
        end;
end;

procedure TForm_users_002.ComprobarFechas_2( param_msg : TStrings );
begin
    WITH Form_users_000.SQLQuery_Users_Passwords DO
    begin
        if (FieldByName('Password_Expira_Inicio').IsNull) or (FieldByName('Password_Expira_Fin').IsNull) then
            begin
                If FieldByName('Password_Expira_Inicio').IsNull then
                begin
                     param_msg.Add('* La fecha de INICIO de la caducidad.');
                end;

                If FieldByName('Password_Expira_Fin').IsNull then
                begin
                     param_msg.Add('* La fecha de FIN de la caducidad.');
                end;
            end
        else
            begin
                if ( Int(FieldByName('Password_Expira_Inicio').Value) = Int(FieldByName('Password_Expira_Fin').Value) ) and
                   ( FieldByName('Password_Expira_Inicio').Value > FieldByName('Password_Expira_Fin').Value           ) then
                begin
                    param_msg.Add( '* El dia de inicio y final es el mismo,' +
                                   ' así que la hora de fin no puede ser menor' +
                                   ' que la de inicio para la caducidad.' );
                end;

                if FieldByName('Password_Expira_Inicio').Value > FieldByName('Password_Expira_Fin').Value then
                begin
                    param_msg.Add('* La fecha de fin no puede ser anterior a la fecha de inicio de la caducidad.');
                end;
            end;
    end;
end;

procedure TForm_users_002.no_Tocar;
begin
     Panel_Mantenimiento.Enabled := False;
end;

procedure TForm_users_002.FormActivate(Sender: TObject);
begin
     if public_Solo_Ver = true then no_Tocar;
end;

procedure TForm_users_002.OKButtonClick(Sender: TObject);
begin
    private_Salir_OK     := True;
    public_Pulso_Aceptar := true;
end;

procedure TForm_users_002.CancelButtonClick(Sender: TObject);
begin
    private_Salir_OK     := True;
    public_Pulso_Aceptar := false;
end;

procedure TForm_users_002.Presentar_Datos;
var var_Hora : tTime;
    var_Dia  : tDate;
begin
    WITH Form_users_000.SQLQuery_Users_Passwords do
    BEGIN
        if not FieldByName('Password_Expira_Inicio').IsNull then
        begin
            var_Dia                   := FieldByName('Password_Expira_Inicio').AsDateTime;
            DateEdit_Dia_Inicio.Text  := DateToStr(var_Dia);

            var_Hora                  := FieldByName('Password_Expira_Inicio').AsDateTime;
            MaskEdit_Hora_Inicio.Text := TimeToStr(var_Hora);
        end;

        if not FieldByName('Password_Expira_Fin').IsNull then
        begin
            var_Dia                := FieldByName('Password_Expira_Fin').AsDateTime;
            DateEdit_Dia_Fin.Text  := DateToStr(var_Dia);

            var_Hora               := FieldByName('Password_Expira_Fin').AsDateTime;
            MaskEdit_Hora_Fin.Text := TimeToStr(var_Hora);
        end;
    END;
end;

end.

ahora estan todas las anotaciones en form_menu
