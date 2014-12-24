unit estado_registro;

{$mode objfpc}{$H+}

interface

uses
    Dialogs, Classes, SysUtils, sqldb, db, FileUtil, Forms, Controls, Graphics, StdCtrls, Buttons,
    variants, utilidades_rgtro, utilidades_bd, utilidades_general, ButtonPanel, DBGrids, DbCtrls;

type

    { TForm_Estado_Registro }

    TForm_Estado_Registro = class(TForm)
        BitBtn_Filtrar: TBitBtn;
        ButtonPanel_Estado_Registro: TButtonPanel;
        DataSource_users_row_changes: TDataSource;
        DataSource_users_row_changes_fields: TDataSource;
        DBGrid_Principal: TDBGrid;
        DBGrid_Principal1: TDBGrid;
        DBGrid_Principal2: TDBGrid;
        DBMemo1: TDBMemo;
        DBNavigator1: TDBNavigator;
        DBNavigator2: TDBNavigator;
        Edit_Fecha_Alta: TEdit;
        Edit_Fecha_Baja: TEdit;
        Edit_Fecha_Ult_Modificacion: TEdit;
        Edit_Motivo_Baja: TEdit;
        Edit_Usuario_Alta: TEdit;
        Edit_Usuario_Baja: TEdit;
        Edit_Usuario_Ult_Modificacion: TEdit;
        GroupBox1: TGroupBox;
        GroupBox2: TGroupBox;
        GroupBox3: TGroupBox;
        GroupBox4: TGroupBox;
        Label1: TLabel;
        Label2: TLabel;
        Label3: TLabel;
        Label4: TLabel;
        Label5: TLabel;
        Label6: TLabel;
        Label7: TLabel;
        Label9: TLabel;
        Memo_Filtros: TMemo;
        Memo_OrderBy: TMemo;
        SQLQuery_users_row_changes: TSQLQuery;
        SQLQuery_users_row_changesOT_Descripcion_Nick_Calc1: TStringField;
        SQLQuery_users_row_changes_fields: TSQLQuery;
        SQLQuery_users_row_changesid: TLargeintField;
        SQLQuery_users_row_changesId_Users: TLargeintField;
        SQLQuery_users_row_changesMomento: TDateTimeField;
        SQLQuery_users_row_changesOT_Descripcion_Nick: TStringField;
        SQLQuery_users_row_changestb: TStringField;
        SQLQuery_users_row_changes_fieldsCampo_Nombre: TStringField;
        SQLQuery_users_row_changes_fieldsCampo_Valor: TMemoField;
        SQLQuery_users_row_changes_fieldsid: TLargeintField;
        SQLQuery_users_row_changes_fieldsId_Users: TLargeintField;
        SQLQuery_users_row_changes_fieldsMomento: TDateTimeField;
        SQLQuery_users_row_changes_fieldsOT_Descripcion_Nick: TStringField;
        SQLQuery_users_row_changes_fieldstb: TStringField;

        procedure Cerramos_Tablas;
        procedure Cerramos_Tablas_Ligadas;
        procedure DBGrid_Principal1TitleClick(Column: TColumn);
        procedure DBGrid_Principal2TitleClick(Column: TColumn);
        procedure FormDestroy(Sender: TObject);
        procedure Refrescar_Registros_fields;
        procedure Refrescar_Registros;
        procedure DBNavigator1BeforeAction(Sender: TObject; Button: TDBNavButtonType);
        procedure DBNavigator2BeforeAction(Sender: TObject; Button: TDBNavButtonType);
        function  Filtrar_users_row_changes( param_Last_Column : TColumn; param_ver_bajas : ShortInt; param_Cambiamos_Filtro : Boolean; param_Lineas_Filtro, param_Lineas_OrderBy : TStrings ) : ShortInt;
        function  Filtrar_users_row_changes_fields( param_Last_Column : TColumn; param_ver_bajas : ShortInt; param_Cambiamos_Filtro : Boolean; param_Lineas_Filtro, param_Lineas_OrderBy : TStrings ) : ShortInt;
        procedure BitBtn_FiltrarClick(Sender: TObject);
        procedure Filtrar_tablas_ligadas;
        procedure CancelButtonClick(Sender: TObject);
        procedure DBGrid_PrincipalKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
        procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
        procedure FormCreate(Sender: TObject);
        procedure OKButtonClick(Sender: TObject);
        procedure SQLQuery_users_row_changesAfterScroll(DataSet: TDataSet);
        procedure SQLQuery_users_row_changesCalcFields(DataSet: TDataSet);
    private
        { private declarations }
        private_Salir_OK           : Boolean;
        private_Last_Column_fields : TColumn;
        private_Order_By_fields    : array of TOrder_By;
    public
        { public declarations }
        public_Pulso_Aceptar : Boolean;
        public_Last_Column   : TColumn;
        public_Order_By      : array of TOrder_By;
    end;

var
    Form_Estado_Registro: TForm_Estado_Registro;

implementation

{$R *.lfm}

uses dm_historico_registros, menu;

{ TForm_Estado_Registro }

procedure TForm_Estado_Registro.OKButtonClick(Sender: TObject);
begin
     private_Salir_OK     := True;
     public_Pulso_Aceptar := true;
end;

procedure TForm_Estado_Registro.SQLQuery_users_row_changesAfterScroll(DataSet: TDataSet);
begin
    Filtrar_tablas_ligadas;
end;

procedure TForm_Estado_Registro.SQLQuery_users_row_changesCalcFields(DataSet: TDataSet);
begin
    with SQLQuery_users_row_changes do
    begin
        if (FieldByName('Id_Users').Value = 0) or
           (FieldByName('Id_Users').IsNull)    then
             FieldByName('OT_Descripcion_Nick_Calc').AsString := 'SUPER USUARIO'
        else FieldByName('OT_Descripcion_Nick_Calc').AsString :=FieldByName('OT_Descripcion_Nick').AsString;
    end;
end;

procedure TForm_Estado_Registro.FormClose(Sender: TObject;
    var CloseAction: TCloseAction);
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

procedure TForm_Estado_Registro.CancelButtonClick(Sender: TObject);
begin
    private_Salir_OK     := True;
    public_Pulso_Aceptar := false;
end;

procedure TForm_Estado_Registro.DBGrid_PrincipalKeyDown(Sender: TObject; var Key: Word;
    Shift: TShiftState);
begin
  if (key = 38) or (key=40) then key := 0;
end;

procedure TForm_Estado_Registro.FormCreate(Sender: TObject);
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

  { ****************************************************************************
    Solo para formularios que traten con datos
    **************************************************************************** }
    DBGrid_Principal.TitleImageList := Form_Menu.ImageList_Grid_Sort;

    if UTI_GEN_Form_Abierto_Ya('DataModule_historico_registros') = False then
    begin
        DataModule_historico_registros := TDataModule_historico_registros.Create(Application);
    end;

  { ****************************************************************************
    Preparamos los diferentes tipos de orden preconfigurados
    **************************************************************************** }
    SetLength(private_Order_By_fields, 1);

    private_Order_By_fields[0].Titulo       := 'Por rgtro.cambiado'; // El índice 0 siempre será por el que empezará la aplicación y los filtros
    private_Order_By_fields[0].Memo_OrderBy := 'rf.tb ASC, rf.id ASC, rf.Momento ASC, rf.Id_Users ASC, rf.Campo_Nombre ASC';
end;

procedure TForm_Estado_Registro.BitBtn_FiltrarClick(Sender: TObject);
begin
    Filtrar_users_row_changes( public_Last_Column,
                               0,
                               true,
                               Memo_Filtros.Lines,
                               Memo_OrderBy.Lines );
end;

procedure TForm_Estado_Registro.DBNavigator1BeforeAction(Sender: TObject; Button: TDBNavButtonType);
begin
    case Button of
        nbRefresh : begin
            Refrescar_Registros;
            Abort;
        end;
    end;
end;

procedure TForm_Estado_Registro.DBNavigator2BeforeAction(Sender: TObject; Button: TDBNavButtonType);
begin
    case Button of
        nbRefresh : begin
            Refrescar_Registros_fields;
            Abort;
        end;
    end;
end;

procedure TForm_Estado_Registro.Refrescar_Registros;
var var_tb       : String;
    var_id       : Int64;
    var_Momento  : TDateTime;
    var_Id_Users : Int64;
begin
    // ********************************************************************************************* //
    // ** OJITO ... NO USAR CAMPOS AUTOINCREMENTABLES                                             ** //
    // ********************************************************************************************* //
    var_tb       := '';
    var_id       := 0;
    // var_Momento  := nil;
    var_Id_Users := 0;

    if SQLQuery_users_row_changes.RecordCount > 0 then
    begin
         var_tb       := SQLQuery_users_row_changes.FieldByName('tb').Value;
         var_id       := SQLQuery_users_row_changes.FieldByName('id').Value;
         var_Momento  := SQLQuery_users_row_changes.FieldByName('Momento').Value;
         var_Id_Users := SQLQuery_users_row_changes.FieldByName('Id_Users').Value;
    end;

    Filtrar_users_row_changes( public_Last_Column,
                               0,
                               false,
                               Memo_Filtros.Lines,
                               Memo_OrderBy.Lines );

    if Trim(var_tb) <> '' then
    begin
         SQLQuery_users_row_changes.Locate( 'tb;id;Momento;Id_Users',
                                            VarArrayOf( [ var_tb,
                                                          var_id,
                                                          var_Momento,
                                                          var_Id_Users ] ),
                                            [] );
    end;
end;

procedure TForm_Estado_Registro.Refrescar_Registros_fields;
var var_Buscar       : Boolean;
    var_tb           : String;
    var_id           : Int64;
    var_Momento      : TDateTime;
    var_Id_Users     : Int64;
    var_Campo_Nombre : String;
begin
    // ********************************************************************************************* //
    // ** OJITO ... NO USAR CAMPOS AUTOINCREMENTABLES                                             ** //
    // ********************************************************************************************* //
    var_Buscar := false;
    if SQLQuery_users_row_changes.RecordCount > 0 then
    begin
        var_Buscar        := true;
         var_tb           := SQLQuery_users_row_changes.FieldByName('tb').Value;
         var_id           := SQLQuery_users_row_changes.FieldByName('id').Value;
         var_Momento      := SQLQuery_users_row_changes.FieldByName('Momento').Value;
         var_Id_Users     := SQLQuery_users_row_changes.FieldByName('Id_Users').Value;
         var_Campo_Nombre := SQLQuery_users_row_changes.FieldByName('Campo_Nombre').Value;
    end;

    Filtrar_users_row_changes_fields( private_Last_Column_fields,
                                      0,
                                      false,
                                      Memo_Filtros.Lines,
                                      Memo_OrderBy.Lines );

    if var_Buscar = true then
    begin
         SQLQuery_users_row_changes.Locate( 'tb;id;Momento;Id_Users;Campo_Nombre',
                                            VarArrayOf( [ var_tb,
                                                          var_id,
                                                          var_Momento,
                                                          var_Id_Users,
                                                          var_Campo_Nombre ] ),
                                            [] );
    end;
end;

procedure TForm_Estado_Registro.Cerramos_Tablas;
begin
    Cerramos_Tablas_Ligadas;

    if UTI_TB_Cerrar( DataModule_historico_registros.SQLConnector,
                      DataModule_historico_registros.SQLTransaction,
                      SQLQuery_users_row_changes ) = false then
    begin
        Application.Terminate;
    end;

    FreeAndNil(DataModule_historico_registros);
end;

procedure TForm_Estado_Registro.Cerramos_Tablas_Ligadas;
begin
    if UTI_TB_Cerrar( DataModule_historico_registros.SQLConnector1,
                      DataModule_historico_registros.SQLTransaction1,
                      SQLQuery_users_row_changes_fields ) = false then
    begin
        Application.Terminate;
    end;
end;

procedure TForm_Estado_Registro.DBGrid_Principal1TitleClick(Column: TColumn);
begin
    public_Last_Column := UTI_GEN_Ordenar_dbGrid(public_Last_Column, Column, SQLQuery_users_row_changes);
end;

procedure TForm_Estado_Registro.DBGrid_Principal2TitleClick(Column: TColumn);
begin
    private_Last_Column_fields := UTI_GEN_Ordenar_dbGrid(private_Last_Column_fields, Column, SQLQuery_users_row_changes_fields);
end;

procedure TForm_Estado_Registro.FormDestroy(Sender: TObject);
begin
    Cerramos_Tablas;
end;

procedure TForm_Estado_Registro.Filtrar_tablas_ligadas;
var var_Lineas_Filtro  : TStrings;
    var_Lineas_OrderBy : TStrings;
begin
    if SQLQuery_users_row_changes.RecordCount = 0 then Exit;

    var_Lineas_Filtro  := TStringList.Create;
    var_Lineas_OrderBy := TStringList.Create;

    UTI_RGTRO_Pasar_Valor_Campo( true,  var_Lineas_Filtro, SQLQuery_users_row_changes.FieldByName('tb').AsString, 'rf.tb', true );
    UTI_RGTRO_Pasar_Valor_Campo( false, var_Lineas_Filtro, SQLQuery_users_row_changes.FieldByName('id').AsString, 'rf.id', false );
    UTI_RGTRO_Pasar_Valor_Campo( false, var_Lineas_Filtro, SQLQuery_users_row_changes.FieldByName('Id_Users').AsString, 'rf.Id_Users', false );
    UTI_RGTRO_Pasar_Valor_Campo( false,
                                 var_Lineas_Filtro,
                                 // FormatDateTime('yyyy-mm-dd hh:nn:ss', SQLQuery_users_row_changes.FieldByName('Momento').Value),
                                 UTI_GEN_Format_Fecha_Hora( SQLQuery_users_row_changes.FieldByName('Momento').AsString ),
                                 'rf.Momento',
                                 true );

    var_Lineas_OrderBy.Clear;

    Filtrar_users_row_changes_fields( private_Last_Column_fields,
                                      0,
                                      false,
                                      var_Lineas_Filtro,
                                      var_Lineas_OrderBy );

    FreeAndNil(var_Lineas_Filtro);
    FreeAndNil(var_Lineas_OrderBy);
end;

function TForm_Estado_Registro.Filtrar_users_row_changes_fields( param_Last_Column : TColumn;
                                                                 param_ver_bajas : ShortInt;
                                                                 param_Cambiamos_Filtro : Boolean;
                                                                 param_Lineas_Filtro,
                                                                 param_Lineas_OrderBy : TStrings ) : ShortInt;
var var_DeleteSQL    : String;
    var_UpdateSQL    : String;
    var_InsertSQL    : String;
    var_ctdad_Rgtros : Integer;
    var_nombre_tabla : ShortString;
    VAR_SQL_SELECT   : String;
    // VAR_SQL_ORDER_BY : String;
begin
    var_DeleteSQL    := '';
    var_UpdateSQL    := '';
    var_InsertSQL    := '';
    var_ctdad_Rgtros := 4;
    var_nombre_tabla := 'rf';

    // ********************************************************************************************* //
    // ** No olvidemos que los campos que empiezan por OT_ son campos que pertenecen a otras      ** //
    // ** tablas(JOIN de la SELECT) y que por lo tanto no voy a permitir hacer nada con ellos en  ** //
    // ** form_filtrar_registros y de momento tampoco en form_ordenado_por                        ** //
    // ********************************************************************************************* //
    VAR_SQL_SELECT   := 'SELECT rf.*,' +
                               ' u.Descripcion_Nick AS OT_Descripcion_Nick' +

                         ' FROM users_row_changes_fields AS rf' +

                       ' LEFT JOIN users AS u' +
                         ' ON rf.Id_Users = u.id';

    // VAR_SQL_ORDER_BY := 'ORDER BY up.Id_Users ASC, up.Password ASC';
    if Trim(param_Lineas_OrderBy.Text) = '' then
    begin
         param_Lineas_OrderBy.Text := private_Order_By_fields[0].Memo_OrderBy;;
    end;

    Result := UTI_TB_Filtrar( private_Order_By_fields,

                              var_DeleteSQL,
                              var_UpdateSQL,
                              var_InsertSQL,

                              var_ctdad_Rgtros,
                              DataModule_historico_registros.SQLTransaction1,
                              DataModule_historico_registros.SQLConnector1,
                              SQLQuery_users_row_changes_fields,

                              var_nombre_tabla,
                              param_ver_bajas,

                              VAR_SQL_SELECT,
                              // var_SQL_ORDER_BY,

                              param_Lineas_Filtro,
                              param_Lineas_OrderBy,

                              param_Cambiamos_Filtro );

    UTI_GEN_Borrar_Imagen_Orden_Grid(param_Last_Column);
end;

function TForm_Estado_Registro.Filtrar_users_row_changes( param_Last_Column : TColumn;
                                                          param_ver_bajas : ShortInt;
                                                          param_Cambiamos_Filtro : Boolean;
                                                          param_Lineas_Filtro,
                                                          param_Lineas_OrderBy : TStrings ) : ShortInt;
var var_DeleteSQL    : String;
    var_UpdateSQL    : String;
    var_InsertSQL    : String;
    var_ctdad_Rgtros : Integer;
    var_nombre_tabla : ShortString;
    VAR_SQL_SELECT   : String;
    // VAR_SQL_ORDER_BY : String;
begin
    var_DeleteSQL    := '';
    var_UpdateSQL    := '';
    var_InsertSQL    := '';
    var_ctdad_Rgtros := 4;
    var_nombre_tabla := 'r';

    // ********************************************************************************************* //
    // ** No olvidemos que los campos que empiezan por OT_ son campos que pertenecen a otras      ** //
    // ** tablas(JOIN de la SELECT) y que por lo tanto no voy a permitir hacer nada con ellos en  ** //
    // ** form_filtrar_registros y de momento tampoco en form_ordenado_por                        ** //
    // ********************************************************************************************* //
    VAR_SQL_SELECT   := 'SELECT r.*,' +
                              ' u.Descripcion_Nick AS OT_Descripcion_Nick' +

                         ' FROM users_row_changes AS r' +

                       ' LEFT JOIN users AS u' +
                         ' ON r.Id_Users = u.id';

    // VAR_SQL_ORDER_BY := 'ORDER BY up.Id_Users ASC, up.Password ASC';
    if Trim(param_Lineas_OrderBy.Text) = '' then
    begin
         param_Lineas_OrderBy.Text := 'r.tb ASC, r.id ASC, r.Momento ASC, r.Id_Users ASC';
    end;

    Result := UTI_TB_Filtrar( public_Order_By,

                              var_DeleteSQL,
                              var_UpdateSQL,
                              var_InsertSQL,

                              var_ctdad_Rgtros,
                              DataModule_historico_registros.SQLTransaction,
                              DataModule_historico_registros.SQLConnector,
                              SQLQuery_users_row_changes,

                              var_nombre_tabla,
                              param_ver_bajas,

                              VAR_SQL_SELECT,
                              // var_SQL_ORDER_BY,

                              param_Lineas_Filtro,
                              param_Lineas_OrderBy,

                              param_Cambiamos_Filtro );

    UTI_GEN_Borrar_Imagen_Orden_Grid(param_Last_Column);
end;

end.


