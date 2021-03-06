unit peliculas_001;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Buttons, StdCtrls, utilidades_general,
    utilidades_forms_Filtrar, DbCtrls, ButtonPanel;

type

    { TForm_peliculas_001 }

    TForm_peliculas_001 = class(TForm)
        Boton_Elegir_Medio: TBitBtn;
        ButtonPanel1: TButtonPanel;
        DBEdit_Titulo: TDBEdit;
        DBEdit_Numero: TDBEdit;
        Edit_Descripcion_Medio: TEdit;
        Label1: TLabel;
        Label3: TLabel;
        Label4: TLabel;

        procedure Boton_Elegir_MedioClick(Sender: TObject);
        procedure Edit_Descripcion_MedioClick(Sender: TObject);
        procedure Presentar_Datos;
        procedure no_Tocar;

        procedure CancelButtonClick(Sender: TObject);
        procedure FormActivate(Sender: TObject);
        procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
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
    Form_peliculas_001: TForm_peliculas_001;

implementation

{$R *.lfm}

uses menu, peliculas_000;

{ TForm_peliculas_001 }

procedure TForm_peliculas_001.FormCreate(Sender: TObject);
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

    public_Record_Rgtro := UTI_Asignar_Fields_Pelis(Form_peliculas_000.SQLQuery_Pelis);

    Presentar_Datos;
end;

procedure TForm_peliculas_001.no_Tocar;
begin
     DBEdit_Titulo.Enabled          := False;
     Boton_Elegir_Medio.Enabled     := False;
     DBEdit_Numero.Enabled          := False;
     Edit_Descripcion_Medio.Enabled := False;
end;

procedure TForm_peliculas_001.CancelButtonClick(Sender: TObject);
begin
    private_Salir_OK     := True;
    public_Pulso_Aceptar := false;
end;

procedure TForm_peliculas_001.FormActivate(Sender: TObject);
begin
    if public_Solo_Ver = true then no_Tocar;
end;

procedure TForm_peliculas_001.OKButtonClick(Sender: TObject);
begin
    private_Salir_OK     := True;
    public_Pulso_Aceptar := true;
end;

procedure TForm_peliculas_001.Presentar_Datos;
begin
    Edit_Descripcion_Medio.Text := Form_peliculas_000.SQLQuery_Pelis.FieldByName('OT_descripcion_medio').AsString;
end;

procedure TForm_peliculas_001.Boton_Elegir_MedioClick(Sender: TObject);
var var_Registro : TRecord_Rgtro_Comun;
begin
    var_Registro := UTI_Abrir_Form( true, true, '', 10 );
    if var_Registro.Id <> '' then
    begin
         Form_peliculas_000.SQLQuery_Pelis.FieldByName('id_medio').AsString := Trim(var_Registro.Id);
         Edit_Descripcion_Medio.Text := var_Registro.MEDIOS_descripcion;
    end;
end;

procedure TForm_peliculas_001.Edit_Descripcion_MedioClick(Sender: TObject);
var var_msg : TStrings;
begin
    var_msg := TStringList.Create;
    var_msg.Add('¿QUITAMOS el MEDIO');
    if UTI_GEN_Aviso(var_msg, '¿SEGURO?', True, True) = True then
    begin
         Form_peliculas_000.SQLQuery_Pelis.FieldByName('id_medio').Clear;
         Edit_Descripcion_Medio.Text := '';
    end;
    var_msg.Free;
end;

procedure TForm_peliculas_001.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var var_msg : TStrings;
begin
    var_msg := TStringList.Create;

    if public_Pulso_Aceptar = true then
    begin
        with form_peliculas_000.SQLQuery_Pelis do
        begin
            if Trim(DBEdit_Titulo.Text) <> '' then
                 DBEdit_Titulo.Text := AnsiUpperCase(Trim(DBEdit_Titulo.Text))
            else var_msg.Add( '* El título de la película.');

            if Trim(Form_peliculas_000.SQLQuery_Pelis.FieldByName('id_medio').AsString) = '' then
            begin
                var_msg.Add( '* El tipo de medio donde se guarda.');
            end;

            if Trim(DBEdit_Numero.Text) = '' then
            begin
                var_msg.Add( '* El número / identificación del medio donde se guarda.');
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

end.

