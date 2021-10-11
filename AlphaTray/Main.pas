// PROGRAMME DE DEMONSTRATION DE L'UNITE ALPHA UTILS
// Auteur : Bacterius
// Amusez-vous bien ! (voir AlphaUtils.pas pour plus d'infos pratiques)

unit Main; // Header unité

interface

uses // Les quelques unités (fournies avec Delphi ou avec mon zip) nécessaires pour lancer le programme
  Windows, SysUtils, Classes, Forms, Dialogs,
  ComCtrls, StdCtrls, Controls, AlphaUtils, Menus, ImgList;

type
  TMainForm = class(TForm) // Type fiche
    TrayWndBox: TGroupBox; // Boîte de contrôle "Barre des tâches"
    TrayWndLbl: TLabel; // Indicateur de descripteur de fenêtre pour la barre des tâches
    CompatibleLbl: TLabel; // Indicateur de compatibilité "layering" pour la barre des tâches
    AlphaLbl: TLabel; // Indicateur de valeur alpha pour la barre des tâches
    AlphaBar: TTrackBar; // Barre de transparence pour la barre des tâches
    QuitBtn: TButton; // Bouton "Quitter"
    BonusBox: TGroupBox; // Boîte de contrôle "Bonus"
    BonusLbl: TLabel; // Label d'information pour le bonus
    BonusBar: TTrackBar; // Barre de transparence pour le bonus
    BonusLbl2: TLabel; // Label d'information 2 pour le bonus
    ReturnToDefaultBtn: TButton; // Bouton "Remettre par défaut"
    PopupBtn: TButton; // Bouton ">>" pour afficher le menu déroulant surgissant
    PopupMenu: TPopupMenu; // Objet Popup Menu (menu déroulant surgissant)
    TrayAlphaMenu: TMenuItem; // Elément popup "Transparence de la barre des tâches"
    Tray100AlphaMenu: TMenuItem; // Elément popup "Transparence 100%" pour la barre des tâches
    Tray75AlphaMenu: TMenuItem; // Elément popup "Transparence 75%" pour la barre des tâches
    Tray50AlphaMenu: TMenuItem; // Elément popup "Transparence 50%" pour la barre des tâches
    Tray25AlphaMenu: TMenuItem; // Elément popup "Transparence 25%" pour la barre des tâches
    Tray0AlphaMenu: TMenuItem; // Elément popup "Transparence 0%" pour la barre des tâches
    AppAlphaMenu: TMenuItem; // Elément popup "Transparence de la fiche"
    App100AlphaMenu: TMenuItem; // Elément popup "Transparence 100%" pour la fiche
    App75AlphaMenu: TMenuItem; // Elément popup "Transparence 75%" pour la fiche
    App50AlphaMenu: TMenuItem; // Elément popup "Transparence 50%" pour la fiche
    App25AlphaMenu: TMenuItem; // Elément popup "Transparence 25%" pour la fiche
    App0AlphaMenu: TMenuItem; // Elément popup "Transparence 0%" pour la fiche
    SeparatorMenu: TMenuItem; // Elément popup séparateur
    QuitMenu: TMenuItem;
    PopupImgList: TImageList; // Elément popup "Quitter"
    procedure FormCreate(Sender: TObject); // On crée la fiche
    procedure AlphaBarChange(Sender: TObject); // On change la trackbar de la barre des tâches
    procedure QuitBtnClick(Sender: TObject); // Clic sur le bouton Quitter
    procedure BonusBarChange(Sender: TObject); // Changement de la position de la barre "Bonus"
    procedure FormKeyPress(Sender: TObject; var Key: Char); // Clic sur une touche
    procedure FormClose(Sender: TObject; var Action: TCloseAction); // Fermeture de la fiche
    procedure ReturnToDefaultBtnClick(Sender: TObject); // Clic sur le bouton "Remettre par défaut"
    procedure PopupBtnClick(Sender: TObject); // Clic sur le bouton ">>"
    procedure QuitMenuClick(Sender: TObject); // Clic sur le menu popup "Quitter"
    procedure DefineAlpha(Sender: TObject); // Procédure qui gère les transparences prédéfinies dans le popup
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  MainForm: TMainForm; // Variable fiche
  TrayWnd: HWND; // Handle de la barre des tâches (on ne va pas la chercher dix fois !)
  TrayOldStyle: Integer; // Style de la barre des tâches avant PrepareLayering (important)
  // La transparence de la barre des tâches ne sera pas conservée, pour une raison simple :
  // on remet le style par défaut "sans layering" à la fermeture, et ça annule toute
  // transparence. Mais si on veut conserver la transparence, on enlève ReleaseLayering dans
  // le OnClose. On peut rétablir, de toute façon, plus tard, le style avec une autre paire
  // de PrepareLayering et ReleaseLayering.
  // Remarque : SupportsLayering teste si le layering est présent dans le style de la fiche.
  // Ici, on sait que la barre des tâches et notre fiche ne supportent de toute façon pas
  // le layering, mais je mets la vérification pour montrer comment il faut faire.

implementation

{$R *.dfm} // Link avec le fichier fiche

procedure TMainForm.FormCreate(Sender: TObject); // On crée la fiche
Var
 Alpha: Byte; // Variable pour contenir la transparence de la barre des tâches
 Dummy: Integer; // Variable utile juste pour la compilation, ne sert à rien
begin
 DoubleBuffered := True;  // On évite les scintillements
 TrayWndBox.DoubleBuffered := True; // Idem
 AlphaBar.DoubleBuffered := True; // Idem
 BonusBox.DoubleBuffered := True; // Idem
 BonusBar.DoubleBuffered := True; // Idem
 TrayWnd := GetTrayHWnd; // On récupère le descripteur de fenêtre.

 if not SupportsLayering(Handle) then // Si notre fenêtre ne supporte pas le layering, alors on l'applique
  if not PrepareLayering(Handle, TrayOldStyle) then // Si erreur de préparation de NOTRE fiche ...
   begin
    Height := 175; // On réduit la taille pour cacher la boîte Bonus
    MessageDlg('La fiche ne supporte pas la transparence, vous n''aurez pas accès au bonus.', mtError, [mbOK], 0);
    // On affiche le message
   end;

 Alpha := 255; // Opaque
 if Height <> 175 then SetWindowAlpha(Handle, Alpha); // Si on a accès au bonus, alors on met à 255 (0 par défaut)

 if not SupportsLayering(TrayWnd) then // Si la barre des tâches ne supporte pas le layering, alors on l'applique
  begin
  CompatibleLbl.Caption := 'Gère la transparence : Non.'; // Si elle ne gère pas, alors on l'indique (ça peut quand même marcher)
   if not PrepareLayering(TrayWnd, Dummy) then // Si erreur de préparation ... (Dummy sert juste à pouvoir compiler)
   begin
    MessageDlg('Impossible de préparer la barre des tâches !', mtError, [mbOK], 0);
    // On en informe l'utilisateur ...
    Close; // Et on quitte l'application !
   end
  end
 else CompatibleLbl.Caption := 'Gère la transparence : Oui.'; // Sinon, on dit que la barre des tâches est compatible.

 TrayWndLbl.Caption := 'Descripteur de fenêtre (HWND) : ' + IntToStr(TrayWnd) + '.';
 // On marque le descripteur de fenêtre dans le label prévu à cet effet ...
 GetWindowAlpha(TrayWnd, Alpha); // On récupère la transparence ...
 case Alpha of // On essaye de varier un petit peu les messages quand même !
  255: AlphaLbl.Caption := 'Valeur alpha actuelle : ' + IntToStr(Alpha) + ' (Opaque).';
  1..254: AlphaLbl.Caption := 'Valeur alpha actuelle : ' + IntToStr(Alpha) + '.';
  0: AlphaLbl.Caption := 'Valeur alpha actuelle : ' + IntToStr(Alpha) + ' (Invisible).';
 end;

 AlphaBar.Position := Alpha; // On récupère la transparence de la barre des tâches, et on place la trackbar comme telle
end;

procedure TMainForm.AlphaBarChange(Sender: TObject); // On change la trackbar de la barre des tâches
Var
 Alpha: Byte; // Variable pour contenir la transparence
begin
 Alpha := AlphaBar.Position; // On donne à Alpha la transparence souhaitée par la position de la barre
 SetWindowAlpha(TrayWnd, Alpha); // On définit la transparence
 GetWindowAlpha(TrayWnd, Alpha); // On récupère la transparence
 AlphaBar.Position := Alpha; // On replace la barre d'après la transparence réelle de la barre des tâches
 case Alpha of // On affiche quelques messages différents selon ...
  255: AlphaLbl.Caption := 'Valeur alpha actuelle : ' + IntToStr(Alpha) + ' (Opaque).';
  1..254: AlphaLbl.Caption := 'Valeur alpha actuelle : ' + IntToStr(Alpha) + '.';
  0: AlphaLbl.Caption := 'Valeur alpha actuelle : ' + IntToStr(Alpha) + ' (Invisible).';
 end;
end;

procedure TMainForm.QuitBtnClick(Sender: TObject); // Clic sur le bouton Quitter
begin
 Close; // On lance OnClose !!
end;

procedure TMainForm.BonusBarChange(Sender: TObject); // Changement de la position de la barre "Bonus"
Var
 Alpha: Byte; // Variable qui contient la transparence de notre fiche
begin
 BonusLbl.Caption := 'Bougez la barre pour changer la transparence de la fiche sans AlphaBlend avec une valeur définie par la barre ci-dessous (valeur définie à ' + IntToStr(BonusBar.Position) + ').'; // On modifie le label !
 Alpha := BonusBar.Position; // On donne à Alpha la valeur de transparence voulue
 SetWindowAlpha(Handle, Alpha); // On définit la transparence !
end;

procedure TMainForm.FormKeyPress(Sender: TObject; var Key: Char); // Clic sur une touche
Var
 Alpha: Byte; // Variable qui contient la transparence de notre fiche
begin
 if Height = 175 then Exit; // Si bonus non accessible, on quitte
 if (Key <> 'r') and (Key <> 'R') then Exit; // Si pas la touche "R" ou la touche "r", on quitte
 // Si on est arrivé jusque là c'est que la touche pressée est "R" ou "r", et qu'on a accès au bonus
 Alpha := 255;  // Opacité
 BonusBar.Position := 255; // On fixe la barre à opacité
 SetWindowAlpha(Handle, Alpha); // On définit la transparence à 255 pour rétablir.
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction); // Fermeture de la fiche
begin
 ReleaseLayering(TrayWnd, TrayOldStyle); // On remet la barre des tâches comme avant !
end;

procedure TMainForm.ReturnToDefaultBtnClick(Sender: TObject); // Clic sur le bouton "Remettre par défaut"
begin
 AlphaBar.Position := 255; // On remet la transparence de la barre des tâches à la valeur par défaut (c'est-à-dire 255)
 BonusBar.Position := 255; // On remet la transparence de notre fiche à la valeur par défaut (c'est-à-dire 255)
end;

procedure TMainForm.PopupBtnClick(Sender: TObject); // Clic sur le bouton ">>"
Var
 P: TPoint; // Variable pour récupérer la position de la souris au moment du clic
begin
 GetCursorPos(P); // On récupère la position de la souris
 PopupMenu.Popup(P.X, P.Y); // On fait apparaître le popup à l'endroit de la souris ;)
end;

procedure TMainForm.DefineAlpha(Sender: TObject); // Procédure qui gère les transparences prédéfinies dans le popup
Var
 Alpha: Byte; // Variable qui contient la transparence calculée
begin
 if not (Sender is TMenuItem) then Exit; // Si Sender n'est pas un TMenuItem, on s'en va

 with Sender as TMenuItem do // On prend Sender (typé TMenuItem) comme référence
  begin
   Alpha := Round((Tag / 100) * 255); // Petit calcul pour obtenir la valeur alpha (0..255) à partir du pourcentage (contenu dans le Tag de Sender)
   case GroupIndex of // Selon le GroupIndex de Sender (1 pour la barre des tâches, 2 pour la fiche)
    1: AlphaBar.Position := Alpha; // Si 1 (barre des tâches), on redéfinit la transparence de la barre des tâches
    2: BonusBar.Position := Alpha; // Si 2 (notre fiche), on redéfinit la transparence de notre fiche
   end;
  end;
end;

procedure TMainForm.QuitMenuClick(Sender: TObject); // Clic sur le menu popup "Quitter"
begin
 Close; // On appelle OnClose !
end;

end. // Fin de fichier
