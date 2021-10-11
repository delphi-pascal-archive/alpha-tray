// PROGRAMME DE DEMONSTRATION DE L'UNITE ALPHA UTILS
// Auteur : Bacterius
// Amusez-vous bien ! (voir AlphaUtils.pas pour plus d'infos pratiques)

unit Main; // Header unit�

interface

uses // Les quelques unit�s (fournies avec Delphi ou avec mon zip) n�cessaires pour lancer le programme
  Windows, SysUtils, Classes, Forms, Dialogs,
  ComCtrls, StdCtrls, Controls, AlphaUtils, Menus, ImgList;

type
  TMainForm = class(TForm) // Type fiche
    TrayWndBox: TGroupBox; // Bo�te de contr�le "Barre des t�ches"
    TrayWndLbl: TLabel; // Indicateur de descripteur de fen�tre pour la barre des t�ches
    CompatibleLbl: TLabel; // Indicateur de compatibilit� "layering" pour la barre des t�ches
    AlphaLbl: TLabel; // Indicateur de valeur alpha pour la barre des t�ches
    AlphaBar: TTrackBar; // Barre de transparence pour la barre des t�ches
    QuitBtn: TButton; // Bouton "Quitter"
    BonusBox: TGroupBox; // Bo�te de contr�le "Bonus"
    BonusLbl: TLabel; // Label d'information pour le bonus
    BonusBar: TTrackBar; // Barre de transparence pour le bonus
    BonusLbl2: TLabel; // Label d'information 2 pour le bonus
    ReturnToDefaultBtn: TButton; // Bouton "Remettre par d�faut"
    PopupBtn: TButton; // Bouton ">>" pour afficher le menu d�roulant surgissant
    PopupMenu: TPopupMenu; // Objet Popup Menu (menu d�roulant surgissant)
    TrayAlphaMenu: TMenuItem; // El�ment popup "Transparence de la barre des t�ches"
    Tray100AlphaMenu: TMenuItem; // El�ment popup "Transparence 100%" pour la barre des t�ches
    Tray75AlphaMenu: TMenuItem; // El�ment popup "Transparence 75%" pour la barre des t�ches
    Tray50AlphaMenu: TMenuItem; // El�ment popup "Transparence 50%" pour la barre des t�ches
    Tray25AlphaMenu: TMenuItem; // El�ment popup "Transparence 25%" pour la barre des t�ches
    Tray0AlphaMenu: TMenuItem; // El�ment popup "Transparence 0%" pour la barre des t�ches
    AppAlphaMenu: TMenuItem; // El�ment popup "Transparence de la fiche"
    App100AlphaMenu: TMenuItem; // El�ment popup "Transparence 100%" pour la fiche
    App75AlphaMenu: TMenuItem; // El�ment popup "Transparence 75%" pour la fiche
    App50AlphaMenu: TMenuItem; // El�ment popup "Transparence 50%" pour la fiche
    App25AlphaMenu: TMenuItem; // El�ment popup "Transparence 25%" pour la fiche
    App0AlphaMenu: TMenuItem; // El�ment popup "Transparence 0%" pour la fiche
    SeparatorMenu: TMenuItem; // El�ment popup s�parateur
    QuitMenu: TMenuItem;
    PopupImgList: TImageList; // El�ment popup "Quitter"
    procedure FormCreate(Sender: TObject); // On cr�e la fiche
    procedure AlphaBarChange(Sender: TObject); // On change la trackbar de la barre des t�ches
    procedure QuitBtnClick(Sender: TObject); // Clic sur le bouton Quitter
    procedure BonusBarChange(Sender: TObject); // Changement de la position de la barre "Bonus"
    procedure FormKeyPress(Sender: TObject; var Key: Char); // Clic sur une touche
    procedure FormClose(Sender: TObject; var Action: TCloseAction); // Fermeture de la fiche
    procedure ReturnToDefaultBtnClick(Sender: TObject); // Clic sur le bouton "Remettre par d�faut"
    procedure PopupBtnClick(Sender: TObject); // Clic sur le bouton ">>"
    procedure QuitMenuClick(Sender: TObject); // Clic sur le menu popup "Quitter"
    procedure DefineAlpha(Sender: TObject); // Proc�dure qui g�re les transparences pr�d�finies dans le popup
  private
    { D�clarations priv�es }
  public
    { D�clarations publiques }
  end;

var
  MainForm: TMainForm; // Variable fiche
  TrayWnd: HWND; // Handle de la barre des t�ches (on ne va pas la chercher dix fois !)
  TrayOldStyle: Integer; // Style de la barre des t�ches avant PrepareLayering (important)
  // La transparence de la barre des t�ches ne sera pas conserv�e, pour une raison simple :
  // on remet le style par d�faut "sans layering" � la fermeture, et �a annule toute
  // transparence. Mais si on veut conserver la transparence, on enl�ve ReleaseLayering dans
  // le OnClose. On peut r�tablir, de toute fa�on, plus tard, le style avec une autre paire
  // de PrepareLayering et ReleaseLayering.
  // Remarque : SupportsLayering teste si le layering est pr�sent dans le style de la fiche.
  // Ici, on sait que la barre des t�ches et notre fiche ne supportent de toute fa�on pas
  // le layering, mais je mets la v�rification pour montrer comment il faut faire.

implementation

{$R *.dfm} // Link avec le fichier fiche

procedure TMainForm.FormCreate(Sender: TObject); // On cr�e la fiche
Var
 Alpha: Byte; // Variable pour contenir la transparence de la barre des t�ches
 Dummy: Integer; // Variable utile juste pour la compilation, ne sert � rien
begin
 DoubleBuffered := True;  // On �vite les scintillements
 TrayWndBox.DoubleBuffered := True; // Idem
 AlphaBar.DoubleBuffered := True; // Idem
 BonusBox.DoubleBuffered := True; // Idem
 BonusBar.DoubleBuffered := True; // Idem
 TrayWnd := GetTrayHWnd; // On r�cup�re le descripteur de fen�tre.

 if not SupportsLayering(Handle) then // Si notre fen�tre ne supporte pas le layering, alors on l'applique
  if not PrepareLayering(Handle, TrayOldStyle) then // Si erreur de pr�paration de NOTRE fiche ...
   begin
    Height := 175; // On r�duit la taille pour cacher la bo�te Bonus
    MessageDlg('La fiche ne supporte pas la transparence, vous n''aurez pas acc�s au bonus.', mtError, [mbOK], 0);
    // On affiche le message
   end;

 Alpha := 255; // Opaque
 if Height <> 175 then SetWindowAlpha(Handle, Alpha); // Si on a acc�s au bonus, alors on met � 255 (0 par d�faut)

 if not SupportsLayering(TrayWnd) then // Si la barre des t�ches ne supporte pas le layering, alors on l'applique
  begin
  CompatibleLbl.Caption := 'G�re la transparence : Non.'; // Si elle ne g�re pas, alors on l'indique (�a peut quand m�me marcher)
   if not PrepareLayering(TrayWnd, Dummy) then // Si erreur de pr�paration ... (Dummy sert juste � pouvoir compiler)
   begin
    MessageDlg('Impossible de pr�parer la barre des t�ches !', mtError, [mbOK], 0);
    // On en informe l'utilisateur ...
    Close; // Et on quitte l'application !
   end
  end
 else CompatibleLbl.Caption := 'G�re la transparence : Oui.'; // Sinon, on dit que la barre des t�ches est compatible.

 TrayWndLbl.Caption := 'Descripteur de fen�tre (HWND) : ' + IntToStr(TrayWnd) + '.';
 // On marque le descripteur de fen�tre dans le label pr�vu � cet effet ...
 GetWindowAlpha(TrayWnd, Alpha); // On r�cup�re la transparence ...
 case Alpha of // On essaye de varier un petit peu les messages quand m�me !
  255: AlphaLbl.Caption := 'Valeur alpha actuelle : ' + IntToStr(Alpha) + ' (Opaque).';
  1..254: AlphaLbl.Caption := 'Valeur alpha actuelle : ' + IntToStr(Alpha) + '.';
  0: AlphaLbl.Caption := 'Valeur alpha actuelle : ' + IntToStr(Alpha) + ' (Invisible).';
 end;

 AlphaBar.Position := Alpha; // On r�cup�re la transparence de la barre des t�ches, et on place la trackbar comme telle
end;

procedure TMainForm.AlphaBarChange(Sender: TObject); // On change la trackbar de la barre des t�ches
Var
 Alpha: Byte; // Variable pour contenir la transparence
begin
 Alpha := AlphaBar.Position; // On donne � Alpha la transparence souhait�e par la position de la barre
 SetWindowAlpha(TrayWnd, Alpha); // On d�finit la transparence
 GetWindowAlpha(TrayWnd, Alpha); // On r�cup�re la transparence
 AlphaBar.Position := Alpha; // On replace la barre d'apr�s la transparence r�elle de la barre des t�ches
 case Alpha of // On affiche quelques messages diff�rents selon ...
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
 BonusLbl.Caption := 'Bougez la barre pour changer la transparence de la fiche sans AlphaBlend avec une valeur d�finie par la barre ci-dessous (valeur d�finie � ' + IntToStr(BonusBar.Position) + ').'; // On modifie le label !
 Alpha := BonusBar.Position; // On donne � Alpha la valeur de transparence voulue
 SetWindowAlpha(Handle, Alpha); // On d�finit la transparence !
end;

procedure TMainForm.FormKeyPress(Sender: TObject; var Key: Char); // Clic sur une touche
Var
 Alpha: Byte; // Variable qui contient la transparence de notre fiche
begin
 if Height = 175 then Exit; // Si bonus non accessible, on quitte
 if (Key <> 'r') and (Key <> 'R') then Exit; // Si pas la touche "R" ou la touche "r", on quitte
 // Si on est arriv� jusque l� c'est que la touche press�e est "R" ou "r", et qu'on a acc�s au bonus
 Alpha := 255;  // Opacit�
 BonusBar.Position := 255; // On fixe la barre � opacit�
 SetWindowAlpha(Handle, Alpha); // On d�finit la transparence � 255 pour r�tablir.
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction); // Fermeture de la fiche
begin
 ReleaseLayering(TrayWnd, TrayOldStyle); // On remet la barre des t�ches comme avant !
end;

procedure TMainForm.ReturnToDefaultBtnClick(Sender: TObject); // Clic sur le bouton "Remettre par d�faut"
begin
 AlphaBar.Position := 255; // On remet la transparence de la barre des t�ches � la valeur par d�faut (c'est-�-dire 255)
 BonusBar.Position := 255; // On remet la transparence de notre fiche � la valeur par d�faut (c'est-�-dire 255)
end;

procedure TMainForm.PopupBtnClick(Sender: TObject); // Clic sur le bouton ">>"
Var
 P: TPoint; // Variable pour r�cup�rer la position de la souris au moment du clic
begin
 GetCursorPos(P); // On r�cup�re la position de la souris
 PopupMenu.Popup(P.X, P.Y); // On fait appara�tre le popup � l'endroit de la souris ;)
end;

procedure TMainForm.DefineAlpha(Sender: TObject); // Proc�dure qui g�re les transparences pr�d�finies dans le popup
Var
 Alpha: Byte; // Variable qui contient la transparence calcul�e
begin
 if not (Sender is TMenuItem) then Exit; // Si Sender n'est pas un TMenuItem, on s'en va

 with Sender as TMenuItem do // On prend Sender (typ� TMenuItem) comme r�f�rence
  begin
   Alpha := Round((Tag / 100) * 255); // Petit calcul pour obtenir la valeur alpha (0..255) � partir du pourcentage (contenu dans le Tag de Sender)
   case GroupIndex of // Selon le GroupIndex de Sender (1 pour la barre des t�ches, 2 pour la fiche)
    1: AlphaBar.Position := Alpha; // Si 1 (barre des t�ches), on red�finit la transparence de la barre des t�ches
    2: BonusBar.Position := Alpha; // Si 2 (notre fiche), on red�finit la transparence de notre fiche
   end;
  end;
end;

procedure TMainForm.QuitMenuClick(Sender: TObject); // Clic sur le menu popup "Quitter"
begin
 Close; // On appelle OnClose !
end;

end. // Fin de fichier
