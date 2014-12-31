unit utilidades_general;

{$mode objfpc}{$H+}

interface

uses
    sysutils, syncobjs, Dialogs, Forms, Controls, Classes, ButtonPanel, DBGrids, sqldb, db;

function  UTI_GEN_Format_Fecha_Hora( param_Fecha_Str : ShortString ) : ShortString;
function  UTI_GEN_Form_Abierto_Ya(param_Form : string) : boolean;
function  UTI_GEN_Aviso( param_msg : TStrings; param_Titulo : String; param_BitBtn_Aceptar, param_BitBtn_Cancelar : Boolean ) : Boolean;
function  UTI_GEN_Ordenar_dbGrid( param_Last_Column : TColumn; param_Column : TColumn; param_SQLQuery : TSQLQuery ) : TColumn;
procedure UTI_GEN_Borrar_Imagen_Orden_Grid( param_Last_Column : TColumn );
procedure UTI_GEN_Salir;
procedure UTI_GEN_Log(param_msg : String);

var
  var_Global_CriticalSection : TCriticalSection;

implementation

uses menu, avisos, utilidades_bd;

function UTI_GEN_Aviso( param_msg : TStrings;
                        param_Titulo : String;
                        param_BitBtn_Aceptar,
                        param_BitBtn_Cancelar : Boolean ) : Boolean;
// var var_Formito : tform_Avisos;
begin
  { ****************************************************************************
    Ejemplos:
        UTI_GEN_Aviso( 'Para el codigo del trabajador NO EMPLEAR el signo -',
               '', True, False, True );

        if UTI_GEN_Aviso( '¿SOLO EL tipo de personal ELEGIDO S/N?',
                  '', True, True, True ) = True then
        begin
        end;

    ****************************************************************************
    Ejemplos .... llamando desde fuera de esta opción:
    ****************************************************************************
        Application.CreateForm(tform_Avisos, form_Avisos);
        form_Avisos.Memo_Aviso.Lines.Clear;
        form_Avisos.Memo_Aviso.Lines.Add('-. IMAGEN CAPTURADA .-');
        form_Avisos.Show;
        form_Avisos.Repaint;
    ****************************************************************************
        Application.CreateForm(tform_Avisos, form_Avisos);
        form_Avisos.Memo_Aviso.Lines.Clear;
        form_Avisos.Memo_Aviso.Lines.Add('-. IMAGEN CAPTURADA .-');
        form_Avisos.Show;
        form_Avisos.Repaint;
        for Contador := 1 to 999999999 do
        begin
            // Contador de tiempo //
        end;
        form_Avisos.Free;
    **************************************************************************** }

    // var_Formito := tform_Avisos.Create(nil);
    Application.CreateForm(tform_Avisos, form_Avisos);

    with form_Avisos do
    begin
        Memo_Aviso.Lines.Clear;

        if Trim(param_msg.Text) <> '' then Memo_Aviso.Lines.AddStrings(param_msg);

        with ButtonPanel_Avisos do
        begin
            ShowButtons := [];

            if (param_BitBtn_Aceptar = True) and
               (param_BitBtn_Cancelar = True) then
                begin
                    ShowButtons := [pbOK,pbCancel];
                    DefaultButton := pbOK;
                end
            else
                begin
                    if param_BitBtn_Aceptar = True then
                    begin
                        ShowButtons := [pbOK];
                        DefaultButton := pbOK;
                    end;

                    if param_BitBtn_Cancelar = True then
                    begin
                        ShowButtons := [pbCancel];
                        DefaultButton := pbCancel;
                    end;
                end;

            if Trim(param_Titulo) <> '' then
            begin
                Caption := Trim(param_Titulo);
            end;
        end;

        ShowModal;
        if public_Pulso_Aceptar = true then
             Result := True
        else Result := False;

        Free;
    end;
end;

function UTI_GEN_Form_Abierto_Ya(param_Form : string) : boolean;
var var_Contador : integer;
begin
    Result := false;
    for var_Contador := 0 to Screen.FormCount - 1 do
    begin
        if Pos( LowerCase(param_Form), LowerCase(Screen.Forms[var_Contador].Name) ) > 0 then
        begin
            Result := true;
            Break;
        end;
    end;
end;

function UTI_GEN_Format_Fecha_Hora( param_Fecha_Str : ShortString ) : ShortString;
var var_CN_Conexion : Trecord_CN_Conexion;
    var_Fecha_Hora  : TDateTime;
begin
    var_CN_Conexion := UTI_CN_Traer_Configuracion;
    if var_CN_Conexion.con_Exito = False then UTI_GEN_Salir;

    if UpperCase(Copy(var_CN_Conexion.ConnectorType, 1, 5)) = UpperCase('MySQL') then
    begin
        Try
           var_Fecha_Hora := StrToDateTime(param_Fecha_Str);
           Result         := FormatDateTime( 'yyyy-mm-dd hh:nn:ss', var_Fecha_Hora );
        Except
              Result := param_Fecha_Str;
        end;
    end;
end;

function UTI_GEN_Ordenar_dbGrid( param_Last_Column : TColumn;
                                 param_Column : TColumn;
                                 param_SQLQuery : TSQLQuery ) : TColumn;
const const_ImageArrowUp   = 0; //should match image in imagelist
      const_ImageArrowDown = 1; //should match image in imagelist

var var_ASC_IndexName, var_DESC_IndexName : string;

    procedure UTI_GEN_Ordenar_dbGrid_Actualizar_Indices(param_SQLQuery : TSQLQuery);
    begin
         // Ensure index defs are up to date
         param_SQLQuery.IndexDefs.Updated := false; { <<<--This line is critical. IndexDefs.Update
                                                      will not update if already true, which will
                                                      happen on the first column sorted.}
         param_SQLQuery.IndexDefs.Update;
    end;

begin

     // Clean all persistent index
     param_SQLQuery.IndexDefs.Clear;

     var_ASC_IndexName  := 'ASC_'  + param_Column.FieldName;
     var_DESC_IndexName := 'DESC_' + param_Column.FieldName;

     // indexes can't sort binary types such as ftMemo, ftBLOB
     if (param_Column.Field.DataType in [ftBLOB,ftMemo,ftWideMemo]) then Exit;

   { Esto falla asi que lo quito, ocurre cuando vuelvo a filtrar la tabla, y me pasa aún refrescando
     los índices creados. Así que paso de esto y los creo siempre que se pulsa en onTitle del Grid

     Check if a descending index already exists for this column
     if not, create one

     if param_SQLQuery.IndexDefs.IndexOf(var_DESC_IndexName) = -1 then
     begin
         param_SQLQuery.AddIndex(var_DESC_IndexName,param_Column.FieldName,[ixDescending]);
         UTI_GEN_Ordenar_dbGrid_Actualizar_Indices(param_SQLQuery); //ensure index defs are up to date
     end; }

     param_SQLQuery.AddIndex(var_ASC_IndexName,param_Column.FieldName,[]);
     UTI_GEN_Ordenar_dbGrid_Actualizar_Indices(param_SQLQuery); //ensure index defs are up to date

     param_SQLQuery.AddIndex(var_DESC_IndexName,param_Column.FieldName,[ixDescending]);
     UTI_GEN_Ordenar_dbGrid_Actualizar_Indices(param_SQLQuery); //ensure index defs are up to date


     // Use the column tag to toggle ASC/DESC
     param_Column.tag := not param_Column.tag;

     if boolean(param_Column.tag) then
          begin
               param_Column.Title.ImageIndex:=const_ImageArrowUp;
               param_SQLQuery.IndexName:=var_ASC_IndexName;
          end
     else
         begin
              param_Column.Title.ImageIndex:=const_ImageArrowDown;
              param_SQLQuery.IndexName:=var_DESC_IndexName;
     end;

     // Remove the sort arrow from the previous column we sorted
     if (param_Last_Column <> nil) and (param_Last_Column <> param_Column) then
     begin
          UTI_GEN_Borrar_Imagen_Orden_Grid(param_Last_Column);
     end;

     Result := param_Column;
end;

procedure UTI_GEN_Borrar_Imagen_Orden_Grid( param_Last_Column : TColumn );
begin
     if param_Last_Column <> nil then
     begin
          param_Last_Column.Title.ImageIndex := -1;
     end;
end;

procedure UTI_GEN_Salir;
begin
    with form_Menu do
    begin
        try
           Timer_Sin_Usar.Enabled := false;
           public_Salir_OK := True;
           Application.Terminate;  { No puedo poner Close, tiene que ser Application.Terminate }
        Except
           on E: Exception do
           begin
                ShowMessage('Error! ' + E.Message);
                raise;
           end;
        end;
    end;
end;

// Esta funcion nos permite guardar mensajes en un .log
procedure UTI_GEN_Log(param_msg : String);
var
  var_F              : TextFile;
  var_nombre_Fichero : String;
  var_SearchRec      : TSearchRec;
  var_Usuario        : ShortString;
begin
    if Trim(form_Menu.public_User_Descripcion_Nick) <> '' then
         var_Usuario := ' - ' + Trim(form_Menu.public_User_Descripcion_Nick)
    else var_Usuario := '';

    // Damos formato al param_msg
    param_msg          := FormatDateTime('[ddd dd mmm, hh:nn:ss]', Now) +
                          Trim(var_Usuario) +
                          ' ... ' +
                          param_msg;

    var_nombre_Fichero := ChangeFileExt(ParamStr(0), '.log');

  { Comenzamos el bloqueo  . la variable global se crea para evitar que cuando se trabajen
    con threads ... que dos partes del programa intenten trabajar con el fichero log }
    var_Global_CriticalSection.Enter;

    try
        if FindFirst(var_nombre_Fichero, faArchive, var_SearchRec) = 0 then
        begin
             // Comprobamos el tamaño de .log
             if var_SearchRec.Size > (1024*1024) then
             begin
                  // Y si es mayor de 1 MB lo renombramos
                  RenameFile( var_nombre_Fichero,
                              var_nombre_Fichero +
                              FormatDateTime('_YYYY_MM_DD-hh_nn_ss', Now) );
            end;
            FindClose(var_SearchRec);
        end;

        // Aqui abrimos el archivo si existe, o lo creamos sino existe
        AssignFile(var_F, var_nombre_Fichero);
        {$I-}
             Append(var_F);
             if IOResult <> 0 then Rewrite(var_F);
        {$I+}

        if IOResult = 0 then
        begin
          // Escribimos el param_msg
          Writeln( var_F, param_msg );
          CloseFile(var_F);
        end;
    finally
        // Terminamos el bloqueo
        var_Global_CriticalSection.Leave;
    end;
end;

// En la seccion initialization y finalization de la unit
initialization
  var_Global_CriticalSection:= TCriticalSection.Create;
finalization
  var_Global_CriticalSection.Free;
end.





