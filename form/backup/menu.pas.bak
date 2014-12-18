unit menu;

{$mode objfpc}{$H+}

interface

uses
    utilidades_usuarios, Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Buttons, Menus,
    Dialogs, utilidades_forms_Filtrar;

type

    { TForm_Menu }

    TForm_Menu = class(TForm)
        ImageList_Grid_Sort: TImageList;
        MainMenu1: TMainMenu;
        MenuItem1: TMenuItem;
        MenuItem_Usuarios: TMenuItem;
        MenuItem_Menus: TMenuItem;
        MenuItem_Salir: TMenuItem;
        MenuItem_Medios: TMenuItem;
        MenuItem_Peliculas: TMenuItem;
        procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
        procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
        procedure FormCreate(Sender: TObject);
        procedure MenuItem1Click(Sender: TObject);
        procedure MenuItem_MenusClick(Sender: TObject);
        procedure MenuItem_UsuariosClick(Sender: TObject);
        procedure MenuItem_MediosClick(Sender: TObject);
        procedure MenuItem_PeliculasClick(Sender: TObject);
    private
      { private declarations }
        private_Salir_OK : Boolean;
    public
      { public declarations }

      { ************************************************************************
        Variables para la comprobación de la contraseña del usuario
        ************************************************************************ }
        public_User              : Integer;
        public_pwd_No_Caduca     : Boolean;
        public_pwd_Caduca_Inicio : tDateTime;
        public_pwd_Caduca_Fin    : tDateTime;

      { ************************************************************************
        Variables que controlará cuando fué el último momento en el que se
        comprobaron los permisos y no se uso la aplicación.
        ************************************************************************
        Nos sirve para vigilar que el usuario no se olvide la pantalla abierta
        durante mucho tiempo y otro usuario pueda entrar en módulos que no tenga
        privilegios.
        ************************************************************************ }
        public_When_OLD_Permiso : tDateTime;
    end;

var
    Form_Menu: TForm_Menu;

implementation

{$R *.lfm}

{ TForm_Menu }

Uses peliculas_000, medios_000;

procedure TForm_Menu.FormCreate(Sender: TObject);
begin
    ShortDateFormat {%H-} := 'dd/mm/yyyy';
    DateSeparator {%H-} := '/';

  { ****************************************************************************
    Obligado en cada formulario para no olvidarlo
    **************************************************************************** }
    with Self do
    begin
        Position    := poScreenCenter;
        BorderIcons := [biSystemMenu,biMinimize,biMaximize];
        BorderStyle := bsSingle;
    end;

    private_Salir_OK := false;
    { **************************************************************************** }

    public_When_OLD_Permiso := Now;
end;

procedure TForm_Menu.MenuItem1Click(Sender: TObject);
begin
    private_Salir_OK := True;
    Application.Terminate;
end;

procedure TForm_Menu.MenuItem_UsuariosClick(Sender: TObject);
begin
    UTI_Abrir_Form(false, false, '', 30);
end;

procedure TForm_Menu.MenuItem_MediosClick(Sender: TObject);
begin
    UTI_Abrir_Form(false, false, '', 10);
end;

procedure TForm_Menu.MenuItem_PeliculasClick(Sender: TObject);
begin
    UTI_Abrir_Form(false, false, '', 20);
    close;
end;

procedure TForm_Menu.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
{
if MessageDlg('Desea Realmente Salir ...?', mtConfirmation,
   [mbOK, mbCancel],0) =mrCancel then
   begin
        CanClose := False;
   end
   else
   begin
        Application.Terminate;
   end;
}
end;

procedure TForm_Menu.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
    if private_Salir_OK = false then CloseAction := caNone; // Para que nunca se cierre el menu
end;

procedure TForm_Menu.MenuItem_MenusClick(Sender: TObject);
begin
    UTI_Abrir_Form(false, false, '', 40);
end;

end.

JEROFA

Creo que voy a tener que cambiar todos los FreeAndNil() por Destroy ... a la vuelta de llamar a una funcion en la que hice
varios freeandnil, el programa seguia sobre la linea de comandos y el que me daba problemas era un FreeAndNil(form) de un form
Lo resolvi quitando todos los freeandnil de la funcion y convirtiendolos en Destroy

Las llamadas a los diferentes módulos deberían de construir diferentes record asi no tendriamos
un record tan sumamente grande como diferentes tablas se hubieran creado


tambien ver el codigo de errores para copiar y enviar por correo pues lleva un detalle de como ver el valor de cada campo

