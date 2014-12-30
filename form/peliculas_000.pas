unit peliculas_000;

{$mode objfpc}{$H+}

interface

uses
  Dialogs, Classes, sqldb, mysql55conn, db, FileUtil, PrintersDlgs, LR_DBSet, LR_Class, LR_Desgn,
  Forms, Controls, Graphics, DbCtrls, DBGrids, StdCtrls, Buttons, ExtCtrls, utilidades_usuarios,
  utilidades_bd, utilidades_general, SysUtils, Grids, utilidades_rgtro, variants;

type

  { TForm_peliculas_000 }

  TForm_peliculas_000 = class(TForm)

    BitBtn_Filtrar: TBitBtn;
    BitBtn_Imprimir: TBitBtn;
    BitBtn_Seleccionar: TBitBtn;

	BitBtn_Ver_Situacion_Registro: TBitBtn;
    DataSource_Pelis: TDataSource;
	DBGrid_Principal: TDBGrid;
	DBNavigator1: TDBNavigator;
    Image_Confirmado: TImage;
	Memo_Filtros: TMemo;
    Memo_OrderBy: TMemo;
	RadioGroup_Bajas: TRadioGroup;
	BitBtn_SALIR: TBitBtn;
    SQLQuery_Pelis: TSQLQuery;
    SQLQuery_PelisChange_Id_User: TLargeintField;
    SQLQuery_PelisChange_WHEN: TDateTimeField;
    SQLQuery_PelisDel_Id_User: TLargeintField;
    SQLQuery_PelisDel_WHEN: TDateTimeField;
    SQLQuery_PelisDel_WHY: TStringField;
    SQLQuery_Pelisid: TLargeintField;
    SQLQuery_Pelisid_medio: TLargeintField;
    SQLQuery_PelisInsert_Id_User: TLargeintField;
    SQLQuery_PelisInsert_WHEN: TDateTimeField;
    SQLQuery_PelisNumero: TLongintField;
    SQLQuery_PelisOT_descripcion_medio: TStringField;
    SQLQuery_Pelistitulo: TStringField;

    procedure Presentar_Datos;
    procedure DBGrid_PrincipalTitleClick(Column: TColumn);
    function  Filtrar_Principal( param_Cambiamos_Filtro : Boolean ) : ShortInt;
    procedure Filtrar_tablas_ligadas;
    procedure Cerramos_Tablas;
    procedure DBGrid_PrincipalCellClick(Column: TColumn);
    procedure FormDestroy(Sender: TObject);
    procedure no_Tocar;
    procedure BitBtn_ImprimirClick(Sender: TObject);
    procedure Refrescar_Registros;
    procedure Dibujar_Grid( param_Sender: TObject; param_SQLQuery : TSQLQuery; param_Rect: TRect; param_DataCol: Integer; param_Column: TColumn; param_State: TGridDrawState );
    procedure BitBtn_FiltrarClick(Sender: TObject);
    procedure DBGrid_PrincipalDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure DBGrid_PrincipalKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure RadioGroup_BajasClick(Sender: TObject);
    procedure Seleccionado_Rgtro;
    procedure BitBtn_SeleccionarClick(Sender: TObject);
    procedure BitBtn_Ver_Situacion_RegistroClick(Sender: TObject);
    procedure DBGrid_PrincipalDblClick(Sender: TObject);
    procedure DBGrid_PrincipalKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Editar_Registro;
    procedure FormActivate(Sender: TObject);
    procedure Insertar_Registro;

    procedure DBNavigator1BeforeAction(Sender: TObject; Button: TDBNavButtonType);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure BitBtn_SALIRClick(Sender: TObject);
    procedure SQLQuery_PelisAfterPost(DataSet: TDataSet);
    procedure SQLQuery_PelisAfterScroll(DataSet: TDataSet);
    procedure SQLQuery_PelisBeforePost(DataSet: TDataSet);
  private
    { private declarations }
    private_Salir_OK    : Boolean;
    private_Last_Column : TColumn;
    private_Order_By    : array of TOrder_By;
  public
    { public declarations }
    public_Solo_Ver           : Boolean;
    public_Elegimos           : Boolean;
    public_Menu_Worked        : Integer;
    public_Rgtro_Seleccionado : Boolean;
  end;

var
  Form_peliculas_000: TForm_peliculas_000;

implementation

{$R *.lfm}

uses dm_pelis, peliculas_001, menu, informe;

{ TForm_peliculas_000 }

procedure TForm_peliculas_000.FormActivate(Sender: TObject);
begin
    If public_Elegimos = true then
    begin
        BitBtn_Seleccionar.Visible := True;
        BitBtn_Imprimir.Visible  := False;
    end;

    if public_Solo_Ver = true then no_Tocar;
end;

procedure TForm_peliculas_000.FormCreate(Sender: TObject);
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

    if DataModule_Pelis = Nil then
    begin
        DataModule_Pelis := TDataModule_Pelis.Create(Application);
    end;

  { ****************************************************************************
    Preparamos los diferentes tipos de orden preconfigurados
    **************************************************************************** }
    SetLength(private_Order_By, 3);

    private_Order_By[0].Titulo       := 'Por el título'; // El índice 0 siempre será por el que empezará la aplicación y los filtros
    private_Order_By[0].Memo_OrderBy := 'p.titulo ASC';

    private_Order_By[1].Titulo       := 'Por Número';
    private_Order_By[1].Memo_OrderBy := 'p.Numero ASC';

    private_Order_By[2].Titulo       := 'Por la id';
    private_Order_By[2].Memo_OrderBy := 'p.id ASC';

    Memo_OrderBy.Lines.Text          := private_Order_By[0].Memo_OrderBy;

  { ****************************************************************************
    Filtramos los datos
    **************************************************************************** }
    RadioGroup_Bajas.ItemIndex := Filtrar_Principal( false );

    Presentar_Datos;
end;

procedure TForm_peliculas_000.FormClose(Sender: TObject; var CloseAction: TCloseAction);
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

procedure TForm_peliculas_000.Cerramos_Tablas;
begin
    if UTI_TB_Cerrar( DataModule_Pelis.SQLConnector,
                      DataModule_Pelis.SQLTransaction,
                      SQLQuery_Pelis ) = false then
    begin
        Application.Terminate;
    end;

    DataModule_Pelis.Free;
end;

procedure TForm_peliculas_000.RadioGroup_BajasClick(Sender: TObject);
begin
    Refrescar_Registros;
end;

procedure TForm_peliculas_000.BitBtn_SALIRClick(Sender: TObject);
begin
    private_Salir_OK := true;  { La pongo a true para controlar el modo de BitBtn_SALIR del programa}

    Close;
end;

procedure TForm_peliculas_000.DBGrid_PrincipalDblClick(Sender: TObject);
begin
    If public_Elegimos then
         Seleccionado_Rgtro
    else Editar_Registro;
end;

procedure TForm_peliculas_000.DBGrid_PrincipalDrawColumnCell( Sender: TObject;
                                                              const Rect: TRect;
                                                              DataCol: Integer;
                                                              Column: TColumn;
                                                              State: TGridDrawState );
begin
    Dibujar_Grid( Sender, SQLQuery_Pelis, Rect, DataCol, Column, State );
end;

procedure TForm_peliculas_000.Dibujar_Grid( param_Sender: TObject;
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
                Registro dado de baja
                **************************************************************** }
                Canvas.Font.Color := clSilver;
            end
        else
            begin
              { ****************************************************************
                Registro sin estar de baja
                ****************************************************************
                Así que las pinto, pero sólo si no son las columnas que van a
                ser dibujadas
                **************************************************************** }
                if param_State <> [gdSelected] then
                begin
                    if (param_Column.FieldName <> 'id_medio') then
                    begin
                        Canvas.font.Color := clBlack;
                    end;
                end;
            end;

      { ************************************************************************
        Ahora paso a dibujar una celda normal con los colores elegidos o una
        dibujada
        ************************************************************************ }
        if (param_Column.FieldName <> 'id_medio') then
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
                if param_Column.FieldName = 'id_medio'  then
                begin
                    if Trim(param_SQLQuery.FieldByName('id_medio').asString) = '1' then
                    begin
                        Canvas.StretchDraw(param_Rect, Image_Confirmado.Picture.Graphic);
                    end;
                end;
            end;

        Canvas.Font.Color := var_Color_Normal;
    end;
end;

procedure TForm_peliculas_000.DBGrid_PrincipalKeyDown(Sender: TObject; var Key: Word;
    Shift: TShiftState);
begin
    if Key = 13 then
    begin
        If public_Elegimos then
             Seleccionado_Rgtro
        else Editar_Registro;
    end;
end;

procedure TForm_peliculas_000.Seleccionado_Rgtro;
begin
    private_Salir_OK          := true;  { La pongo a true para controlar el modo de BitBtn_SALIR del programa}
    public_Rgtro_Seleccionado := true;
    Close;
end;

procedure TForm_peliculas_000.DBGrid_PrincipalCellClick(Column: TColumn);
begin
    //Filtrar_tablas_ligadas;
end;

procedure TForm_peliculas_000.FormDestroy(Sender: TObject);
begin
    Cerramos_Tablas;
end;

procedure TForm_peliculas_000.DBGrid_PrincipalKeyUp(Sender: TObject; var Key: Word;
    Shift: TShiftState);
begin
    if (key = 40) or
       (key = 38) then
    begin
         //Filtrar_tablas_ligadas;
    end;
end;

procedure TForm_peliculas_000.SQLQuery_PelisAfterScroll(DataSet: TDataSet);
begin
    Filtrar_tablas_ligadas;
end;

procedure TForm_peliculas_000.SQLQuery_PelisBeforePost(DataSet: TDataSet);
begin
    UTI_RGTRO_param_assign_value( SQLQuery_Pelis );
end;

procedure TForm_peliculas_000.DBNavigator1BeforeAction(Sender: TObject;
    Button: TDBNavButtonType);
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
                UTI_RGTRO_Borrar( SQLQuery_Pelis,
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

procedure TForm_peliculas_000.BitBtn_Ver_Situacion_RegistroClick(
    Sender: TObject);
begin
    if UTI_usr_Permiso_SN(public_Menu_Worked, '', True) = True then
    begin
        if SQLQuery_Pelis.RecordCount > 0 then UTI_RGTRO_Ver_Estado_Registro( SQLQuery_Pelis, DataSource_Pelis, DBGrid_Principal );
    end;
end;

procedure TForm_peliculas_000.BitBtn_SeleccionarClick(Sender: TObject);
begin
    Seleccionado_Rgtro;
end;

procedure TForm_peliculas_000.Editar_Registro;
var var_msg                : TStrings;
    var_Form_peliculas_001 : TForm_peliculas_001;
begin
    with SQLQuery_Pelis do
    begin
        var_msg := TStringList.Create;

        if RecordCount > 0 then
            begin
                if UTI_usr_Permiso_SN(public_Menu_Worked, 'M', True) = True then
                begin
                    Edit;

                    var_Form_peliculas_001 := TForm_peliculas_001.Create(nil);
                    // Application.CreateForm(tForm_peliculas_001, Form_peliculas_001);

                    var_Form_peliculas_001.public_Menu_Worked := public_Menu_Worked;

                    if public_Solo_Ver = true then
                    begin
                        var_Form_peliculas_001.public_Solo_Ver := true;
                    end;

                    var_Form_peliculas_001.ShowModal;
                    if var_Form_peliculas_001.public_Pulso_Aceptar = true then
                        begin
                            if ( Trim(var_Form_peliculas_001.public_Record_Rgtro.PELICULAS_titulo)   <> Trim(FieldByName('titulo').AsString) )   or
                               ( Trim(var_Form_peliculas_001.public_Record_Rgtro.PELICULAS_id_medio) <> Trim(FieldByName('id_medio').AsString) ) or
                               ( Trim(var_Form_peliculas_001.public_Record_Rgtro.PELICULAS_Numero)   <> Trim(FieldByName('Numero').AsString) )   then
                               begin
                                    FieldByName('Change_WHEN').Value    := UTI_CN_Fecha_Hora;
                                    FieldByName('Change_Id_User').Value := Form_Menu.public_User;
                                    Post;
                               end
                            else Cancel;
                        end
                    else Cancel;

                    var_Form_peliculas_001.Free;
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

procedure TForm_peliculas_000.BitBtn_ImprimirClick(Sender: TObject);
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
        // Application.CreateForm(Tform_Informe, form_Informe);
        var_form_Informe.frDBDataSet1.DataSource := DataSource_Pelis;
        var_form_Informe.public_Menu_Worked      := public_Menu_Worked;
        var_form_Informe.public_informe          := 'informes/peliculas.lrf';
        var_form_Informe.ShowModal;
        var_form_Informe.Free;
    end;
end;

procedure TForm_peliculas_000.no_Tocar;
begin
     BitBtn_Imprimir.Enabled := False;
end;

procedure TForm_peliculas_000.Insertar_Registro;
var var_msg                : TStrings;
    var_Form_peliculas_001 : TForm_peliculas_001;
begin
    with SQLQuery_Pelis do
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

                    var_Form_peliculas_001 := TForm_peliculas_001.Create(nil);

                    var_Form_peliculas_001.ShowModal;
                    if var_Form_peliculas_001.public_Pulso_Aceptar = true then
                        begin
                            FieldByName('Insert_WHEN').Value    := UTI_CN_Fecha_Hora;
                            FieldByName('Insert_Id_User').Value := Form_Menu.public_User;
                            Post;
                        end
                    else Cancel;

                    var_Form_peliculas_001.Free;
                end;
        end;

        var_msg.Free;
    end;
end;

procedure TForm_peliculas_000.Filtrar_tablas_ligadas;
var var_Lineas : TStrings;
begin
    if SQLQuery_Pelis.RecordCount = 0 then Exit;

    var_Lineas := TStringList.Create;
    var_Lineas.Clear;

    // Filtrar_users_passwords( RadioGroup_Bajas.ItemIndex, false, var_Lineas );

    var_Lineas.Free;
end;

procedure TForm_peliculas_000.DBGrid_PrincipalTitleClick(Column: TColumn);
begin
     private_Last_Column := UTI_GEN_Ordenar_dbGrid(private_Last_Column, Column, SQLQuery_Pelis);
end;

procedure TForm_peliculas_000.Presentar_Datos;
begin
     /// guardar por lo que pueda pasar
end;

procedure TForm_peliculas_000.BitBtn_FiltrarClick(Sender: TObject);
begin
    RadioGroup_Bajas.ItemIndex := Filtrar_Principal( true );
end;

function TForm_peliculas_000.Filtrar_Principal( param_Cambiamos_Filtro : Boolean ) : ShortInt;
var var_DeleteSQL    : String;
    var_UpdateSQL    : String;
    var_InsertSQL    : String;
    var_ctdad_Rgtros : Integer;
    var_nombre_tabla : ShortString;
    VAR_SQL_SELECT   : String;
    // VAR_SQL_ORDER_BY : String;
begin
    var_DeleteSQL    := '';

    var_UpdateSQL    := 'UPDATE peliculas' +
                          ' SET titulo = :titulo,' +
                              ' id_medio = :id_medio,' +
                              ' Numero = :Numero,' +

                              ' Insert_WHEN = :Insert_WHEN,' +
                              ' Insert_Id_User = :Insert_Id_User,' +
                              ' Del_WHEN = :Del_WHEN,' +
                              ' Del_Id_User = :Del_Id_User,' +
                              ' Del_WHY = :Del_WHY,' +
                              ' Change_WHEN = :Change_WHEN,' +
                              ' Change_Id_User = :Change_Id_User' +
                        ' WHERE id = :id';

    var_InsertSQL    := 'INSERT INTO peliculas' +
                         ' ( titulo,' +
                           ' id_medio,' +
                           ' Numero,' +

                           ' Insert_WHEN, Insert_Id_User,' +
                           ' Del_WHEN, Del_Id_User, Del_WHY,' +
                           ' Change_WHEN, Change_Id_User )' +
                       ' VALUES' +
                         ' ( :titulo,' +
                           ' :id_medio,' +
                           ' :Numero,' +

                           ' :Insert_WHEN, :Insert_Id_User,' +
                           ' :Del_WHEN, :Del_Id_User, :Del_WHY,' +
                           ' :Change_WHEN, :Change_Id_User )';

    var_nombre_tabla := 'p';
    var_ctdad_Rgtros := 20;

    // ********************************************************************************************* //
    // ** No olvidemos que los campos que empiezan por OT_ son campos que pertenecen a otras      ** //
    // ** tablas(JOIN de la SELECT) y que por lo tanto no voy a permitir hacer nada con ellos en  ** //
    // ** form_filtrar_registros y de momento tampoco en form_ordenado_por                        ** //
    // ********************************************************************************************* //
    VAR_SQL_SELECT   := 'SELECT p.*,' +
                              ' m.descripcion AS OT_descripcion_medio' +

                         ' FROM peliculas AS p' +

                         ' LEFT JOIN medio AS m' +
                           ' ON p.id_medio = m.id';

    // var_SQL_ORDER_BY :=  'ORDER BY ' + Trim(Memo_OrderBy.Lines.Text);

    Result := UTI_TB_Filtrar( private_Order_By,

                              var_DeleteSQL,
                              var_UpdateSQL,
                              var_InsertSQL,

                              var_ctdad_Rgtros,
                              DataModule_Pelis.SQLTransaction,
                              DataModule_Pelis.SQLConnector,
                              SQLQuery_Pelis,

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

procedure TForm_peliculas_000.Refrescar_Registros;
var var_titulo   : String;
    var_id_medio : Integer;
    var_Numero   : Integer;
begin
    // ********************************************************************************************* //
    // ** OJITO ... NO USAR CAMPOS AUTOINCREMENTABLES                                             ** //
    // ********************************************************************************************* //
    var_titulo   := '';
    var_id_medio := 0;
    var_Numero   := 0;

    if SQLQuery_Pelis.RecordCount > 0 then
    begin
        var_titulo   := SQLQuery_Pelis.FieldByName('titulo').Value;
        var_id_medio := SQLQuery_Pelis.FieldByName('id_medio').Value;
        var_Numero   := SQLQuery_Pelis.FieldByName('Numero').Value;
    end;

    RadioGroup_Bajas.ItemIndex := Filtrar_Principal( false );

    if Trim(var_titulo) <> '' then
    begin
         SQLQuery_Pelis.Locate( 'titulo;id_medio;Numero',
                                VarArrayOf( [ var_titulo, var_id_medio, var_Numero ] ),
                                [] );
    end;
end;

procedure TForm_peliculas_000.SQLQuery_PelisAfterPost(DataSet: TDataSet);
begin
    UTI_RGTRO_Grabar( DataModule_Pelis.SQLTransaction, SQLQuery_Pelis );
    Refrescar_Registros;
end;

end.


