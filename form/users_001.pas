unit users_001;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, DbCtrls, ButtonPanel, StdCtrls,
    sqldb, utilidades_general, Buttons, DBGrids, Grids, ExtCtrls, ComCtrls, db, utilidades_usuarios,
    utilidades_forms_Filtrar, variants, utilidades_rgtro, utilidades_bd;

type

    { TForm_users_001 }

    Trecord_Existe = record
        Existe              : Boolean;
        deBaja              : ShortString;
        id_Users            : ShortString;
        OT_Descripcion_Nick : ShortString;
        id_Menus            : ShortString;
    end;

    TForm_users_001 = class(TForm)
        BitBtn_Filtrar: TBitBtn;
        BitBtn_Ver_Situacion_Permisos: TBitBtn;
        BitBtn_Ver_Situacion_Registro_Passwords: TBitBtn;
        BitBtn_Ver_Situacion_Registro1: TBitBtn;
        ButtonPanel1: TButtonPanel;
        DBCheckBox1: TDBCheckBox;
        DBEdit_Nick: TDBEdit;
        DBGrid_Menus: TDBGrid;
        DBGrid_Menus_Permisos: TDBGrid;
        DBGrid_Passwords: TDBGrid;
        DBNavigator_Passwords: TDBNavigator;
        DBNavigator_Menus: TDBNavigator;
        DBNavigator_Menus_Permisos: TDBNavigator;
        GroupBox_Modulos: TGroupBox;
        GroupBox_Passwords: TGroupBox;
        GroupBox_Permisos: TGroupBox;
        Label1: TLabel;
        Memo_Filtros: TMemo;
        Memo_OrderBy: TMemo;
        RadioGroup_Bajas: TRadioGroup;

        procedure Editar_Registro_Passwords;
        procedure Editar_Registro_Menus;
        procedure Editar_Registro_Menus_Permisos;

        procedure Preparar_Memo(param_Borramos_Filtro : Boolean);
        procedure BitBtn_FiltrarClick(Sender: TObject);
        procedure Insertar_Registro_Menus_Permisos;
        procedure BitBtn_Ver_Situacion_PermisosClick(Sender: TObject);
        procedure BitBtn_Ver_Situacion_Registro1Click(Sender: TObject);
        procedure DBGrid_Menus_PermisosDblClick(Sender: TObject);
        procedure DBGrid_Menus_PermisosDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer;
            Column: TColumn; State: TGridDrawState);
        procedure DBGrid_MenusDblClick(Sender: TObject);
        procedure DBGrid_MenusDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer;
            Column: TColumn; State: TGridDrawState);
        procedure DBGrid_MenusKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
        procedure DBGrid_MenusTitleClick(Column: TColumn);
        procedure DBGrid_Menus_PermisosKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
        procedure DBGrid_Menus_PermisosTitleClick(Column: TColumn);
        procedure DBNavigator_MenusBeforeAction(Sender: TObject; Button: TDBNavButtonType);
        procedure DBNavigator_Menus_PermisosBeforeAction(Sender: TObject; Button: TDBNavButtonType);
        function  Existe_PWD_Ya( param_Id_Users, param_Password : String ) : Trecord_Existe;
        function  Existe_Menu_Ya( param_Id, param_Id_Users, param_id_Menus : String ) : Trecord_Existe;
        function  Existe_Menus_Permisos_Ya( param_Id, param_Id_Users, param_id_Menus, param_Tipo_CRUD : String ) : Trecord_Existe;
        procedure Presentar_Datos;
        procedure DBGrid_PasswordsTitleClick(Column: TColumn);
        procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
        procedure Refrescar_Registros;
        procedure Insertar_Registro_Passwords;
        procedure Insertar_Registro_Menus;
        procedure no_Tocar;
        procedure no_Tocar_2;

        procedure BitBtn_Ver_Situacion_Registro_PasswordsClick(Sender: TObject);
        procedure DBGrid_PasswordsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
        procedure DBNavigator_PasswordsBeforeAction(Sender: TObject; Button: TDBNavButtonType);

        procedure CancelButtonClick(Sender: TObject);
        procedure DBGrid_PasswordsDblClick(Sender: TObject);
        procedure DBGrid_PasswordsDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
        procedure FormActivate(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure OKButtonClick(Sender: TObject);
        procedure RadioGroup_BajasClick(Sender: TObject);
    private
        { private declarations }
        private_Salir_OK     : Boolean;
    public
        { public declarations }
        public_Solo_Ver      : Boolean;
        public_Menu_Worked   : Integer;
        public_Pulso_Aceptar : Boolean;
        public_Record_Rgtro  : TRecord_Rgtro_Comun;
    end;

var
    Form_users_001: TForm_users_001;

implementation

{$R *.lfm}

uses menu, users_000, users_002, users_003, users_004;

{ TForm_users_001 }

procedure TForm_users_001.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var var_msg : TStrings;
begin
    var_msg := TStringList.Create;

    if public_Pulso_Aceptar = true then
    begin
        with Form_users_000.SQLQuery_Users do
        begin
            if Trim(DBEdit_Nick.Text) <> '' then
                 DBEdit_Nick.Text := AnsiUpperCase(Trim(DBEdit_Nick.Text))
            else var_msg.Add( '* El Nick.');
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
            if form_Menu.public_Salir_OK = False then CloseAction := CloseAction.caFree ;
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
                    CloseAction := CloseAction.caNone;
                end
            else
                begin
                    // var_msg.Free;
                    CloseAction := caFree;
                end;

        end;

    var_msg.Free;
end;

procedure TForm_users_001.DBGrid_PasswordsTitleClick(Column: TColumn);
begin
    form_users_000.public_Last_Column_Password := UTI_GEN_Ordenar_dbGrid( form_users_000.public_Last_Column_Password,
                                                                          Column,
                                                                          form_users_000.SQLQuery_Users_Passwords );
end;

procedure TForm_users_001.FormCreate(Sender: TObject);
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
    DBGrid_Passwords.TitleImageList      := Form_Menu.ImageList_Grid_Sort;
    DBGrid_Menus.TitleImageList          := Form_Menu.ImageList_Grid_Sort;
    DBGrid_Menus_Permisos.TitleImageList := Form_Menu.ImageList_Grid_Sort;

    public_Solo_Ver                      := false;

    public_Record_Rgtro := UTI_Asignar_Fields_Usuarios(form_users_000.SQLQuery_Users);

    Presentar_Datos;

    if form_users_000.SQLQuery_Users.State = dsInsert then no_Tocar_2;
end;

procedure TForm_users_001.OKButtonClick(Sender: TObject);
begin
    private_Salir_OK     := True;
    public_Pulso_Aceptar := true;
end;

procedure TForm_users_001.no_Tocar_2;
begin
     GroupBox_Passwords.Enabled := False;
     GroupBox_Modulos.Enabled   := False;
     GroupBox_Permisos.Enabled  := False;
end;

procedure TForm_users_001.CancelButtonClick(Sender: TObject);
begin
    private_Salir_OK     := True;
    public_Pulso_Aceptar := false;
end;

procedure TForm_users_001.DBGrid_PasswordsDblClick(Sender: TObject);
begin
    Editar_Registro_Passwords;
end;

procedure TForm_users_001.DBGrid_PasswordsDrawColumnCell(Sender: TObject; const Rect: TRect;
    DataCol: Integer; Column: TColumn; State: TGridDrawState);
var var_Color_Normal : TColor;
begin
    with Sender as TDBGrid do
    begin
        if Form_users_000.SQLQuery_Users_Passwords.RecordCount = 0 then Exit;

        var_Color_Normal := Canvas.Brush.Color;

      { ************************************************************************
        Primero comprobamos si es un registro dado de baja o no
        ************************************************************************ }
        if not Form_users_000.SQLQuery_Users_Passwords.FieldByName('Del_WHEN').IsNull then
            begin
              { ****************************************************************
                Registro DADO de BAJA
                **************************************************************** }
                Canvas.Font.Color := clSilver;
            end
        else
            begin
              { ****************************************************************
                Registro DADO de ALTA, NO BAJA
                ****************************************************************
                Así que las pinto, pero sólo si no son las columnas que van a
                ser dibujadas
                **************************************************************** }
                if State <> [gdSelected] then
                begin
                    if (Column.FieldName <> 'COLUMNA_CON_IMAGEN') then
                    begin
                        Canvas.font.Color := clBlack;
                    end;
                end;
            end;

      { ************************************************************************
        Ahora paso a dibujar una celda normal con los colores elegidos o una
        dibujada
        ************************************************************************ }
        if (Column.FieldName <> 'COLUMNA_CON_IMAGEN') then
            begin
              { ****************************************************************
                No es una de las columnas a dibujar por lo que la pinto con los
                colores elegidos
                **************************************************************** }
                DefaultDrawColumnCell(Rect, DataCol, Column, State)
            end
        else
            begin
              { ****************************************************************
                Es una de las columnas a dibujar
                **************************************************************** }
                // COLUMNA CONFIRMADA
                if Column.FieldName = 'COLUMNA_CON_IMAGEN'  then
                begin
                    {
                    if Trim(Form_users_000.SQLQuery_Users_Passwords.FieldByName('id_medio').asString) = '1' then
                    begin
                        Canvas.StretchDraw(param_Rect, Image_Confirmado.Picture.Graphic);
                    end;
                    }
                end;
            end;

        Canvas.Font.Color := var_Color_Normal;
    end;
end;

procedure TForm_users_001.DBGrid_PasswordsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
    if Key = 13 then Editar_Registro_Passwords;
end;

procedure TForm_users_001.FormActivate(Sender: TObject);
begin
    if public_Solo_Ver = true then no_Tocar;
end;

procedure TForm_users_001.BitBtn_Ver_Situacion_Registro_PasswordsClick(Sender: TObject);
begin
    if UTI_usr_Permiso_SN(public_Menu_Worked, '', True) = True then
    begin
        if form_users_000.SQLQuery_Users_Passwords.RecordCount > 0 then UTI_RGTRO_Ver_Estado_Registro( form_users_000.SQLQuery_Users_Passwords, form_users_000.DataSource_Users_Passwords, DBGrid_Passwords);
    end;
end;

procedure TForm_users_001.DBNavigator_PasswordsBeforeAction(Sender: TObject; Button: TDBNavButtonType);
begin
    case Button of
        nbInsert : begin
            Insertar_Registro_Passwords;
            Abort;
        end;

        nbEdit : begin
            Editar_Registro_Passwords;
            Abort;
        end;

        nbDelete : begin
            if UTI_usr_Permiso_SN(public_Menu_Worked, 'B', True) = True then
            begin
                UTI_RGTRO_Borrar( form_users_000.SQLQuery_Users_Passwords,
                                  public_Solo_Ver,
                                  public_Menu_Worked );
            end;
            Abort;
        end;

        nbRefresh : begin
            form_users_000.Refrescar_Registros_Passwords;
            Abort;
        end;
    end;
end;

procedure TForm_users_001.no_Tocar;
begin
     DBEdit_Nick.Enabled := False;
     no_Tocar_2;
end;

procedure TForm_users_001.RadioGroup_BajasClick(Sender: TObject);
begin
    //UTI_TB_Ver_Bajas_SN('um', Memo_Filtros.Lines, RadioGroup_Bajas.ItemIndex);
    Refrescar_Registros;
end;

procedure TForm_users_001.DBGrid_MenusDblClick(Sender: TObject);
begin
    Editar_Registro_Menus;
end;

procedure TForm_users_001.BitBtn_Ver_Situacion_Registro1Click(Sender: TObject);
begin
    if UTI_usr_Permiso_SN(public_Menu_Worked, '', True) = True then
    begin
        if form_users_000.SQLQuery_Users_Menus.RecordCount > 0 then UTI_RGTRO_Ver_Estado_Registro( form_users_000.SQLQuery_Users_Menus, form_users_000.DataSource_Users_Menus, DBGrid_Menus );
    end;
end;

procedure TForm_users_001.DBGrid_Menus_PermisosDblClick(Sender: TObject);
begin
    Editar_Registro_Menus_Permisos;
end;

procedure TForm_users_001.DBGrid_MenusDrawColumnCell(Sender: TObject; const Rect: TRect;
    DataCol: Integer; Column: TColumn; State: TGridDrawState);
var var_Color_Normal : TColor;
begin
    with Sender as TDBGrid do
    begin
        if Form_users_000.SQLQuery_Users_Menus.RecordCount = 0 then Exit;

        var_Color_Normal := Canvas.Brush.Color;

      { ************************************************************************
        Primero comprobamos si es un registro dado de baja o no
        ************************************************************************ }
        if not Form_users_000.SQLQuery_Users_Menus.FieldByName('Del_WHEN').IsNull then
            begin
              { ****************************************************************
                Registro DADO de BAJA
                **************************************************************** }
                Canvas.Font.Color := clSilver;
            end
        else
            begin
              { ****************************************************************
                Registro DADO de ALTA, NO BAJA
                ****************************************************************
                Así que las pinto, pero sólo si no son las columnas que van a
                ser dibujadas
                **************************************************************** }
                if State <> [gdSelected] then
                begin
                    if (Column.FieldName <> 'COLUMNA_CON_IMAGEN') then
                    begin
                        Canvas.font.Color := clBlack;
                    end;
                end;
            end;

      { ************************************************************************
        Ahora paso a dibujar una celda normal con los colores elegidos o una
        dibujada
        ************************************************************************ }
        if (Column.FieldName <> 'COLUMNA_CON_IMAGEN') then
            begin
              { ****************************************************************
                No es una de las columnas a dibujar por lo que la pinto con los
                colores elegidos
                **************************************************************** }
                DefaultDrawColumnCell(Rect, DataCol, Column, State)
            end
        else
            begin
              { ****************************************************************
                Es una de las columnas a dibujar
                **************************************************************** }
                // COLUMNA CONFIRMADA
                if Column.FieldName = 'COLUMNA_CON_IMAGEN'  then
                begin
                    {
                    if Trim(Form_users_000.SQLQuery_Users_Menus.FieldByName('id_medio').asString) = '1' then
                    begin
                        Canvas.StretchDraw(param_Rect, Image_Confirmado.Picture.Graphic);
                    end;
                    }
                end;
            end;

        Canvas.Font.Color := var_Color_Normal;
    end;
end;

procedure TForm_users_001.DBGrid_MenusKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
    if Key = 13 then Editar_Registro_Menus;
end;

procedure TForm_users_001.DBGrid_MenusTitleClick(Column: TColumn);
begin
    form_users_000.public_Last_Column_Menus := UTI_GEN_Ordenar_dbGrid(form_users_000.public_Last_Column_Menus, Column, form_users_000.SQLQuery_Users_Menus);
end;

procedure TForm_users_001.DBGrid_Menus_PermisosKeyDown(Sender: TObject; var Key: Word;
    Shift: TShiftState);
begin
    if Key = 13 then Editar_Registro_Menus_Permisos;
end;

procedure TForm_users_001.DBNavigator_MenusBeforeAction(Sender: TObject; Button: TDBNavButtonType);
begin
    case Button of
        nbInsert : begin
            Insertar_Registro_Menus;
            Abort;
        end;

        nbEdit : begin
            Editar_Registro_Menus;
            Abort;
        end;

        nbDelete : begin
            if UTI_usr_Permiso_SN(public_Menu_Worked, 'B', True) = True then
            begin
                UTI_RGTRO_Borrar( form_users_000.SQLQuery_Users_Menus,
                                  public_Solo_Ver,
                                  public_Menu_Worked );
            end;
            Abort;
        end;

        nbRefresh : begin
            form_users_000.Refrescar_Registros_Menus;
            Abort;
        end;
    end;
end;

procedure TForm_users_001.Presentar_Datos;
begin
    Memo_OrderBy.Lines.Text := 'um.Id_Users ASC, um.Id_Menus ASC';

    Preparar_Memo(true);
end;

procedure TForm_users_001.Preparar_Memo(param_Borramos_Filtro : Boolean);
begin
     UTI_RGTRO_Pasar_Valor_Campo( param_Borramos_Filtro,
                                  Memo_Filtros.Lines,
                                  form_users_000.SQLQuery_Users.FieldByName('id').AsString,
                                  'um.Id_Users',
                                  false );

     UTI_TB_Ver_Bajas_SN('um', Memo_Filtros.Lines, RadioGroup_Bajas.ItemIndex);

     Memo_Filtros.Lines.Text := UTI_TB_Quitar_AndOr_Principio(Memo_Filtros.Lines.Text);
end;

procedure TForm_users_001.DBGrid_Menus_PermisosDrawColumnCell(Sender: TObject; const Rect: TRect;
    DataCol: Integer; Column: TColumn; State: TGridDrawState);
var var_Color_Normal : TColor;
begin
    with Sender as TDBGrid do
    begin
        if Form_users_000.SQLQuery_Users_Menus_Permisos.RecordCount = 0 then Exit;

        var_Color_Normal := Canvas.Brush.Color;

      { ************************************************************************
        Primero comprobamos si es un registro dado de baja o no
        ************************************************************************ }
        if not Form_users_000.SQLQuery_Users_Menus_Permisos.FieldByName('Del_WHEN').IsNull then
            begin
              { ****************************************************************
                Registro DADO de BAJA
                **************************************************************** }
                Canvas.Font.Color := clSilver;
            end
        else
            begin
              { ****************************************************************
                Registro DADO de ALTA, NO BAJA
                ****************************************************************
                Así que las pinto, pero sólo si no son las columnas que van a
                ser dibujadas
                **************************************************************** }
                if State <> [gdSelected] then
                begin
                    if (Column.FieldName <> 'COLUMNA_CON_IMAGEN') then
                    begin
                        Canvas.font.Color := clBlack;
                    end;
                end;
            end;

      { ************************************************************************
        Ahora paso a dibujar una celda normal con los colores elegidos o una
        dibujada
        ************************************************************************ }
        if (Column.FieldName <> 'COLUMNA_CON_IMAGEN') then
            begin
              { ****************************************************************
                No es una de las columnas a dibujar por lo que la pinto con los
                colores elegidos
                **************************************************************** }
                DefaultDrawColumnCell(Rect, DataCol, Column, State)
            end
        else
            begin
              { ****************************************************************
                Es una de las columnas a dibujar
                **************************************************************** }
                // COLUMNA CONFIRMADA
                if Column.FieldName = 'COLUMNA_CON_IMAGEN'  then
                begin
                    {
                    if Trim(Form_users_000.SQLQuery_Users_Menus.FieldByName('id_medio').asString) = '1' then
                    begin
                        Canvas.StretchDraw(param_Rect, Image_Confirmado.Picture.Graphic);
                    end;
                    }
                end;
            end;

        Canvas.Font.Color := var_Color_Normal;
    end;
end;

procedure TForm_users_001.DBGrid_Menus_PermisosTitleClick(Column: TColumn);
begin
    form_users_000.public_Last_Column_Menus_Permisos := UTI_GEN_Ordenar_dbGrid( form_users_000.public_Last_Column_Menus_Permisos,
                                                                                Column,
                                                                                form_users_000.SQLQuery_Users_Menus );
end;

procedure TForm_users_001.BitBtn_Ver_Situacion_PermisosClick(Sender: TObject);
begin
    if UTI_usr_Permiso_SN(public_Menu_Worked, '', True) = True then
    begin
        if form_users_000.SQLQuery_Users_Menus_Permisos.RecordCount > 0 then
        begin
             UTI_RGTRO_Ver_Estado_Registro( form_users_000.SQLQuery_Users_Menus_Permisos, form_users_000.DataSource_Users_Menus_Permisos, DBGrid_Menus_Permisos );
        end;
    end;
end;

procedure TForm_users_001.BitBtn_FiltrarClick(Sender: TObject);
begin
    RadioGroup_Bajas.ItemIndex := Form_users_000.Filtrar_users_menus( form_users_000.public_Last_Column_Menus,
                                                                      RadioGroup_Bajas.ItemIndex,
                                                                      true,
                                                                      Memo_Filtros.Lines,
                                                                      Memo_OrderBy.Lines );
end;

procedure TForm_users_001.Refrescar_Registros;
begin
    form_users_000.Refrescar_Registros_Passwords;
    form_users_000.Refrescar_Registros_Menus;
    // Refrescar_Registros_Menus_Permisos; NO HACE FALTA PORQUE LO HACE EL AFTER SCROLL DE LA TABLA DE MENUS
end;

procedure TForm_users_001.Insertar_Registro_Passwords;
var var_msg           : TStrings;
    var_Form          : TForm_users_002;
    var_record_Existe : Trecord_Existe;
begin
    with form_users_000.SQLQuery_Users_Passwords do
    begin
        var_msg := TStringList.Create;

        if UTI_usr_Permiso_SN(public_Menu_Worked, 'A', True) = True then
        begin
            if public_Solo_Ver = True then
                begin
                    var_msg.Clear;
                    var_msg.Add('Sólo se puede visualizar.');
                    UTI_GEN_Aviso(var_msg, 'SOLO PARA OBSERVAR', True, False);
                end
            else
                begin
                    Insert;

                    FieldByName('Id_Users').AsString           := form_users_000.SQLQuery_Users.FieldByName('Id').AsString;
                    FieldByName('Password_Expira_SN').AsString := 'S';
                    FieldByName('Obligado_NICK_SN').AsString   := 'S';

                    var_Form := TForm_users_002.Create(nil);

                    var_Form.ShowModal;
                    if var_Form.public_Pulso_Aceptar = true then
                        begin
                            var_Form.Free;

                            var_record_Existe := Existe_PWD_Ya( '', // Estoy insertando/creando y lo que tengo que comprobar es que no exista la pwd en cualquier otro usuario, por lo que el campo id_Users no lo paso
                                                                FieldByName('Password').AsString );
                            if var_record_Existe.Existe = false then
                          { if Existe_PWD_Ya( '', // Estoy insertando/creando y lo que tengo que comprobar es que no exista la pwd en cualquier otro usuario, por lo que el campo id_Users no lo paso
                                              FieldByName('Password').AsString ) = false then }
                                begin
                                    FieldByName('Insert_WHEN').Value    := UTI_CN_Fecha_Hora;
                                    FieldByName('Insert_Id_User').Value := Form_Menu.public_User;
                                    Post;
                                end
                            else
                                begin
                                    Cancel;
                                    var_msg.Clear;
                                    var_msg.Add('Contraseña repetida, pertenece al usuario ' + Trim(var_record_Existe.OT_Descripcion_Nick) + '.');

                                    if UpperCase(var_record_Existe.deBaja) = 'S' then
                                    begin
                                        var_msg.Add('Y está dada de baja.');
                                    end;

                                    UTI_GEN_Aviso(var_msg, 'YA EXISTE.-', True, False);
                                end;
                        end
                    else
                        begin
                            var_Form.Free;
                            Cancel;
                        end;
                end;
        end;

        var_msg.Free;
    end;
end;

function TForm_users_001.Existe_PWD_Ya( param_Id_Users,
                                        param_Password : String ) : Trecord_Existe;
var var_SQL            : TStrings;
    var_SQLTransaction : TSQLTransaction;
    var_SQLConnector   : TSQLConnector;
    var_SQLQuery       : TSQLQuery;
begin
  { ****************************************************************************
    Creamos la Transaccion y la conexión con el motor BD, y la abrimos
    **************************************************************************** }
    var_SQLTransaction := TSQLTransaction.Create(nil);
    var_SQLConnector   := TSQLConnector.Create(nil);

    if UTI_CN_Abrir( var_SQLTransaction,
                     var_SQLConnector ) = False then Application.Terminate;

  { ****************************************************************************
    Creamos la SQL Según el motor de BD
    **************************************************************************** }
    var_SQL := TStringList.Create;

    var_SQL.Add('SELECT up.*,' );
    var_SQL.Add(       'u.Descripcion_Nick AS OT_Descripcion_Nick' );

    var_SQL.Add(  'FROM users_passwords as up' );

    var_SQL.Add(  'LEFT JOIN users AS u' );
    var_SQL.Add(    'ON up.Id_Users = u.id' );

    var_SQL.Add(' WHERE up.Password = ' +  QuotedStr(Trim(param_Password)) );

    if Trim(param_Id_Users) <> '' then
    begin
         var_SQL.Add(  ' AND NOT up.Id_Users = ' + Trim(param_Id_Users) );
    end;

    var_SQL.Add(' ORDER BY up.Password ' );

  { ****************************************************************************
    Abrimos la tabla
    **************************************************************************** }
    var_SQLQuery := TSQLQuery.Create(nil);

    if UTI_TB_Abrir( '', '', '',
                     var_SQLConnector,
                     var_SQLTransaction,
                     var_SQLQuery,
                     -1, // asi me trae todos los registros de golpe
                     var_SQL.Text ) = False then Application.Terminate;

  { ****************************************************************************
    TRABAJAMOS CON LOS REGISTROS DEVUELTOS
    ****************************************************************************
    Si el módulo no se creó, no se permite entrar en él ... Result := False
    **************************************************************************** }
    Result.Existe              := false;
    Result.deBaja              := 'N';
    Result.id_Users            := '';
    Result.id_Menus            := '';
    Result.OT_Descripcion_Nick := '';

    if var_SQLQuery.RecordCount > 0 then
    begin
        Result.Existe              := true;
        Result.id_Users            := var_SQLQuery.FieldByName('Id_Users').AsString;
        Result.OT_Descripcion_Nick := var_SQLQuery.FieldByName('OT_Descripcion_Nick').AsString;;

        if not var_SQLQuery.FieldByName('Del_WHEN').IsNull then Result.deBaja := 'S';
    end;

    //if var_SQLQuery.FieldByName('Ctdad').Value > 0 then Result := True;

  { ****************************************************************************
    Cerramos la tabla
    **************************************************************************** }
    if UTI_TB_Cerrar( var_SQLConnector,
                      var_SQLTransaction,
                      var_SQLQuery ) = false then Application.Terminate;

    var_SQLQuery.Free;

    var_SQL.Free;

  { ****************************************************************************
    Cerramos La transacción y la conexión con la BD
    **************************************************************************** }
    if UTI_CN_Cerrar( var_SQLTransaction,
                      var_SQLConnector ) = False then Application.Terminate;

    var_SQLTransaction.Free;
    var_SQLConnector.Free;
end;

function TForm_users_001.Existe_Menu_Ya( param_Id,
                                         param_Id_Users,
                                         param_id_Menus : String ) : Trecord_Existe;
var var_SQL            : TStrings;
    var_SQLTransaction : TSQLTransaction;
    var_SQLConnector   : TSQLConnector;
    var_SQLQuery       : TSQLQuery;
begin
  { ****************************************************************************
    Creamos la Transaccion y la conexión con el motor BD, y la abrimos
    **************************************************************************** }
    var_SQLTransaction := TSQLTransaction.Create(nil);
    var_SQLConnector   := TSQLConnector.Create(nil);

    if UTI_CN_Abrir( var_SQLTransaction,
                     var_SQLConnector ) = False then Application.Terminate;

  { ****************************************************************************
    Creamos la SQL Según el motor de BD
    **************************************************************************** }
    var_SQL := TStringList.Create;

    var_SQL.Add('SELECT um.*,' );
    var_SQL.Add(        'u.Descripcion_Nick AS OT_Descripcion_Nick,' );
    var_SQL.Add(        'm.Descripcion AS OT_Descripcion_Menu' );

    var_SQL.Add(  'FROM users_menus AS um' );

    var_SQL.Add(  'LEFT JOIN users AS u' );
    var_SQL.Add(    'ON um.Id_Users = u.id' );

    var_SQL.Add(  'LEFT JOIN menus AS m' );
    var_SQL.Add(    'ON um.Id_Menus = m.id' );

    var_SQL.Add(' WHERE um.id_Menus = ' +  Trim(param_id_Menus) );
    var_SQL.Add(  ' AND um.Id_Users = ' +  Trim(param_Id_Users) );

    if Trim(param_Id) <> '' then
    begin
         var_SQL.Add(  ' AND NOT um.Id = ' + Trim(param_Id) );
    end;

    var_SQL.Add(' ORDER BY um.Id_Users, um.id_Menus' );

  { ****************************************************************************
    Abrimos la tabla
    **************************************************************************** }
    var_SQLQuery := TSQLQuery.Create(nil);

    if UTI_TB_Abrir( '', '', '',
                     var_SQLConnector,
                     var_SQLTransaction,
                     var_SQLQuery,
                     -1, // asi me trae todos los registros de golpe
                     var_SQL.Text ) = False then Application.Terminate;

  { ****************************************************************************
    TRABAJAMOS CON LOS REGISTROS DEVUELTOS
    ****************************************************************************
    Si el módulo no se creó, no se permite entrar en él ... Result := False
    **************************************************************************** }
    Result.Existe              := false;
    Result.deBaja              := 'N';
    Result.id_Users            := '';
    Result.id_Menus            := '';
    Result.OT_Descripcion_Nick := '';

    // if var_SQLQuery.FieldByName('Ctdad').Value > 0 then Result := True;
    if var_SQLQuery.RecordCount > 0 then
    begin
        Result.Existe              := true;
        if not var_SQLQuery.FieldByName('Del_WHEN').IsNull then Result.deBaja := 'S';
    end;

  { ****************************************************************************
    Cerramos la tabla
    **************************************************************************** }
    if UTI_TB_Cerrar( var_SQLConnector,
                      var_SQLTransaction,
                      var_SQLQuery ) = false then Application.Terminate;

    var_SQLQuery.Free;

    var_SQL.Free;

  { ****************************************************************************
    Cerramos La transacción y la conexión con la BD
    **************************************************************************** }
    if UTI_CN_Cerrar( var_SQLTransaction,
                      var_SQLConnector ) = False then Application.Terminate;

    var_SQLTransaction.Free;
    var_SQLConnector.Free;
end;

function TForm_users_001.Existe_Menus_Permisos_Ya( param_Id,
                                                   param_Id_Users,
                                                   param_id_Menus,
                                                   param_Tipo_CRUD : String ) : Trecord_Existe;
var var_SQL            : TStrings;
    var_SQLTransaction : TSQLTransaction;
    var_SQLConnector   : TSQLConnector;
    var_SQLQuery       : TSQLQuery;
begin
  { ****************************************************************************
    Creamos la Transaccion y la conexión con el motor BD, y la abrimos
    **************************************************************************** }
    var_SQLTransaction := TSQLTransaction.Create(nil);
    var_SQLConnector   := TSQLConnector.Create(nil);

    if UTI_CN_Abrir( var_SQLTransaction,
                     var_SQLConnector ) = False then Application.Terminate;

  { ****************************************************************************
    Creamos la SQL Según el motor de BD
    **************************************************************************** }
    var_SQL := TStringList.Create;

    var_SQL.Add('SELECT upe.*,' );
    var_SQL.Add(       'u.Descripcion_Nick AS OT_Descripcion_Nick,' );
    var_SQL.Add(       'm.Descripcion AS OT_Descripcion_Menu' );

    var_SQL.Add(  'FROM users_menus_permissions AS upe' );

    var_SQL.Add(  'LEFT JOIN users AS u' );
    var_SQL.Add(    'ON upe.Id_Users = u.id' );

    var_SQL.Add(  'LEFT JOIN menus AS m' );
    var_SQL.Add(    'ON upe.Id_Menus = m.id' );

    var_SQL.Add(' WHERE upe.Tipo_CRUD = ' +  QuotedStr(Trim(param_Tipo_CRUD)) );
    var_SQL.Add(  ' AND upe.id_Menus = ' +  Trim(param_id_Menus) );
    var_SQL.Add(  ' AND upe.Id_Users = ' +  Trim(param_Id_Users) );

    if Trim(param_Id) <> '' then
    begin
         var_SQL.Add(  ' AND NOT upe.Id = ' + Trim(param_Id) );
    end;

    var_SQL.Add(' ORDER BY upe.Id_Users, upe.id_Menus, upe.Tipo_CRUD' );

  { ****************************************************************************
    Abrimos la tabla
    **************************************************************************** }
    var_SQLQuery := TSQLQuery.Create(nil);

    if UTI_TB_Abrir( '', '', '',
                     var_SQLConnector,
                     var_SQLTransaction,
                     var_SQLQuery,
                     -1, // asi me trae todos los registros de golpe
                     var_SQL.Text ) = False then Application.Terminate;

  { ****************************************************************************
    TRABAJAMOS CON LOS REGISTROS DEVUELTOS
    ****************************************************************************
    Si el módulo no se creó, no se permite entrar en él ... Result := False
    **************************************************************************** }
    Result.Existe              := false;
    Result.deBaja              := 'N';
    Result.id_Users            := '';
    Result.id_Menus            := '';
    Result.OT_Descripcion_Nick := '';

    if var_SQLQuery.RecordCount > 0 then
    begin
        Result.Existe              := true;
        if not var_SQLQuery.FieldByName('Del_WHEN').IsNull then Result.deBaja := 'S';
    end;

  { ****************************************************************************
    Cerramos la tabla
    **************************************************************************** }
    if UTI_TB_Cerrar( var_SQLConnector,
                      var_SQLTransaction,
                      var_SQLQuery ) = false then Application.Terminate;

    var_SQLQuery.Free;

    var_SQL.Free;

  { ****************************************************************************
    Cerramos La transacción y la conexión con la BD
    **************************************************************************** }
    if UTI_CN_Cerrar( var_SQLTransaction,
                      var_SQLConnector ) = False then Application.Terminate;

    var_SQLTransaction.Free;
    var_SQLConnector.Free;
end;

procedure Tform_users_001.Editar_Registro_Passwords;
var var_msg           : TStrings;
    var_Form          : TForm_users_002;
    var_record_Existe : Trecord_Existe;
begin
    with form_users_000.SQLQuery_Users_Passwords do
    begin
        var_msg := TStringList.Create;

        if RecordCount > 0 then
            begin
                if UTI_usr_Permiso_SN(public_Menu_Worked, 'M', True) = True then
                begin
                    // ***************************************************************************** //
                    // ** Esto se hace porque cuando creamos el registro, como hace un commit a la** //
                    // ** transaccion, no devuelve el valor dado a los campos autoincrementales   ** //
                    // ***************************************************************************** //
                    Edit;

                    var_Form := TForm_users_002.Create(nil);

                    var_Form.public_Menu_Worked := public_Menu_Worked;

                    if public_Solo_Ver = true then
                    begin
                        var_Form.public_Solo_Ver := true;
                    end;

                    var_Form.ShowModal;
                    if var_Form.public_Pulso_Aceptar = true then
                        begin
                            var_record_Existe := Existe_PWD_Ya( FieldByName('Id_Users').AsString,
                                                                FieldByName('Password').AsString );
                            if var_record_Existe.Existe = false then
                                begin
                                    if ( Trim(var_Form.public_Record_Rgtro.USERS_PASSWORDS_Id_Users)               <> Trim(FieldByName('Id_Users').AsString) )               or
                                       ( Trim(var_Form.public_Record_Rgtro.USERS_PASSWORDS_Password)               <> Trim(FieldByName('Password').AsString) )               or
                                       ( Trim(var_Form.public_Record_Rgtro.USERS_PASSWORDS_Password_Expira_SN)     <> Trim(FieldByName('Password_Expira_SN').AsString) )     or
                                       ( Trim(var_Form.public_Record_Rgtro.USERS_PASSWORDS_Password_Expira_Inicio) <> Trim(FieldByName('Password_Expira_Inicio').AsString) ) or
                                       ( Trim(var_Form.public_Record_Rgtro.USERS_PASSWORDS_Password_Expira_Fin)    <> Trim(FieldByName('Password_Expira_Fin').AsString) )    or
                                       ( Trim(var_Form.public_Record_Rgtro.USERS_PASSWORDS_Obligado_NICK_SN)       <> Trim(FieldByName('Obligado_NICK_SN').AsString) )       then
                                       begin
                                            FieldByName('Change_WHEN').Value    := UTI_CN_Fecha_Hora;
                                            FieldByName('Change_Id_User').Value := Form_Menu.public_User;
                                            Post;
                                       end
                                    else Cancel;
                                    var_Form.Free;
                                end
                            else
                                begin
                                    var_Form.Free;
                                    Cancel;
                                    var_msg.Clear;
                                    var_msg.Add( 'Contraseña repetida, pertenece al usuario ' +
                                                 Trim(var_record_Existe.OT_Descripcion_Nick) + '.');

                                    if UpperCase(var_record_Existe.deBaja) = 'S' then
                                    begin
                                        var_msg.Add('Y está dada de baja.');
                                    end;

                                    UTI_GEN_Aviso(var_msg, 'YA EXISTE.-', True, False);
                                end;
                        end
                    else
                        begin
                            var_Form.Free;
                            Cancel;
                        end;
                end;
            end
        else
            begin
                var_msg.Add('No hay registros.');
                UTI_GEN_Aviso(var_msg, '¿QUE VAS A VER?', True, False);
            end;
    end;

    var_msg.Free;
end;

procedure Tform_users_001.Editar_Registro_Menus;
var var_msg           : TStrings;
    // var_Formito       : TForm_users_003;
    var_record_Existe : Trecord_Existe;
begin
    with form_users_000.SQLQuery_Users_Menus do
    begin
        var_msg := TStringList.Create;

        if RecordCount > 0 then
            begin
                if UTI_usr_Permiso_SN(public_Menu_Worked, 'M', True) = True then
                begin
                    // ***************************************************************************** //
                    // ** Esto se hace porque cuando creamos el registro, como hace un commit a la** //
                    // ** transaccion, no devuelve el valor dado a los campos autoincrementales   ** //
                    // ***************************************************************************** //
                    Edit;

                    Application.CreateForm(TForm_users_003, Form_users_003);
                    //var_Formito := TForm_users_003.Create(nil);

                    Form_users_003.public_Menu_Worked := public_Menu_Worked;

                    if public_Solo_Ver = true then
                    begin
                        Form_users_003.public_Solo_Ver := true;
                    end;

                    Form_users_003.ShowModal;
                    if Form_users_003.public_Pulso_Aceptar = true then
                        begin
                            var_record_Existe := Existe_Menu_Ya( FieldByName('Id').AsString, // estoy en modificacion por lo que le paso el campo id para que compruebe que no existe ya fuera de él mismo
                                                                 FieldByName('Id_Users').AsString,
                                                                 FieldByName('Id_Menus').AsString );
                            if var_record_Existe.Existe = false then
                                begin
                                    if ( Trim(Form_users_003.public_Record_Rgtro.USERS_MENUS_Id_Users)           <> Trim(FieldByName('Id_Users').AsString) )           or
                                       ( Trim(Form_users_003.public_Record_Rgtro.USERS_MENUS_Id_Menus)           <> Trim(FieldByName('Id_Menus').AsString) )           or
                                       ( Trim(Form_users_003.public_Record_Rgtro.USERS_MENUS_Forcing_Why_Delete) <> Trim(FieldByName('Forcing_Why_Delete').AsString) ) then
                                       begin
                                            FieldByName('Change_WHEN').Value    := UTI_CN_Fecha_Hora;
                                            FieldByName('Change_Id_User').Value := Form_Menu.public_User;
                                            Post;
                                       end
                                    else Cancel;

                                    Form_users_003.Free;
                                end
                            else
                                begin
                                    Form_users_003.Free;
                                    Cancel;
                                    var_msg.Clear;
                                    var_msg.Add('Menu repetido.');

                                    if UpperCase(var_record_Existe.deBaja) = 'S' then
                                    begin
                                        var_msg.Add('Y está dado de baja.');
                                    end;

                                    UTI_GEN_Aviso(var_msg, 'YA EXISTE.-', True, False);
                                end;
                        end
                    else
                        begin
                            Form_users_003.Free;
                            Cancel;
                        end;
                end;
            end
        else
            begin
                var_msg.Add('No hay registros.');
                UTI_GEN_Aviso(var_msg, '¿QUE VAS A VER?', True, False);
            end;
    end;
    var_msg.Free;
end;

procedure Tform_users_001.Editar_Registro_Menus_Permisos;
var var_msg           : TStrings;
    var_Form          : TForm_users_004;
    var_record_Existe : Trecord_Existe;
begin
    with form_users_000.SQLQuery_Users_Menus_Permisos do
    begin
        var_msg := TStringList.Create;

        if RecordCount > 0 then
            begin
                if UTI_usr_Permiso_SN(public_Menu_Worked, 'M', True) = True then
                begin
                    // ***************************************************************************** //
                    // ** Esto se hace porque cuando creamos el registro, como hace un commit a la** //
                    // ** transaccion, no devuelve el valor dado a los campos autoincrementales   ** //
                    // ***************************************************************************** //
                    Edit;

                    var_Form := TForm_users_004.Create(nil);

                    var_Form.public_Menu_Worked := public_Menu_Worked;

                    if public_Solo_Ver = true then
                    begin
                        var_Form.public_Solo_Ver := true;
                    end;

                    var_Form.ShowModal;
                    if var_Form.public_Pulso_Aceptar = true then
                        begin
                            var_record_Existe := Existe_Menus_Permisos_Ya( FieldByName('Id').AsString, // estoy en modificacion por lo que le paso el campo id para que compruebe que no existe ya fuera de él mismo
                                                                           FieldByName('Id_Users').AsString,
                                                                           FieldByName('Id_Menus').AsString,
                                                                           FieldByName('Tipo_CRUD').AsString );
                            if var_record_Existe.Existe = false then
                                begin
                                    if ( Trim(var_Form.public_Record_Rgtro.USERS_MENUS_PERMISSIONS_Id_Users)    <> Trim(FieldByName('Id_Users').AsString) )    or
                                       ( Trim(var_Form.public_Record_Rgtro.USERS_MENUS_PERMISSIONS_Id_Menus)    <> Trim(FieldByName('Id_Menus').AsString) )    or
                                       ( Trim(var_Form.public_Record_Rgtro.USERS_MENUS_PERMISSIONS_Tipo_CRUD)   <> Trim(FieldByName('Tipo_CRUD').AsString) )   or
                                       ( Trim(var_Form.public_Record_Rgtro.USERS_MENUS_PERMISSIONS_Descripcion) <> Trim(FieldByName('Descripcion').AsString) ) or
                                       ( Trim(var_Form.public_Record_Rgtro.USERS_MENUS_PERMISSIONS_PermisoSN)   <> Trim(FieldByName('PermisoSN').AsString) )   then
                                       begin
                                            FieldByName('Change_WHEN').Value    := UTI_CN_Fecha_Hora;
                                            FieldByName('Change_Id_User').Value := Form_Menu.public_User;
                                            Post;
                                       end
                                    else Cancel;
                                    var_Form.Free;
                                end
                            else
                                begin
                                    var_Form.Free;
                                    Cancel;
                                    var_msg.Clear;
                                    var_msg.Add('Permiso repetido para el menú elegido.');

                                    if UpperCase(var_record_Existe.deBaja) = 'S' then
                                    begin
                                        var_msg.Add('Y está dado de baja.');
                                    end;

                                    UTI_GEN_Aviso(var_msg, 'YA EXISTE.-', True, False);
                                end;
                        end
                    else
                        begin
                            var_Form.Free;
                            Cancel;
                        end;
                end;
            end
        else
            begin
                var_msg.Add('No hay registros.');
                UTI_GEN_Aviso(var_msg, '¿QUE VAS A VER?', True, False);
            end;
    end;
    var_msg.Free;
end;

procedure TForm_users_001.Insertar_Registro_Menus;
var var_msg           : TStrings;
    var_Form          : TForm_users_003;
    var_record_Existe : Trecord_Existe;
begin
    with form_users_000.SQLQuery_Users_Menus do
    begin
        var_msg := TStringList.Create;

        if UTI_usr_Permiso_SN(public_Menu_Worked, 'A', True) = True then
        begin
            if public_Solo_Ver = True then
                begin
                    var_msg.Clear;
                    var_msg.Add('Sólo se puede visualizar.');
                    UTI_GEN_Aviso(var_msg, 'SOLO PARA OBSERVAR', True, False);
                end
            else
                begin
                    Insert;

                    FieldByName('Id_Users').AsString           := form_users_000.SQLQuery_Users.FieldByName('id').AsString;
                    FieldByName('Forcing_Why_Delete').AsString := 'S';

                    var_Form := TForm_users_003.Create(nil);

                    var_Form.ShowModal;
                    if var_Form.public_Pulso_Aceptar = true then
                        begin
                            var_Form.Free;

                            var_record_Existe := Existe_Menu_Ya( '', // estoy en creación por lo que le paso el campo id vacío para que compruebe que no existe
                                                                 FieldByName('Id_Users').AsString,
                                                                 FieldByName('Id_Menus').AsString );
                            if var_record_Existe.Existe = false then
                                begin
                                    FieldByName('Insert_WHEN').Value    := UTI_CN_Fecha_Hora;
                                    FieldByName('Insert_Id_User').Value := Form_Menu.public_User;
                                    Post;
                                end
                            else
                                begin
                                    Cancel;
                                    var_msg.Clear;
                                    var_msg.Add('Menu repetido.');

                                    if UpperCase(var_record_Existe.deBaja) = 'S' then
                                    begin
                                        var_msg.Add('Y está dado de baja.');
                                    end;

                                    UTI_GEN_Aviso(var_msg, 'YA EXISTE.-', True, False);
                                end;
                        end
                    else
                        begin
                            var_Form.Free;
                            Cancel;
                        end;
                end;
        end;

        var_msg.Free;
    end;
end;

procedure TForm_users_001.DBNavigator_Menus_PermisosBeforeAction(Sender: TObject;
    Button: TDBNavButtonType);
begin
    case Button of
        nbInsert : begin
            Insertar_Registro_Menus_Permisos;
            Abort;
        end;

        nbEdit : begin
            Editar_Registro_Menus_Permisos;
            Abort;
        end;

        nbDelete : begin
            if UTI_usr_Permiso_SN(public_Menu_Worked, 'B', True) = True then
            begin
                UTI_RGTRO_Borrar( form_users_000.SQLQuery_Users_Menus_Permisos,
                                  public_Solo_Ver,
                                  public_Menu_Worked );
            end;
            Abort;
        end;

        nbRefresh : begin
            form_users_000.Refrescar_Registros_Menus_Permisos;
            Abort;
        end;
    end;
end;

procedure TForm_users_001.Insertar_Registro_Menus_Permisos;
var var_msg           : TStrings;
    var_Form          : TForm_users_004;
    var_record_Existe : Trecord_Existe;
begin
    with form_users_000.SQLQuery_Users_Menus_Permisos do
    begin
        var_msg := TStringList.Create;

        if form_users_000.SQLQuery_Users_Menus.RecordCount > 0 then
            begin
                if UTI_usr_Permiso_SN(public_Menu_Worked, 'A', True) = True then
                begin
                    if public_Solo_Ver = True then
                        begin
                            var_msg.Clear;
                            var_msg.Add('Sólo se puede visualizar.');
                            UTI_GEN_Aviso(var_msg, 'SOLO PARA OBSERVAR', True, False);
                        end
                    else
                        begin
                            Insert;

                            FieldByName('Id_Users').AsString  := form_users_000.SQLQuery_Users_Menus.FieldByName('Id_Users').AsString;
                            FieldByName('Id_Menus').AsString  := form_users_000.SQLQuery_Users_Menus.FieldByName('Id_Menus').AsString;
                            FieldByName('PermisoSN').AsString := 'S';

                            var_Form := TForm_users_004.Create(nil);

                            var_Form.ShowModal;
                            if var_Form.public_Pulso_Aceptar = true then
                                begin
                                    var_Form.Free;

                                    var_record_Existe := Existe_Menus_Permisos_Ya( '', // estoy en creación por lo que le paso el campo id vacío para que compruebe que no existe
                                                                                   FieldByName('Id_Users').AsString,
                                                                                   FieldByName('Id_Menus').AsString,
                                                                                   FieldByName('Tipo_CRUD').AsString );
                                    if var_record_Existe.Existe = false then
                                  { if Existe_Menus_Permisos_Ya( '', // estoy en creación por lo que le paso el campo id vacío para que compruebe que no existe
                                                                 FieldByName('Id_Users').AsString,
                                                                 FieldByName('Id_Menus').AsString,
                                                                 FieldByName('Tipo_CRUD').AsString ) = false then }
                                        begin
                                            FieldByName('Insert_WHEN').Value    := UTI_CN_Fecha_Hora;
                                            FieldByName('Insert_Id_User').Value := Form_Menu.public_User;
                                            Post;
                                        end
                                    else
                                        begin
                                            Cancel;
                                            var_msg.Clear;
                                            var_msg.Add('Permiso repetido para el menú elegido.');

                                            if UpperCase(var_record_Existe.deBaja) = 'S' then
                                            begin
                                                var_msg.Add('Y está dado de baja.');
                                            end;

                                            UTI_GEN_Aviso(var_msg, 'YA EXISTE.-', True, False);
                                        end;
                                end
                            else
                                begin
                                    var_Form.Free;
                                    Cancel;
                                end;
                        end;
                end;
            end
        else
            begin
                var_msg.Clear;
                var_msg.Add('No tiene ninguna autorización.');
                UTI_GEN_Aviso(var_msg, 'NO EXISTE.-', True, False);
            end;

        var_msg.Free;
    end;
end;

end.


