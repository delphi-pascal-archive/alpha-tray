{-------------------------------------------------------------------------------
---------------------------------- ALPHA UTILS ---------------------------------
-------------------------------------------------------------------------------}

{
AlphaUtils : Unit� de gestion de la transparence des fen�tres (AlphaBlending)
Auteur : Bacterius
Utilis� dans l'exemple ci-joint pour la barre des t�ches et pour la fiche principale
Adaptable pour tout type de fen�tre poss�dant un descripteur de fen�tre (HWND) ...
... si elle prend en charge la transparence, bien s�r :]
(vous pouvez forcer la transparence mais �a ne marchera pas � tous les coups !)

==> www.delphifr.com

Vous devrez, comme dans l'exemple, trouver un moyen de m�moriser l'ancien style de
la fen�tre (renvoy� par PrepareLayering), pour pouvoir le passer en param�tre dans
ReleaseLayering. Ceci est particuli�rement utile pour certaines fen�tres (par exemple,
la barre des t�ches dispara�t � l'affichage de la bo�te de dialogue "Arr�ter
l'ordinateur" si l'on ne remet pas son style par d�faut (sans WS_EX_LAYERED)).
ATTENTION : ne pas passer une valeur nulle dans ReleaseLayering, vous pourriez le
regretter. Si vous n'avez pas m�moris� l'ancien style, n'appellez tout simplement
pas la fonction (et pensez � m�moriser la prochaine fois !). En g�n�ral, il n'y
aura pas besoin de m�moriser le style de sa propre fiche (sauf indications
contraires non li�es � cette unit�).

}

{-------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

unit AlphaUtils;

interface

uses Windows; // Uniquement besoin de l'unit� Windows:]

{-------------------------------------------------------------------------------
----------------------------- CONSTANTES DIVERSES ------------------------------
-------------------------------------------------------------------------------}

const // Quelques constantes ...
  WS_EX_LAYERED = $00080000; // Flag pour le style de transparence
  LWA_ALPHA = $00000002;  // Flag pour d�finir la transparence Alpha
  TrayClassName='Shell_TrayWnd'; // Nom de classe de la fen�tre de la barre des t�ches

{-------------------------------------------------------------------------------
--------------------------------- TYPES DIVERS ---------------------------------
-------------------------------------------------------------------------------}



{-------------------------------------------------------------------------------
------------------------------ ROUTINES DIVERSES -------------------------------
-------------------------------------------------------------------------------}

function GetTrayHWnd: HWND; // R�cup�re le HWND (descripteur de fen�tre) de la barre des t�ches (une fonction rien que pour elle !) pour l'utiliser dans les API
function GetDesktopHWnd: HWND; // R�cup�re le HWND (descripteur de fen�tre) du bureau
function GetHWndByWindowName(WindowName: String): HWND; // R�cup�re le HWND (descripteur de fen�tre) d'une fen�tre si on conna�t son nom
function GetHWndByWindowClassName(WindowClassName: String): HWND; // R�cup�re le HWND (descripteur de fen�tre) d'une fen�tre si on conna�t son nom de classe

{-------------------------------------------------------------------------------
------------------------- GESTION DE LA TRANSPARENCE ---------------------------
-------------------------------------------------------------------------------}

{----- FONCTIONS ALPHA UTILS -----}

function PrepareLayering(Wnd: HWND; var Style: Integer; ForceLayering: Boolean=True): Boolean; // Pr�pare la fen�tre � devenir transparente
function ReleaseLayering(Wnd: HWND; Style: Integer): Boolean; // Remet la fen�tre sans style de transparence
function SupportsLayering(Wnd: HWND): Boolean; // V�rifie si la fen�tre supporte le layering
function GetWindowAlpha(Wnd: HWND; var Value: Byte): Boolean; // R�cup�re la valeur alpha de la fen�tre
function SetWindowAlpha(Wnd: HWND; var Value: Byte): Boolean; // D�finit la valeur alpha de la fen�tre

{----- API (ADVANCED PROGRAMMING INTERFACE) -----}

function GetLayeredWindowAttributes(hWnd: HWND; var crKey: COLORREF; var bAlpha: BYTE; var dwFlags: DWORD): BOOL; stdcall; external 'user32.dll';
function SetLayeredWindowAttributes(hWnd: HWND; crKey: COLORREF; bAlpha: BYTE; dwFlags: DWORD): BOOL; stdcall; external 'user32.dll';
// Deux fonctions API externes, pour d�finir les "layered attributes", c'est-�-dire comment une fen�tre doit r�agir avec une fen�tre situ�e "derri�re" elle

{-------------------------------------------------------------------------------
--------------------------------- IMPLEMENTATION -------------------------------
-------------------------------------------------------------------------------}

implementation

{-------------------------------------------------------------------------------
------------------------------ ROUTINES DIVERSES -------------------------------
-------------------------------------------------------------------------------}

function GetTrayHWnd: HWND; // R�cup�re le descripteur de la fen�tre
begin
 Result := FindWindow(TrayClassName, ''); // R�cup�re la fen�tre de la barre des t�ches ...
 // ... � partir du nom de classe de la fen�tre de la barre des t�ches ("Shell_TrayWnd") ...
 // ... d�clar�e comme constante plus haut dans l'unit�.
end;

function GetDesktopHWnd: HWND; // R�cup�re le HWND (descripteur de fen�tre) du bureau
begin
  Result := GetDesktopWindow; // On appelle GetDesktopWindow !
end;

function GetHWndByWindowName(WindowName: String): HWND; // R�cup�re le HWND (descripteur de fen�tre) d'une fen�tre si on conna�t son nom
begin
 Result := FindWindow(nil, PChar(WindowName)); // R�cup�re selon le nom de la fen�tre
 // Quelques exemples : "Inspecteur d'objets", "Main.pas", "Gestionnaire des t�ches de Windows" ^^
end;

function GetHWndByWindowClassName(WindowClassName: String): HWND; // R�cup�re le HWND (descripteur de fen�tre) d'une fen�tre si on conna�t son nom de classe
begin
 Result := FindWindow(PChar(WindowClassName), nil); // R�cup�re selon le nom de classe de la fen�tre
 // Revient au m�me que GetTrayWnd si WindowClassName = TrayClassName (ou "Shell_TrayWnd")
end;


{-------------------------------------------------------------------------------
------------------------- GESTION DE LA TRANSPARENCE ---------------------------
-------------------------------------------------------------------------------}


function PrepareLayering(Wnd: HWND; var Style: Integer; ForceLayering: Boolean=True): Boolean; // Pr�pare la fen�tre � devenir transparente
Var      // Renvoie False si la pr�paration a �chou� (inutile alors d'appeller SetTrayAlpha ou GetTrayAlpha)
 WindowStyle: Integer; // Variable qui contient le style de la fen�tre
begin
 Result := False; // Par d�faut, r�sultat n�gatif
 WindowStyle := GetWindowLong(Wnd, GWL_EXSTYLE); // On r�cup�re le style de la fen�tre
 Style := WindowStyle; // On repasse en param�tre le style de la fen�tre, brut !
 if (WindowStyle = 0) then Exit; // Si le style est nul, pfuit !
 if (not ForceLayering) and (WindowStyle and WS_EX_LAYERED = 0) then Exit; // Si la fen�tre ne prend pas en charge la transparence (et si on ne force pas la transparence)
 if SetWindowLong(Wnd, GWL_EXSTYLE, WindowStyle or WS_EX_LAYERED) = 0 then Exit; // On essaye d'ajouter l'option "transparence" dans le style de la fen�tre
 Result := True; // Si aucune erreur, r�sultat positif !
end;

function ReleaseLayering(Wnd: HWND; Style: Integer): Boolean; // Remet la fen�tre sans style de transparence
Var
 WindowStyle: Integer; // Variable qui contient le style de la fen�tre
begin
 Result := False; // Par d�faut, r�sultat n�gatif
 WindowStyle := Style; // On donne � WindowStyle la valeur de Style
 if (WindowStyle = 0) then Exit; // Si le style est nul, on part.
 if SetWindowLong(Wnd, GWL_EXSTYLE, WindowStyle) = 0 then Exit; // On essaye d'ajouter l'option "transparence" dans le style de la fen�tre
 Result := True; // Si aucune erreur, r�sultat positif !
end;

function SupportsLayering(Wnd: HWND): Boolean; // V�rifie si la fen�tre supporte le layering
Var
 WindowStyle: Integer; // Style de la fen�tre d�finie par Wnd
begin
 WindowStyle := GetWindowLong(Wnd, GWL_EXSTYLE); // On r�cup�re le style de la fen�tre
 Result := (WindowStyle and WS_EX_LAYERED <> 0); // On v�rifie si WS_EX_LAYERED est dedans
end;

function GetWindowAlpha(Wnd: HWND; var Value: Byte): Boolean; // R�cup�ration de la transparence de la fen�tre (Result renvoie la r�ussite de la fonction)
Var
 clrref: COLORREF; // Variable qui sert uniquement pour l'appel � l'API
 Alpha: Byte; // Valeur alpha (on n'utilise pas le param�tre de la fonction directement)
 Flags: DWord; // Variable qui sert uniquement pour l'appel � l'API
begin
 Result := False; // R�sultat n�gatif par d�faut
 if not GetLayeredWindowAttributes(Wnd, clrref, Alpha, Flags) then Exit; // Si on n'arrive pas � r�cup�rer la transparence, on s'en va
 Value := Alpha; // On donne � Value la valeur de Alpha (qui contient la transparence de la fen�tre)
 Result := True; // R�sultat positif si aucune erreur !
end;

function SetWindowAlpha(Wnd: HWND; var Value: Byte): Boolean; // D�finition de la transparence de la fen�tre (Result renvoie la r�ussite de la fonction)
Var
 Alpha: Byte; // Valeur alpha (on n'utilise pas le param�tre de la fonction directement)
begin
 Result := False; // R�sultat n�gatif par d�faut
 Alpha := Value; // On donne � Alpha la valeur de Value (pour l'utiliser dans l'API)
 if not SetLayeredWindowAttributes(Wnd, rgb(0, 0, 0), Alpha, LWA_ALPHA) then Exit;
 // On appelle l'API pour d�finir la transparence - si erreur, on s'en va !
 Result := True; // R�sultat positif si aucune erreur !
end;

end.

