unit menus_000;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, sqldb, db, FileUtil, Forms, Controls, Graphics, Dialogs, Buttons, StdCtrls,
    utilidades_usuarios, utilidades_bd, utilidades_rgtro, utilidades_general, ExtCtrls, DBGrids,
    DbCtrls, Grids;

type

    { Tform_menus_000 }

    Tform_menus_000 = class(TForm)
        BitBtn_Filtrar: TBitBtn;
        BitBtn_Imprimir: TBitBtn;
        BitBtn_SALIR: TBitBtn;
        BitBtn_Seleccionar: TBitBtn;
        BitBtn_Ver_Situacion_Registro: TBitBtn;
        DataSource_Menus: TDataSource;
        DBGrid_Principal: TDBGrid;
        DBNavigator1: TDBNavigator;
        Memo_Filtros: TMemo;
        Memo_OrderBy: TMemo;
        RadioGroup_Bajas: TRadioGroup;
        SQLQuery_Menus: TSQLQuery;
        SQLQuery_MenusChange_Id_User: TLargeintField;
        SQLQuery_MenusChange_WHEN: TDateTimeField;
        SQLQuery_MenusDel_Id_User: TLargeintField;
        SQLQuery_MenusDel_WHEN: TDateTimeField;
        SQLQuery_MenusDel_WHY: TStringField;
        SQLQuery_MenusDescripcion: TStringField;
        SQLQuery_Menusid: TLargeintField;
        SQLQuery_MenusId_Menus: TLargeintField;
        SQLQuery_MenusInsert_Id_User: TLargeintField;
        SQLQuery_MenusInsert_WHEN: TDateTimeField;

        procedure Presentar_Datos;
        procedure Cerramos_Tablas;
        procedure DBGrid_PrincipalTitleClick(Column: TColumn);
        procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
        procedure FormDestroy(Sender: TObject);
        procedure Seleccionado_Rgtro;
        procedure BitBtn_SALIRClick(Sender: TObject);
        procedure Insertar_Registro;
        procedure Editar_Registro;
        procedure no_Tocar;
        procedure BitBtn_ImprimirClick(Sender: TObject);
        procedure BitBtn_SeleccionarClick(Sender: TObject);
        procedure BitBtn_Ver_Situacion_RegistroClick(Sender: TObject);
        procedure DBNavigator1BeforeAction(Sender: TObject; Button: TDBNavButtonType);
        procedure Filtrar_tablas_ligadas;
        procedure DBGrid_PrincipalKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
        procedure DBGrid_PrincipalKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
        procedure Dibujar_Grid( param_Sender: TObject; param_SQLQuery : TSQLQuery; param_Rect: TRect; param_DataCol: Integer; param_Column: TColumn; param_State: TGridDrawState );
        procedure DBGrid_PrincipalCellClick(Column: TColumn);
        procedure DBGrid_PrincipalDblClick(Sender: TObject);
        procedure DBGrid_PrincipalDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
        procedure Refrescar_Registros;
        procedure BitBtn_FiltrarClick(Sender: TObject);
        function  Filtrar_Principal( param_Cambiamos_Filtro : Boolean ) : ShortInt;
        procedure FormActivate(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure RadioGroup_BajasClick(Sender: TObject);
        procedure SQLQuery_MenusAfterPost(DataSet: TDataSet);
        procedure SQLQuery_MenusAfterScroll(DataSet: TDataSet);
        procedure SQLQuery_MenusBeforePost(DataSet: TDataSet);

    private
        { private declarations }
        private_Salir_OK    : Boolean;
        private_Last_Column : TColumn;
        private_Order_By    : array of TOrder_By;
    public
        { public declarations }
        public_Elegimos           : Boolean;
        public_Solo_Ver           : Boolean;
        public_Menu_Worked        : Integer;
        public_Rgtro_Seleccionado : Boolean;
    end;

var
    form_menus_000: Tform_menus_000;

implementation

{$R *.lfm}

uses dm_menus, menu, informe, menus_001;

{ Tform_menus_000 }

procedure Tform_menus_000.FormCreate(Sender: TObject);
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
    public_Solo_Ver                 := false;
    public_Elegimos                 := false;

    public_Rgtro_Seleccionado       := false;

    if UTI_GEN_Form_Abierto_Ya('DataModule_Medios') = False then
    begin
        DataModule_Menus := TDataModule_Menus.Create(Application);
    end;

  { ****************************************************************************
    Preparamos los diferentes tipos de orden preconfigurados
    **************************************************************************** }
    SetLength(private_Order_By, 2);

    private_Order_By[0].Titulo       := 'Por la descripción'; // El índice 0 siempre será por el que empezará la aplicación y los filtros
    private_Order_By[0].Memo_OrderBy := 'me.descripcion ASC';

    private_Order_By[1].Titulo       := 'Por la id';
    private_Order_By[1].Memo_OrderBy := 'me.id ASC';

    Memo_OrderBy.Lines.Text          := private_Order_By[0].Memo_OrderBy;

  { ****************************************************************************
    Filtramos los datos
    **************************************************************************** }
    RadioGroup_Bajas.ItemIndex := Filtrar_Principal( false );

    Presentar_Datos;
end;

procedure Tform_menus_000.RadioGroup_BajasClick(Sender: TObject);
begin
    Refrescar_Registros;
end;

procedure Tform_menus_000.SQLQuery_MenusAfterScroll(DataSet: TDataSet);
begin
    Filtrar_tablas_ligadas;
end;

procedure Tform_menus_000.Filtrar_tablas_ligadas;
var var_Lineas : TStrings;
begin
    if SQLQuery_Menus.RecordCount = 0 then Exit;

    var_Lineas := TStringList.Create;
    var_Lineas.Clear;

    // Filtrar_users_passwords( RadioGroup_Bajas.ItemIndex, false, var_Lineas );

    var_Lineas.Free;
end;

procedure Tform_menus_000.SQLQuery_MenusBeforePost(DataSet: TDataSet);
begin
    UTI_RGTRO_param_assign_value( SQLQuery_Menus );
end;

procedure Tform_menus_000.BitBtn_FiltrarClick(Sender: TObject);
begin
    RadioGroup_Bajas.ItemIndex := Filtrar_Principal( true );
end;

procedure Tform_menus_000.FormActivate(Sender: TObject);
begin
    If public_Elegimos = true then
    begin
         BitBtn_Seleccionar.Visible := True;
         BitBtn_Imprimir.Visible  := False;
    end;

    if public_Solo_Ver = true then no_Tocar;
end;

procedure Tform_menus_000.DBNavigator1BeforeAction(Sender: TObject; Button: TDBNavButtonType);
begin
    //Filtrar_tablas_ligadas;

    case Button of
        nbInsert : begin
            Insertar_Registro;
            Abort;
        end;

        nbEdit : begin
            Editar_Registro;
            Abort;
        end;

        nbDelete : begin
            if UTI_usr_Permiso_SN(public_Menu_Worked, 'B', True) = True then
            begin
                UTI_RGTRO_Borrar( SQLQuery_Menus,
                                  public_Solo_Ver,
                                  public_Menu_Worked );
            end;
            Abort;
        end;

        nbRefresh : begin
            Refrescar_Registros;
            Abort;
        end;
    end;
end;

procedure Tform_menus_000.SQLQuery_MenusAfterPost(DataSet: TDataSet);
begin
    UTI_RGTRO_Grabar( DataModule_Menus.SQLTransaction, SQLQuery_Menus );
    Refrescar_Registros;
end;

procedure Tform_menus_000.Refrescar_Registros;
var var_descripcion : String;
begin
    // ********************************************************************************************* //
    // ** OJITO ... NO USAR CAMPOS AUTOINCREMENTABLES                                             ** //
    // ********************************************************************************************* //
    var_descripcion := '';

    if SQLQuery_Menus.RecordCount > 0 then
    begin
        var_descripcion := SQLQuery_Menus.FieldByName('Descripcion').Value;
    end;

    RadioGroup_Bajas.ItemIndex := Filtrar_Principal( false );

    if Trim(var_descripcion) <> '' then SQLQuery_Menus.Locate('Descripcion', var_descripcion, []);
end;

procedure Tform_menus_000.DBGrid_PrincipalCellClick(Column: TColumn);
begin
    //Filtrar_tablas_ligadas;
end;

procedure Tform_menus_000.DBGrid_PrincipalDblClick(Sender: TObject);
begin
    If public_Elegimos then
         Seleccionado_Rgtro
    else Editar_Registro;
end;

procedure Tform_menus_000.DBGrid_PrincipalDrawColumnCell(Sender: TObject; const Rect: TRect;
    DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
    Dibujar_Grid( Sender, SQLQuery_Menus, Rect, DataCol, Column, State );
end;

procedure Tform_menus_000.Dibujar_Grid( param_Sender: TObject;
                                        param_SQLQuery : TSQLQuery;
                                        param_Rect: TRect;
                                        param_DataCol: Integer;
                                        param_Column: TColumn;
                                        param_State: TGridDrawState );
var var_Color_Normal : TColor;
begin
    with param_Sender as TDBGrid do
    begin
        if param_SQLQuery.RecordCount = 0 then Exit;

        var_Color_Normal := Canvas.Brush.Color;

      { ************************************************************************
        Primero comprobamos si es un registro dado de baja o no
        ************************************************************************ }
        if not param_SQLQuery.FieldByName('Del_WHEN').IsNull then
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
                if param_State <> [gdSelected] then
                begin
                    if (param_Column.FieldName <> 'COLUMNA_CON_IMAGEN') then
                    begin
                        Canvas.font.Color := clBlack;
                    end;
                end;
            end;

      { ************************************************************************
        Ahora paso a dibujar una celda normal con los colores elegidos o una
        dibujada
        ************************************************************************ }
        if (param_Column.FieldName <> 'COLUMNA_CON_IMAGEN') then
            begin
              { ****************************************************************
                No es una de las columnas a dibujar por lo que la pinto con los
                colores elegidos
                **************************************************************** }
                DefaultDrawColumnCell(param_Rect, param_DataCol, param_Column, param_State)
            end
        else
            begin
              { ****************************************************************
                Es una de las columnas a dibujar
                **************************************************************** }
                // COLUMNA CONFIRMADA
                if param_Column.FieldName = 'COLUMNA_CON_IMAGEN'  then
                begin
                    {
                    if Trim(param_SQLQuery.FieldByName('id_medio').asString) = '1' then
                    begin
                        Canvas.StretchDraw(param_Rect, Image_Confirmado.Picture.Graphic);
                    end;
                    }
                end;
            end;

        Canvas.Font.Color := var_Color_Normal;
    end;
end;

procedure Tform_menus_000.DBGrid_PrincipalKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
    if Key = 13 then
    begin
        If public_Elegimos then
             Seleccionado_Rgtro
        else Editar_Registro;
    end;
end;

procedure Tform_menus_000.DBGrid_PrincipalKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
    if (key = 40) or
       (key = 38) then
    begin
         //Filtrar_tablas_ligadas;
    end;
end;

procedure Tform_menus_000.BitBtn_Ver_Situacion_RegistroClick(Sender: TObject);
begin
    if UTI_usr_Permiso_SN(public_Menu_Worked, '', True) = True then
    begin
        if SQLQuery_Menus.RecordCount > 0 then UTI_RGTRO_Ver_Estado_Registro( SQLQuery_Menus, DataSource_Menus, DBGrid_Principal );
    end;
end;

procedure Tform_menus_000.BitBtn_ImprimirClick(Sender: TObject);
var var_msg          : TStrings;
    var_form_Informe : Tform_Informe;
begin
    if UTI_usr_Permiso_SN(public_Menu_Worked, 'I', True) = True then
    begin
        if public_Solo_Ver = True then
        begin
            var_msg := TStringList.Create;
            var_msg.Add('Sólo se puede visualizar.');
            UTI_GEN_Aviso(var_msg, 'SOLO PARA OBSERVAR', True, False);
            var_msg.Free;
            Exit;
        end;

        var_form_Informe := Tform_Informe.Create(nil);
        var_form_Informe.frDBDataSet1.DataSource := DataSource_Menus;
        var_form_Informe.public_Menu_Worked      := public_Menu_Worked;
        var_form_Informe.public_informe          := 'informes/menus.lrf';
        var_form_Informe.ShowModal;
        var_form_Informe.Free;
    end;
end;

procedure Tform_menus_000.BitBtn_SeleccionarClick(Sender: TObject);
begin
    Seleccionado_Rgtro;
end;

procedure Tform_menus_000.no_Tocar;
begin
     BitBtn_Imprimir.Enabled := False;
end;

procedure Tform_menus_000.Editar_Registro;
var var_msg  : TStrings;
    var_Form : TForm_menus_001;
begin
    with SQLQuery_Menus do
    begin
        var_msg := TStringList.Create;

        if RecordCount > 0 then
            begin
                if UTI_usr_Permiso_SN(public_Menu_Worked, 'M', True) = True then
                begin
                    Edit;

                    var_Form := TForm_menus_001.Create(nil);

                    var_Form.DBEdit_Codigo.Color      := $006AD3D7;
                    var_Form.DBEdit_Codigo.Font.Color := clRed;
                    var_Form.DBEdit_Codigo.ReadOnly   := true;

                    var_Form.public_Menu_Worked := public_Menu_Worked;

                    if public_Solo_Ver = true then
                    begin
                        var_Form.public_Solo_Ver := true;
                    end;

                    var_Form.ShowModal;
                    if var_Form.public_Pulso_Aceptar = true then
                        begin

                            if ( Trim(var_Form.public_Record_Rgtro.Id)                <> Trim(FieldByName('id').AsString) )          or
                               ( Trim(var_Form.public_Record_Rgtro.MENUS_Descripcion) <> Trim(FieldByName('descripcion').AsString) ) or
                               ( Trim(var_Form.public_Record_Rgtro.MENUS_Id_Menus)    <> Trim(FieldByName('Id_Menus').AsString) )    then
                               begin
                                    FieldByName('Change_WHEN').Value    := UTI_CN_Fecha_Hora;
                                    FieldByName('Change_Id_User').Value := Form_Menu.public_User;
                                    Post;
                               end
                            else Cancel;
                        end
                    else Cancel;

                    var_Form.Free;
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

procedure Tform_menus_000.Insertar_Registro;
var var_msg  : TStrings;
    var_Form : TForm_menus_001;
begin
    with SQLQuery_Menus do
    begin
        var_msg := TStringList.Create;

        if UTI_usr_Permiso_SN(public_Menu_Worked, 'A', True) = True then
        begin
            if public_Solo_Ver = True then
                begin
                    var_msg.Add('Sólo se puede visualizar.');
                    UTI_GEN_Aviso(var_msg, 'SOLO PARA OBSERVAR', True, False);
                end
            else
                begin
                    Insert ;

                    var_Form := TForm_menus_001.Create(nil);

                    var_Form.ShowModal;
                    if var_Form.public_Pulso_Aceptar = true then
                        begin
                            FieldByName('Insert_WHEN').Value    := UTI_CN_Fecha_Hora;
                            FieldByName('Insert_Id_User').Value := Form_Menu.public_User;
                            Post;
                        end
                    else Cancel;

                    var_Form.Free;
                end;
        end;

        var_msg.Free;
    end;
end;

procedure Tform_menus_000.BitBtn_SALIRClick(Sender: TObject);
begin
    private_Salir_OK := true;  { La pongo a true para controlar el modo de BitBtn_SALIR del programa}

    Close;
end;

procedure Tform_menus_000.Seleccionado_Rgtro;
begin
    private_Salir_OK          := true;  { La pongo a true para controlar el modo de BitBtn_SALIR del programa}
    public_Rgtro_Seleccionado := true;
    Close;
end;

procedure Tform_menus_000.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
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
            Fue correcto el modo como quiere BitBtn_SALIR de la aplicación
            ******************************************************************** }
        end;
end;

procedure Tform_menus_000.Cerramos_Tablas;
begin
    if UTI_TB_Cerrar( DataModule_Menus.SQLConnector,
                      DataModule_Menus.SQLTransaction,
                      SQLQuery_Menus ) = false then UTI_GEN_Salir;

    DataModule_Menus.Free;
end;

procedure Tform_menus_000.FormDestroy(Sender: TObject);
begin
     Cerramos_Tablas;
end;

procedure Tform_menus_000.Presentar_Datos;
begin
     /// guardar por lo que pueda pasar
end;

procedure Tform_menus_000.DBGrid_PrincipalTitleClick(Column: TColumn);
begin
    private_Last_Column := UTI_GEN_Ordenar_dbGrid(private_Last_Column, Column, SQLQuery_Menus);
end;

function Tform_menus_000.Filtrar_Principal( param_Cambiamos_Filtro : Boolean ) : ShortInt;
var var_DeleteSQL    : String;
    var_UpdateSQL    : String;
    var_InsertSQL    : String;
    var_ctdad_Rgtros : Integer;
    var_nombre_tabla : ShortString;
    VAR_SQL_SELECT   : String;
    // VAR_SQL_ORDER_BY : String;
begin
    var_DeleteSQL    := '';

    var_UpdateSQL    := 'UPDATE menus' +
                          ' SET Descripcion = :Descripcion,' +
                              ' Id_Menus = :Id_Menus,' +
                              ' id = :id,' +

                              ' Insert_WHEN = :Insert_WHEN,' +
                              ' Insert_Id_User = :Insert_Id_User,' +
                              ' Del_WHEN = :Del_WHEN,' +
                              ' Del_Id_User = :Del_Id_User,' +
                              ' Del_WHY = :Del_WHY,' +
                              ' Change_WHEN = :Change_WHEN,' +
                              ' Change_Id_User = :Change_Id_User' +
                        ' WHERE id = :id';

    var_InsertSQL    := 'INSERT INTO menus' +
                          ' ( descripcion,' +
                            ' Id_Menus,' +
                            ' id,' +

                            ' Insert_WHEN, Insert_Id_User,' +
                            ' Del_WHEN, Del_Id_User, Del_WHY,' +
                            ' Change_WHEN, Change_Id_User )' +
                       ' VALUES' +
                          ' ( :descripcion,' +
                            ' :Id_Menus,' +
                            ' :id,' +

                            ' :Insert_WHEN, :Insert_Id_User,' +
                            ' :Del_WHEN, :Del_Id_User, :Del_WHY,' +
                            ' :Change_WHEN, :Change_Id_User )';

    var_nombre_tabla := 'me';
    var_ctdad_Rgtros := 20;

    VAR_SQL_SELECT   := 'SELECT me.*' + ' ' +
                          'FROM menus AS me';

    // var_SQL_ORDER_BY :=  'ORDER BY m.descripcion ASC';

    Result := UTI_TB_Filtrar( private_Order_By,

                              var_DeleteSQL,
                              var_UpdateSQL,
                              var_InsertSQL,

                              var_ctdad_Rgtros,
                              DataModule_Menus.SQLTransaction,
                              DataModule_Menus.SQLConnector,
                              SQLQuery_Menus,

                              var_nombre_tabla,
                              RadioGroup_Bajas.ItemIndex,

                              VAR_SQL_SELECT,
                              // var_SQL_ORDER_BY,

                              Memo_Filtros.Lines,
                              Memo_OrderBy.Lines,

                              param_Cambiamos_Filtro );

    UTI_GEN_Borrar_Imagen_Orden_Grid(private_Last_Column);

    //Filtrar_tablas_ligadas;
end;

end.

