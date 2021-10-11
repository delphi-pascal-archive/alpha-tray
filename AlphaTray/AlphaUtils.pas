{-------------------------------------------------------------------------------
---------------------------------- ALPHA UTILS ---------------------------------
-------------------------------------------------------------------------------}

{
AlphaUtils : Unité de gestion de la transparence des fenêtres (AlphaBlending)
Auteur : Bacterius
Utilisé dans l'exemple ci-joint pour la barre des tâches et pour la fiche principale
Adaptable pour tout type de fenêtre possèdant un descripteur de fenêtre (HWND) ...
... si elle prend en charge la transparence, bien sûr :]
(vous pouvez forcer la transparence mais ça ne marchera pas à tous les coups !)

==> www.delphifr.com

Vous devrez, comme dans l'exemple, trouver un moyen de mémoriser l'ancien style de
la fenêtre (renvoyé par PrepareLayering), pour pouvoir le passer en paramètre dans
ReleaseLayering. Ceci est particulièrement utile pour certaines fenêtres (par exemple,
la barre des tâches disparaît à l'affichage de la boîte de dialogue "Arrêter
l'ordinateur" si l'on ne remet pas son style par défaut (sans WS_EX_LAYERED)).
ATTENTION : ne pas passer une valeur nulle dans ReleaseLayering, vous pourriez le
regretter. Si vous n'avez pas mémorisé l'ancien style, n'appellez tout simplement
pas la fonction (et pensez à mémoriser la prochaine fois !). En général, il n'y
aura pas besoin de mémoriser le style de sa propre fiche (sauf indications
contraires non liées à cette unité).

}

{-------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

unit AlphaUtils;

interface

uses Windows; // Uniquement besoin de l'unité Windows:]

{-------------------------------------------------------------------------------
----------------------------- CONSTANTES DIVERSES ------------------------------
-------------------------------------------------------------------------------}

const // Quelques constantes ...
  WS_EX_LAYERED = $00080000; // Flag pour le style de transparence
  LWA_ALPHA = $00000002;  // Flag pour définir la transparence Alpha
  TrayClassName='Shell_TrayWnd'; // Nom de classe de la fenêtre de la barre des tâches

{-------------------------------------------------------------------------------
--------------------------------- TYPES DIVERS ---------------------------------
-------------------------------------------------------------------------------}



{-------------------------------------------------------------------------------
------------------------------ ROUTINES DIVERSES -------------------------------
-------------------------------------------------------------------------------}

function GetTrayHWnd: HWND; // Récupère le HWND (descripteur de fenêtre) de la barre des tâches (une fonction rien que pour elle !) pour l'utiliser dans les API
function GetDesktopHWnd: HWND; // Récupère le HWND (descripteur de fenêtre) du bureau
function GetHWndByWindowName(WindowName: String): HWND; // Récupère le HWND (descripteur de fenêtre) d'une fenêtre si on connaît son nom
function GetHWndByWindowClassName(WindowClassName: String): HWND; // Récupère le HWND (descripteur de fenêtre) d'une fenêtre si on connaît son nom de classe

{-------------------------------------------------------------------------------
------------------------- GESTION DE LA TRANSPARENCE ---------------------------
-------------------------------------------------------------------------------}

{----- FONCTIONS ALPHA UTILS -----}

function PrepareLayering(Wnd: HWND; var Style: Integer; ForceLayering: Boolean=True): Boolean; // Prépare la fenêtre à devenir transparente
function ReleaseLayering(Wnd: HWND; Style: Integer): Boolean; // Remet la fenêtre sans style de transparence
function SupportsLayering(Wnd: HWND): Boolean; // Vérifie si la fenêtre supporte le layering
function GetWindowAlpha(Wnd: HWND; var Value: Byte): Boolean; // Récupère la valeur alpha de la fenêtre
function SetWindowAlpha(Wnd: HWND; var Value: Byte): Boolean; // Définit la valeur alpha de la fenêtre

{----- API (ADVANCED PROGRAMMING INTERFACE) -----}

function GetLayeredWindowAttributes(hWnd: HWND; var crKey: COLORREF; var bAlpha: BYTE; var dwFlags: DWORD): BOOL; stdcall; external 'user32.dll';
function SetLayeredWindowAttributes(hWnd: HWND; crKey: COLORREF; bAlpha: BYTE; dwFlags: DWORD): BOOL; stdcall; external 'user32.dll';
// Deux fonctions API externes, pour définir les "layered attributes", c'est-à-dire comment une fenêtre doit réagir avec une fenêtre située "derrière" elle

{-------------------------------------------------------------------------------
--------------------------------- IMPLEMENTATION -------------------------------
-------------------------------------------------------------------------------}

implementation

{-------------------------------------------------------------------------------
------------------------------ ROUTINES DIVERSES -------------------------------
-------------------------------------------------------------------------------}

function GetTrayHWnd: HWND; // Récupère le descripteur de la fenêtre
begin
 Result := FindWindow(TrayClassName, ''); // Récupère la fenêtre de la barre des tâches ...
 // ... à partir du nom de classe de la fenêtre de la barre des tâches ("Shell_TrayWnd") ...
 // ... déclarée comme constante plus haut dans l'unité.
end;

function GetDesktopHWnd: HWND; // Récupère le HWND (descripteur de fenêtre) du bureau
begin
  Result := GetDesktopWindow; // On appelle GetDesktopWindow !
end;

function GetHWndByWindowName(WindowName: String): HWND; // Récupère le HWND (descripteur de fenêtre) d'une fenêtre si on connaît son nom
begin
 Result := FindWindow(nil, PChar(WindowName)); // Récupère selon le nom de la fenêtre
 // Quelques exemples : "Inspecteur d'objets", "Main.pas", "Gestionnaire des tâches de Windows" ^^
end;

function GetHWndByWindowClassName(WindowClassName: String): HWND; // Récupère le HWND (descripteur de fenêtre) d'une fenêtre si on connaît son nom de classe
begin
 Result := FindWindow(PChar(WindowClassName), nil); // Récupère selon le nom de classe de la fenêtre
 // Revient au même que GetTrayWnd si WindowClassName = TrayClassName (ou "Shell_TrayWnd")
end;


{-------------------------------------------------------------------------------
------------------------- GESTION DE LA TRANSPARENCE ---------------------------
-------------------------------------------------------------------------------}


function PrepareLayering(Wnd: HWND; var Style: Integer; ForceLayering: Boolean=True): Boolean; // Prépare la fenêtre à devenir transparente
Var      // Renvoie False si la préparation a échoué (inutile alors d'appeller SetTrayAlpha ou GetTrayAlpha)
 WindowStyle: Integer; // Variable qui contient le style de la fenêtre
begin
 Result := False; // Par défaut, résultat négatif
 WindowStyle := GetWindowLong(Wnd, GWL_EXSTYLE); // On récupère le style de la fenêtre
 Style := WindowStyle; // On repasse en paramètre le style de la fenêtre, brut !
 if (WindowStyle = 0) then Exit; // Si le style est nul, pfuit !
 if (not ForceLayering) and (WindowStyle and WS_EX_LAYERED = 0) then Exit; // Si la fenêtre ne prend pas en charge la transparence (et si on ne force pas la transparence)
 if SetWindowLong(Wnd, GWL_EXSTYLE, WindowStyle or WS_EX_LAYERED) = 0 then Exit; // On essaye d'ajouter l'option "transparence" dans le style de la fenêtre
 Result := True; // Si aucune erreur, résultat positif !
end;

function ReleaseLayering(Wnd: HWND; Style: Integer): Boolean; // Remet la fenêtre sans style de transparence
Var
 WindowStyle: Integer; // Variable qui contient le style de la fenêtre
begin
 Result := False; // Par défaut, résultat négatif
 WindowStyle := Style; // On donne à WindowStyle la valeur de Style
 if (WindowStyle = 0) then Exit; // Si le style est nul, on part.
 if SetWindowLong(Wnd, GWL_EXSTYLE, WindowStyle) = 0 then Exit; // On essaye d'ajouter l'option "transparence" dans le style de la fenêtre
 Result := True; // Si aucune erreur, résultat positif !
end;

function SupportsLayering(Wnd: HWND): Boolean; // Vérifie si la fenêtre supporte le layering
Var
 WindowStyle: Integer; // Style de la fenêtre définie par Wnd
begin
 WindowStyle := GetWindowLong(Wnd, GWL_EXSTYLE); // On récupère le style de la fenêtre
 Result := (WindowStyle and WS_EX_LAYERED <> 0); // On vérifie si WS_EX_LAYERED est dedans
end;

function GetWindowAlpha(Wnd: HWND; var Value: Byte): Boolean; // Récupération de la transparence de la fenêtre (Result renvoie la réussite de la fonction)
Var
 clrref: COLORREF; // Variable qui sert uniquement pour l'appel à l'API
 Alpha: Byte; // Valeur alpha (on n'utilise pas le paramètre de la fonction directement)
 Flags: DWord; // Variable qui sert uniquement pour l'appel à l'API
begin
 Result := False; // Résultat négatif par défaut
 if not GetLayeredWindowAttributes(Wnd, clrref, Alpha, Flags) then Exit; // Si on n'arrive pas à récupérer la transparence, on s'en va
 Value := Alpha; // On donne à Value la valeur de Alpha (qui contient la transparence de la fenêtre)
 Result := True; // Résultat positif si aucune erreur !
end;

function SetWindowAlpha(Wnd: HWND; var Value: Byte): Boolean; // Définition de la transparence de la fenêtre (Result renvoie la réussite de la fonction)
Var
 Alpha: Byte; // Valeur alpha (on n'utilise pas le paramètre de la fonction directement)
begin
 Result := False; // Résultat négatif par défaut
 Alpha := Value; // On donne à Alpha la valeur de Value (pour l'utiliser dans l'API)
 if not SetLayeredWindowAttributes(Wnd, rgb(0, 0, 0), Alpha, LWA_ALPHA) then Exit;
 // On appelle l'API pour définir la transparence - si erreur, on s'en va !
 Result := True; // Résultat positif si aucune erreur !
end;

end.

