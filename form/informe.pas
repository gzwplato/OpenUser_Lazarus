unit informe;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, FileUtil, PrintersDlgs, LR_DBSet, LR_Class, LR_Desgn, Forms, Controls,
    Graphics, Dialogs, ComCtrls, StdCtrls, ExtCtrls, Buttons, utilidades_usuarios, printers;

type

    { Tform_Informe }

    Tform_Informe = class(TForm)
        BitBtn_Imprimir: TBitBtn;
        BitBtn_Design: TBitBtn;
        BitBtn_VPrevia: TBitBtn;
        frDBDataSet1: TfrDBDataSet;
        frDesigner1: TfrDesigner;
        frReport1: TfrReport;
        LabeledEdit_Copias: TLabeledEdit;
        PrintDialog1: TPrintDialog;
        SALIR: TBitBtn;
        UpDown2: TUpDown;
        procedure BitBtn_DesignClick(Sender: TObject);
        procedure BitBtn_ImprimirClick(Sender: TObject);
        procedure BitBtn_VPreviaClick(Sender: TObject);
        procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
        procedure FormCreate(Sender: TObject);
        procedure SALIRClick(Sender: TObject);
    private
        { private declarations }
        private_Salir_OK : Boolean;
    public
        { public declarations }
        public_informe     : String;
        public_Menu_Worked : Integer;
    end;

var
    form_Informe: Tform_Informe;

implementation

{$R *.lfm}

uses menu;

{ Tform_Informe }

procedure Tform_Informe.BitBtn_DesignClick(Sender: TObject);
begin
     if UTI_usr_Permiso_SN(public_Menu_Worked, 'ID', True) = True then // permiso para diseñar informes
     begin
          frReport1.LoadFromFile(public_informe);
          frReport1.DesignReport;
     end;
end;

procedure Tform_Informe.BitBtn_ImprimirClick(Sender: TObject);
var
 FromPage, ToPage, NumberCopies: Integer;
 ind: Integer;
 Collap: Boolean;
begin
     { Carga la definición del reporte desde la carpeta
       de la aplicación }

     //AppDirectory:=ExtractFilePath(ParamStr(0));
     frReport1.LoadFromFile(public_informe);

     { Hay que realizar un seguimiento de qué impresora se seleccionó
       originalmente para comprobar los cambios del usuario }
     ind:= Printer.PrinterIndex;

     { Prepara el informe y se detiene si hay un error.
       Continuar no tiene sentido. }
     if not frReport1.PrepareReport then Exit;

     { Configura el diálogo con algunos parámetros por defecto,
     que el usuario puede cambiar }
     with PrintDialog1 do
     begin
          Options:= [poPageNums ]; // permite seleccionar páginas
          Copies:= 1;
          Collate:= True; // copias ordenadas
          FromPage:= 1; // página de inicio
          ToPage:= frReport1.EMFPages.Count; // última página
          MaxPage:= frReport1.EMFPages.Count; // número máximo de páginas

          { Muestra el diálogo; si tiene éxito, procesa el retorno
          del usuario. }
          if Execute then
          begin
               { Si el usuario cambió la impresora... }
               if (Printer.PrinterIndex <> ind )
               or frReport1.CanRebuild //sólo si podemos cambiar el reporte
               or frReport1.ChangePrinter(ind, Printer.PrinterIndex) then
                    frReport1.PrepareReport //reformatea para la nueva impresora
               else exit; // no pudimos cumplir con el cambio de impresora

               { Si el usuario seleccionó un rango de páginas... }
               if PrintDialog1.PrintRange = prPageNums then
               begin
                    FromPage := PrintDialog1.FromPage; // primera página
                    ToPage   := PrintDialog1.ToPage; // última página
              end;

              NumberCopies := PrintDialog1.Copies; // número de copias

              { Imprime el reporte usando el número de páginas
                y copias indicado }
              frReport1.PrintPreparedReport( IntToStr(FromPage) + '-' +IntToStr(ToPage),
                                             NumberCopies );
          end;
     end;
end;

procedure Tform_Informe.BitBtn_VPreviaClick(Sender: TObject);
begin
     frReport1.LoadFromFile(public_informe);
     frReport1.ShowReport;
end;

procedure Tform_Informe.FormClose(Sender: TObject; var CloseAction: TCloseAction);
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
             Fue correcto el modo como quiere salir de la aplicación
             ******************************************************************** }
         end;
end;

procedure Tform_Informe.FormCreate(Sender: TObject);
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
end;

procedure Tform_Informe.SALIRClick(Sender: TObject);
begin
     private_Salir_OK := true;  { La pongo a true para controlar el modo de salir del programa}

     Close;
end;

end.

