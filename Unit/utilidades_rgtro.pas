unit utilidades_rgtro;

{$mode objfpc}{$H+}

interface

uses
  Controls, Forms, FileUtil, Classes, SysUtils, DB, sqldb, IniFiles, ButtonPanel, Dialogs,
  DBGrids, utilidades_usuarios, utilidades_general, utilidades_bd;

{
var Variable : String;
}

type

  TCN_Conexion = record
    con_Exito: boolean;
    ConnectorType: string;
    DatabaseName: string;
    HostName: string;
    Password: string;
    UserName: string;
  end;

function  UTI_RGTRO_Grabar( param_SQLTransaction : TSQLTransaction; param_SQLQuery : TSQLQuery ) : Boolean;
function  UTI_RGTRO_Grabar_2( param_SQLTransaction : TSQLTransaction; param_SQLQuery : TSQLQuery ) : Boolean;
procedure UTI_RGTRO_Ver_Estado_Registro( param_SQLQuery : TSQLQuery; param_DataSource : TDataSource; param_DBGrid : TDBGrid );
procedure UTI_RGTRO_Borrar( param_SQLQuery : TSQLQuery; param_Solo_Ver : Boolean; param_Menu_Worked : Integer );
procedure UTI_RGTRO_Borrar_BAJA( param_SQLQuery : TSQLQuery; param_msg : TStrings; param_Menu_Worked : Integer);
procedure UTI_RGTRO_Borrar_ALTA( param_SQLQuery : TSQLQuery; param_msg : TStrings );
procedure UTI_RGTRO_param_assign_value( param_SQLQuery : TSQLQuery );
procedure UTI_RGTRO_Pasar_Valor_Campo( param_Vaciar : Boolean; param_Lineas : TStrings; param_valor_id_Principal, param_Campo : ShortString; param_quote : Boolean );

implementation

uses estado_registro, menu;

procedure UTI_RGTRO_Borrar( param_SQLQuery : TSQLQuery;
                            param_Solo_Ver : Boolean;
                            param_Menu_Worked : Integer );
var var_msg : TStrings;
begin
    with param_SQLQuery do
    begin
        var_msg := TStringList.Create;

        if RecordCount > 0 then
            begin
                if param_Solo_Ver = True then
                    begin
                        var_msg.Clear;
                        var_msg.Add('Sólo se puede CONSULTAR.');
                        UTI_GEN_Aviso(var_msg, 'SOLO PARA OBSERVAR', True, False);
                    end
                else
                    begin
                        if FieldByName('Del_WHEN').IsNull then
                             UTI_RGTRO_Borrar_BAJA( param_SQLQuery, var_msg, param_Menu_Worked)
                        else UTI_RGTRO_Borrar_ALTA( param_SQLQuery, var_msg );
                    end;
            end
        else
            begin
                var_msg.Clear;
                var_msg.Add('NO hay REGISTROS.');
                UTI_GEN_Aviso(var_msg, '¿COMO?', True, False);
            end;

        var_msg.Free;
    end;
end;

procedure UTI_RGTRO_Borrar_BAJA( param_SQLQuery : TSQLQuery;
                                 param_msg : TStrings;
                                 param_Menu_Worked : Integer);

var var_OK                   : Boolean;
    var_Form_Estado_Registro : TForm_Estado_Registro;
begin
    with param_SQLQuery do
    begin
        try
            Edit;

            FieldByName('Del_WHEN').Value    := UTI_CN_Fecha_Hora;
            FieldByName('Del_Id_User').Value := Form_Menu.public_User;

            // Llamo a un formulario para que pregunte por el motivo por el que se da de baja
            var_Form_Estado_Registro := TForm_Estado_Registro.Create(nil);
            //Application.CreateForm(tform_Estado_Registro, form_Estado_Registro);

            var_Form_Estado_Registro.Edit_Usuario_Baja.Text           := UTI_usr_Traer_Nombre_Usuario(Form_Menu.public_User);
            var_Form_Estado_Registro.Edit_Fecha_Baja.Text             := FieldByName('Del_WHEN').AsString;

            var_Form_Estado_Registro.Edit_Fecha_Ult_Modificacion.Text := FieldByName('Change_WHEN').AsString;
            var_Form_Estado_Registro.Edit_Fecha_Alta.Text             := FieldByName('Insert_WHEN').AsString;

            if not FieldByName('Change_Id_User').IsNull then
            begin
                var_Form_Estado_Registro.Edit_Usuario_Ult_Modificacion.Text := UTI_usr_Traer_Nombre_Usuario(FieldByName('Change_Id_User').Value);
            end;

            if not FieldByName('Insert_Id_User').IsNull then
            begin
                var_Form_Estado_Registro.Edit_Usuario_Alta.Text := UTI_usr_Traer_Nombre_Usuario(FieldByName('Insert_Id_User').Value);
            end;

            var_OK := True;
            if UTI_usr_Obligado_WHY_Delete_SN(param_Menu_Worked) = true then
            begin
                var_OK := False;
                While Trim(var_Form_Estado_Registro.Edit_Motivo_Baja.Text) = '' do
                begin
                    var_Form_Estado_Registro.ShowModal;
                    if var_Form_Estado_Registro.public_Pulso_Aceptar = true then
                        begin
                            var_OK := True;
                            if Trim(var_Form_Estado_Registro.Edit_Motivo_Baja.Text) = '' then
                            begin
                                param_msg.Clear;
                                param_msg.Add('Está Obligado a decirme PORQUE BORRAR el registro.');
                                UTI_GEN_Aviso(param_msg, 'NO PUEDO BORRAR', True, False);
                            end;
                        end
                    else
                        begin
                            var_OK := False;
                            Break;
                        end;
                end;
            end;

            FieldByName('Del_WHY').AsString := var_Form_Estado_Registro.Edit_Motivo_Baja.Text;
            var_Form_Estado_Registro.Free;

            if var_OK = True then
                 //Grabar_Registro
                 Post
            else Cancel;
        except
            on error : EDatabaseError do
            begin
                param_msg.Clear;
                param_msg.Add('NO SE PUDO BORRAR el registro, ocurrió un error de conexión con la BD.');
                param_msg.Add('Este es el mensaje de error: ');
                param_msg.Add( error.Message );
                UTI_GEN_Aviso(param_msg, 'ERROR', True, False);
            end;
        end;
    end;
end;

procedure UTI_RGTRO_Borrar_ALTA( param_SQLQuery : TSQLQuery;
                                 param_msg : TStrings );
begin
    with param_SQLQuery do
    begin
        param_msg.Clear;
        param_msg.Add('El registro ya estaba dado de baja.');
        param_msg.Add('¿SEGURO que desea darlo de ALTA?');
        if UTI_GEN_Aviso(param_msg, '¿SEGURO?', True, True) = True then
        begin
            try
                Edit;
                FieldByName('Del_WHEN').Clear;
                FieldByName('Del_Id_User').Clear;
                FieldByName('Del_WHY').Clear;

                //Grabar_Registro;
                Post;
            except
                on error : EDatabaseError do
                begin
                    param_msg.Clear;
                    param_msg.Add('NO SE PUDO DAR DE ALTA el registro, ocurrió un error de conexión con la BD.');
                    param_msg.Add('Este es el mensaje de error: ');
                    param_msg.Add( error.Message );
                    UTI_GEN_Aviso(param_msg, 'ERROR', True, False);
                end;
            end;
        end;;
    end;
end;

procedure UTI_RGTRO_param_assign_value( param_SQLQuery : TSQLQuery );
var var_Contador : ShortInt;
begin
    with param_SQLQuery do
    begin
        Params.Clear;

        for var_Contador := 0 to (FieldDefs.Count - 1) do
        begin
            Params.CreateParam(ftUnknown, FieldDefs.Items[var_Contador].Name, ptUnknown);
        end;
    end;

    param_SQLQuery.Params.CopyParamValuesFromDataset(param_SQLQuery, true);
end;

procedure UTI_RGTRO_Pasar_Valor_Campo( param_Vaciar : Boolean;
                                       param_Lineas : TStrings;
                                       param_valor_id_Principal,
                                       param_Campo : ShortString;
                                       param_quote : Boolean );
var var_valor : ShortString;
    var_Frase : String;
begin
    if Trim(param_valor_id_Principal) <> '' then
         var_valor := Trim(param_valor_id_Principal)
    else var_valor := 'Null';

    if param_quote = false then
         var_Frase := Trim(param_Campo) + ' = ' + Trim(var_valor)
    else var_Frase := Trim(param_Campo) + ' = ' + QuotedStr(Trim(var_valor));

    UTI_TB_Quitar_Filtro( 'AND ' + Trim(var_Frase), param_Lineas);
    UTI_TB_Quitar_Filtro( 'OR ' + Trim(var_Frase), param_Lineas);
    UTI_TB_Quitar_Filtro( Trim(var_Frase), param_Lineas);

    param_Lineas.Text := UTI_TB_Quitar_AndOr_Principio(Trim(param_Lineas.Text));

    if param_Vaciar = true then
        begin
            param_Lineas.Text := Trim(var_Frase);
        end
    else
        begin
            if Trim(param_Lineas.Text) = '' then
                param_Lineas.Text := Trim(var_Frase)
            else
                begin
                    param_Lineas.Text := Trim(var_Frase) + ' AND ' + Trim(param_Lineas.Text);
                end;
        end;

    param_Lineas.Text := UTI_TB_Quitar_AndOr_Principio(Trim(param_Lineas.Text));
end;

function UTI_RGTRO_Grabar( param_SQLTransaction : TSQLTransaction;
                           param_SQLQuery : TSQLQuery ) : Boolean;
var var_msg : TStrings;
begin
    { **************************************************************************
      ** Grabamos los cambios realizados por el usuario en el registro        **
      ************************************************************************** }
    Result := True;

    try
        if param_SQLTransaction.Active then
        { **********************************************************************
          ** Only if we are within a started transaction; otherwise you get   **
          ** "Operation cannot be performed on an inactive dataset"           **
          ********************************************************************** }
        begin
            param_SQLQuery.ApplyUpdates; { Pass user-generated changes back to database... }
            param_SQLTransaction.CommitRetaining; { and commit them using the transaction. }

            UTI_RGTRO_Grabar_2( param_SQLTransaction,
                                param_SQLQuery );
        end;
    except
        on error : EDatabaseError do
        begin
            var_msg := TStringList.Create;
                var_msg.Clear;
                var_msg.Add('Ocurrió un error de conexión con la BD.');
                var_msg.Add('Este es el mensaje de error : ');
                var_msg.Add( error.Message );
                UTI_GEN_Aviso(var_msg, 'ERROR', True, False);
            var_msg.Free;

            Result := False;
        end;
    end;
end;

function UTI_RGTRO_Grabar_2( param_SQLTransaction : TSQLTransaction;
                             param_SQLQuery : TSQLQuery ) : Boolean;
{ procedure Mensaje_No_Puedo_Grabar(Campos : tFields; Param_de_ande_viene: ShortString); }
var var_SQL            : TStrings;
    var_SQLTransaction : TSQLTransaction;
    var_SQLConnector   : TSQLConnector;
    var_SQLQuery       : TSQLQuery;

    var_Contador       : Integer;
    var_Momento        : TDateTime;
{
    var_tb             : ShortString;
    var_id             : ShortString;
    var_Id_Users       : ShortString; }
begin
  { ****************************************************************************
    Creamos la Transaccion y la conexión con el motor BD, y la abrimos
    **************************************************************************** }
    var_SQLTransaction := TSQLTransaction.Create(nil);
    var_SQLConnector   := TSQLConnector.Create(nil);

    if UTI_CN_Abrir( var_SQLTransaction,
                     var_SQLConnector ) = False then Application.Terminate;

  { ****************************************************************************
    Creamos la SQL
    **************************************************************************** }
    var_SQL      := TStringList.Create;

    var_Momento  := UTI_CN_Fecha_Hora;
{
    var_tb       := param_SQLQuery.Name;
    var_id       := param_SQLQuery.FieldByName('id').asString;
    var_Id_Users := IntToStr(Form_Menu.public_User); }

    var_SQL.Add( 'INSERT INTO users_row_changes' );
    var_SQL.Add(     '( tb,' );
    var_SQL.Add(       'id,' );
    var_SQL.Add(       'Momento,' );
    var_SQL.Add(       'Id_Users )' );
    var_SQL.Add( 'VALUES' );
    var_SQL.Add(     '( :tb,' );
    var_SQL.Add(       ':id,' );
    var_SQL.Add(       ':Momento,' );
    var_SQL.Add(       ':Id_Users )' );

  { ****************************************************************************
    Ejecutamos la Sql
    **************************************************************************** }
    var_SQLQuery          := TSQLQuery.Create(nil);

    var_SQLQuery.Database := var_SQLConnector;
    var_SQLQuery.SQL.Text := var_SQL.Text;

    var_SQLQuery.Params.ParamByName('tb').AsString    := Trim(param_SQLQuery.Name);
    var_SQLQuery.Params.ParamByName('id').AsString    := Trim(param_SQLQuery.FieldByName('id').asString);
    var_SQLQuery.Params.ParamByName('Momento').Value  := var_Momento;
    var_SQLQuery.Params.ParamByName('Id_Users').Value := Trim(IntToStr(Form_Menu.public_User));

    var_SQLQuery.ExecSQL;
    var_SQLTransaction.Commit;

  { ****************************************************************************
    Pasamos a grabar ahora el registro sobre la otra tabla
    **************************************************************************** }
    for var_Contador := 0 to param_SQLQuery.Fields.Count - 1 do
    begin
        If Pos( UpperCase('OT_'), UpperCase(param_SQLQuery.Fields[var_Contador].FieldName) ) = 0 then
        begin
            var_SQL.Clear;

            var_SQL.Add( 'INSERT INTO users_row_changes_fields' );
            var_SQL.Add(     '( tb,' );
            var_SQL.Add(       'id,' );
            var_SQL.Add(       'Momento,' );
            var_SQL.Add(       'Id_Users,' );

            var_SQL.Add(       'Campo_Nombre,' );
            var_SQL.Add(       'Campo_Valor )' );
            var_SQL.Add( 'VALUES' );
            var_SQL.Add(     '( :tb,' );
            var_SQL.Add(       ':id,' );
            var_SQL.Add(       ':Momento,' );
            var_SQL.Add(       ':Id_Users,' );

            var_SQL.Add(       ':Campo_Nombre,' );
            var_SQL.Add(       ':Campo_Valor )' );

            var_SQLQuery.SQL.Text := var_SQL.Text;

            var_SQLQuery.Params.ParamByName('tb').AsString           := Trim(param_SQLQuery.Name);
            var_SQLQuery.Params.ParamByName('id').AsString           := Trim(param_SQLQuery.FieldByName('id').asString);
            var_SQLQuery.Params.ParamByName('Momento').Value         := var_Momento;
            var_SQLQuery.Params.ParamByName('Id_Users').Value        := Trim(IntToStr(Form_Menu.public_User));

            var_SQLQuery.Params.ParamByName('Campo_Nombre').AsString := Trim(param_SQLQuery.Fields[var_Contador].FieldName);
            var_SQLQuery.Params.ParamByName('Campo_Valor').AsString  := param_SQLQuery.Fields[var_Contador].AsString;

            var_SQLQuery.ExecSQL;
            var_SQLTransaction.Commit;
        end;
    end;

  { ****************************************************************************
    Destruimos la tabla y conexiones
    **************************************************************************** }
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

procedure UTI_RGTRO_Ver_Estado_Registro( param_SQLQuery : TSQLQuery;
                                         param_DataSource : TDataSource;
                                         param_DBGrid : TDBGrid );
var var_Form_Estado_Registro : TForm_Estado_Registro;
    var_Contador : ShortInt;
begin
    with param_SQLQuery do
    begin
        var_Form_Estado_Registro := TForm_Estado_Registro.Create(nil);
        //Application.CreateForm(TForm_Estado_Registro, Form_Estado_Registro);

        var_Form_Estado_Registro.ButtonPanel_Estado_Registro.ShowButtons := [pbOK];
        var_Form_Estado_Registro.ButtonPanel_Estado_Registro.DefaultButton := pbOK;

        var_Form_Estado_Registro.Edit_Motivo_Baja.Color           := $006AD3D7;
        var_Form_Estado_Registro.Edit_Motivo_Baja.ReadOnly        := True;

        var_Form_Estado_Registro.Edit_Motivo_Baja.Text            := FieldByName('Del_WHY').AsString;
        var_Form_Estado_Registro.Edit_Fecha_Baja.Text             := FieldByName('Del_WHEN').AsString;
        var_Form_Estado_Registro.Edit_Fecha_Ult_Modificacion.Text := FieldByName('Change_WHEN').AsString;
        var_Form_Estado_Registro.Edit_Fecha_Alta.Text             := FieldByName('Insert_WHEN').AsString;

        if not FieldByName('Del_Id_User').isNull then
        begin
            var_Form_Estado_Registro.Edit_Usuario_Baja.Text := UTI_usr_Traer_Nombre_Usuario(FieldByName('Del_Id_User').Value);
        end;

        if not FieldByName('Change_Id_User').isNull then
        begin
            var_Form_Estado_Registro.Edit_Usuario_Ult_Modificacion.Text := UTI_usr_Traer_Nombre_Usuario(FieldByName('Change_Id_User').Value);
        end;

        if not FieldByName('Insert_Id_User').isNull then
        begin
            var_Form_Estado_Registro.Edit_Usuario_Alta.Text := UTI_usr_Traer_Nombre_Usuario(FieldByName('Insert_Id_User').Value);
        end;

        var_Form_Estado_Registro.DBGrid_Principal.Columns.Assign(param_DBGrid.Columns);
        var_Form_Estado_Registro.DBGrid_Principal.DataSource := param_DataSource;

        UTI_RGTRO_Pasar_Valor_Campo( true,
                                     var_Form_Estado_Registro.Memo_Filtros.Lines,
                                     param_SQLQuery.Name,
                                     'r.tb',
                                     true );

        UTI_RGTRO_Pasar_Valor_Campo( false,
                                     var_Form_Estado_Registro.Memo_Filtros.Lines,
                                     param_SQLQuery.FieldByName('id').AsString,
                                     'r.id',
                                     false );

      { ****************************************************************************
        Preparamos los diferentes tipos de orden preconfigurados
        **************************************************************************** }
        SetLength(var_Form_Estado_Registro.public_Order_By, 1);

        var_Form_Estado_Registro.public_Order_By[0].Titulo       := 'Por el registro a comprobar'; // El índice 0 siempre será por el que empezará la aplicación y los filtros
        var_Form_Estado_Registro.public_Order_By[0].Memo_OrderBy := 'r.tb ASC, r.id ASC, r.Momento ASC, r.Id_Users ASC';

        var_Form_Estado_Registro.Memo_OrderBy.Lines.Text         := var_Form_Estado_Registro.public_Order_By[0].Memo_OrderBy;

        var_Form_Estado_Registro.Filtrar_users_row_changes( var_Form_Estado_Registro.public_Last_Column,
                                                            0,
                                                            false,
                                                            var_Form_Estado_Registro.Memo_Filtros.Lines,
                                                            var_Form_Estado_Registro.Memo_OrderBy.Lines );

        var_Form_Estado_Registro.ShowModal;

        var_Form_Estado_Registro.Free;
    end;
end;

{
    jerofa hay que llevar un control de errores, ver si vale el método GetLogEvent
    de dm_Pelis para guardar en un fichero.log el control de los errores.
    Ver de como arreglar todos los Application.Terminate porque puede ser que fallen
    porque no necesite en ese momento cerrar la aplicación
}

end.





