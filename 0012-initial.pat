From 4a2f93353f0a8e217e056d132d34a5d7d3246105 Mon Sep 17 00:00:00 2001
From: florent Richard <florent.r08@live.fr>
Date: Wed, 28 Apr 2021 11:33:39 +0200
Subject: [PATCH] =?UTF-8?q?Ajout=20de=20la=20fonctionnalit=C3=A9=20pour=20?=
 =?UTF-8?q?modifier=20une=20absence?=
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

---
 MediaTek86/controle/Controle.cs               |  69 +++++-
 MediaTek86/dal/AccesDonnees.cs                |  20 ++
 MediaTek86/vue/GererAbsence.Designer.cs       |   1 +
 MediaTek86/vue/GererAbsence.cs                |  28 ++-
 .../vue/ModificationAbsence.Designer.cs       |  45 ++--
 MediaTek86/vue/ModificationAbsence.cs         | 219 +++++++++++++++++-
 6 files changed, 354 insertions(+), 28 deletions(-)

diff --git a/MediaTek86/controle/Controle.cs b/MediaTek86/controle/Controle.cs
index 0fa8c37..dee1273 100644
--- a/MediaTek86/controle/Controle.cs
+++ b/MediaTek86/controle/Controle.cs
@@ -25,11 +25,21 @@ namespace MediaTek86.controle
         /// </summary>
         private frmModificationPersonnel frmModificationPersonnel;
 
+        /// <summary>
+        /// instance de frmModificationAbsence
+        /// </summary>
+        private frmModificationAbsence frmModificationAbsence;
+
         /// <summary>
         /// instance de frmGererAbsence
         /// </summary>
         private frmGererAbsence frmGererAbsence;
 
+        /// <summary>
+        /// Permet de sauvegarder le personnel séléctionné auparavant
+        /// </summary>
+        private Personnel savePersonnel;
+
         /// <summary>
         /// Ouverture de la fenêtre
         /// </summary>
@@ -86,6 +96,7 @@ namespace MediaTek86.controle
         public void DemGererAbsence()
         {
             Personnel personnel = (Personnel)frmListePersonnel.bdgPersonnel.List[frmListePersonnel.bdgPersonnel.Position];
+            savePersonnel = personnel;
             frmGererAbsence = new frmGererAbsence(this);
             frmGererAbsence.RemplirListeAbsence(personnel);
             frmGererAbsence.SetNom(personnel.Nom);
@@ -142,9 +153,26 @@ namespace MediaTek86.controle
             // Ouvre la fenêtre frmModificationPersonnel
             frmModificationPersonnel.ShowDialog();
         }
+
+        public void DemUpdateAbsence()
+        {
+            // Ferme la fenêtre active
+            frmGererAbsence.Hide();
+            frmModificationAbsence = new frmModificationAbsence(this);
+            Absence absence = (Absence)frmGererAbsence.bdgAbsence.List[frmGererAbsence.bdgAbsence.Position];
+            frmModificationAbsence.SetIdPersonnel(absence.Idpersonnel);
+            frmModificationAbsence.SetNom(absence.Nom);
+            frmModificationAbsence.SetPrenom(absence.Prenom);
+            frmModificationAbsence.SetDateDebut(absence.Date_de_debut);
+            frmModificationAbsence.SetDateFin(absence.Date_de_fin);
+            frmModificationAbsence.SetIdMotif(absence.Idmotif);
+            frmModificationAbsence.SetMotif(absence.Motif);
+            // Ouvre la fenêtre frmModificationPersonnel
+            frmModificationAbsence.ShowDialog();
+        }
         
         /// <summary>
-        /// Demande pour annule la modification d'un personnel 
+        /// Demande pour annuler la modification d'un personnel 
         /// </summary>
         public void AnnulerUpdatePersonnel()
         {
@@ -153,6 +181,22 @@ namespace MediaTek86.controle
             frmListePersonnel.ShowDialog();
         }
 
+        /// <summary>
+        /// Demande pour annuler la modification d'une absence
+        /// </summary>
+        public void AnnulerUpdateAbsence()
+        {
+            frmModificationAbsence.Hide();
+            frmGererAbsence = new frmGererAbsence(this);
+            frmGererAbsence.RemplirListeAbsence(savePersonnel);
+            frmGererAbsence.SetNom(savePersonnel.Nom);
+            frmGererAbsence.SetPrenom(savePersonnel.Prenom);
+            frmGererAbsence.SetIdPersonnel(savePersonnel.Idpersonnel);
+            Console.WriteLine("Nom :" + savePersonnel.Nom);
+            Console.WriteLine("Prenom :" + savePersonnel.Prenom);
+            frmGererAbsence.ShowDialog();
+        }
+
         /// <summary>
         /// Demande pour retourner à la liste des personnels
         /// </summary>
@@ -206,8 +250,27 @@ namespace MediaTek86.controle
             {
                 AccesDonnees.DelAbsence(absence);
                 frmGererAbsence.RemplirListeAbsence(personnel);
-            }
-            
+            } 
+        }
+
+        /// <summary>
+        /// Enregistre les modifications d'une absence
+        /// </summary>
+        /// <param name="datedebut"></param>
+        /// <param name="datefin"></param>
+        public void EnrUpdateAbsence(DateTime datedebut, DateTime datefin)
+        {
+            frmModificationAbsence frm = frmModificationAbsence;
+            Motif motif = (Motif)frm.bdgMotif.List[frm.bdgMotif.Position];
+            Absence absence = new Absence(frm.GetIdPersonnel(), frm.GetNom(), frm.GetPrenom(), frm.GetDateDebut(), frm.GetDateFin(), motif.Idmotif, motif.Libelle);
+            AccesDonnees.UpdateAbsence(absence, datedebut, datefin);
+            frmModificationAbsence.Hide();
+            frmGererAbsence = new frmGererAbsence(this);
+            Personnel personnel = new Personnel(frm.GetIdPersonnel(), frm.GetNom(), frm.GetPrenom(), null, null, 0, null);
+            frmGererAbsence.RemplirListeAbsence(personnel);
+            frmGererAbsence.SetNom(frmModificationAbsence.GetNom());
+            frmGererAbsence.SetPrenom(frmModificationAbsence.GetPrenom());
+            frmGererAbsence.ShowDialog();
         }
     }
 }
diff --git a/MediaTek86/dal/AccesDonnees.cs b/MediaTek86/dal/AccesDonnees.cs
index 2a51c4d..af3386e 100644
--- a/MediaTek86/dal/AccesDonnees.cs
+++ b/MediaTek86/dal/AccesDonnees.cs
@@ -183,6 +183,26 @@ namespace MediaTek86.dal
             conn.ReqUpdate(req, parameters);
         }
 
+        /// <summary>
+        /// Modification d'une absence
+        /// </summary>
+        /// <param name="absence"></param>
+        /// <param name="newdatedebut"></param>
+        /// <param name="newdatefin"></param>
+        public static void UpdateAbsence(Absence absence, DateTime newdatedebut, DateTime newdatefin)
+        {
+            string req = "update absence set datedebut = @newdatedebut, datefin = @newdatefin, idmotif = @idmotif ";
+            req += "where idpersonnel = @idpersonnel and datedebut = @datedebut and datefin = @datefin;";
+            Dictionary<string, object> parameters = new Dictionary<string, object>();
+            parameters.Add("@idpersonnel", absence.Idpersonnel);
+            parameters.Add("@newdatedebut", newdatedebut);
+            parameters.Add("@newdatefin", newdatefin);
+            parameters.Add("@datedebut", absence.Date_de_debut);
+            parameters.Add("@datefin", absence.Date_de_fin);
+            parameters.Add("@idmotif", absence.Idmotif);
+            ConnexionBDD conn = ConnexionBDD.GetInstance(connectionString);
+            conn.ReqUpdate(req, parameters);
+        }
     }
 
 }
diff --git a/MediaTek86/vue/GererAbsence.Designer.cs b/MediaTek86/vue/GererAbsence.Designer.cs
index f203060..5dbd69b 100644
--- a/MediaTek86/vue/GererAbsence.Designer.cs
+++ b/MediaTek86/vue/GererAbsence.Designer.cs
@@ -116,6 +116,7 @@
             this.btnModifAbsence.TabIndex = 17;
             this.btnModifAbsence.Text = "Modifier l\'absence";
             this.btnModifAbsence.UseVisualStyleBackColor = true;
+            this.btnModifAbsence.Click += new System.EventHandler(this.btnModifAbsence_Click);
             // 
             // btnSupAbsence
             // 
diff --git a/MediaTek86/vue/GererAbsence.cs b/MediaTek86/vue/GererAbsence.cs
index cd3c385..4b773e1 100644
--- a/MediaTek86/vue/GererAbsence.cs
+++ b/MediaTek86/vue/GererAbsence.cs
@@ -34,6 +34,8 @@ namespace MediaTek86.vue
         /// </summary>
         private Controle controle;
 
+        public frmModificationAbsence frmModificationAbsence;
+
         /// <summary>
         /// Permet de changer la valeur de idpersonnel
         /// </summary>
@@ -192,9 +194,21 @@ namespace MediaTek86.vue
         /// <param name="e"></param>
         private void btnEnregistrerAbsence_Click(object sender, EventArgs e)
         {
+            DateTime datedebut = dtpDateDebut.Value;
+            DateTime datefin = dtpDateFin.Value;
+            int result = DateTime.Compare(datedebut, datefin);
+
             if (cbbMotif.SelectedIndex != -1)
             {
-                controle.AddAbsence(GetIdPersonnel(), GetNom(), GetPrenom(), dtpDateDebut.Value, dtpDateFin.Value);
+                if (result < 0)
+                {
+                    controle.AddAbsence(GetIdPersonnel(), GetNom(), GetPrenom(), dtpDateDebut.Value, dtpDateFin.Value);
+                }
+                else
+                {
+                    MessageBox.Show("La date de début est supérieur à la date de fin", "Imformation");
+
+                }
             }
             else
             {
@@ -238,5 +252,17 @@ namespace MediaTek86.vue
                 MessageBox.Show("Une ligne doit être sélectionnée.", "Information");
             }
         }
+
+        private void btnModifAbsence_Click(object sender, EventArgs e)
+        {
+            if (dgvAbsence.SelectedRows.Count > 0)
+            {
+                controle.DemUpdateAbsence();
+            }
+            else
+            {
+                MessageBox.Show("Une ligne doit être sélectionnée.", "Information");
+            }
+        }
     }
 }
diff --git a/MediaTek86/vue/ModificationAbsence.Designer.cs b/MediaTek86/vue/ModificationAbsence.Designer.cs
index f81854b..78a49ec 100644
--- a/MediaTek86/vue/ModificationAbsence.Designer.cs
+++ b/MediaTek86/vue/ModificationAbsence.Designer.cs
@@ -32,8 +32,6 @@
             this.lblDescription = new System.Windows.Forms.Label();
             this.btnEnregistrer = new System.Windows.Forms.Button();
             this.cbbMotif = new System.Windows.Forms.ComboBox();
-            this.txtDateDebut = new System.Windows.Forms.TextBox();
-            this.txtDateFin = new System.Windows.Forms.TextBox();
             this.lblMotif = new System.Windows.Forms.Label();
             this.lblDateFin = new System.Windows.Forms.Label();
             this.lblDateDebut = new System.Windows.Forms.Label();
@@ -42,6 +40,8 @@
             this.txtNom = new System.Windows.Forms.TextBox();
             this.lblNom = new System.Windows.Forms.Label();
             this.btnAnnuler = new System.Windows.Forms.Button();
+            this.dtpDateDebut = new System.Windows.Forms.DateTimePicker();
+            this.dtpDateFin = new System.Windows.Forms.DateTimePicker();
             this.SuspendLayout();
             // 
             // lblMail
@@ -71,6 +71,7 @@
             this.btnEnregistrer.TabIndex = 37;
             this.btnEnregistrer.Text = "Enregistrer les modifications";
             this.btnEnregistrer.UseVisualStyleBackColor = true;
+            this.btnEnregistrer.Click += new System.EventHandler(this.btnEnregistrer_Click);
             // 
             // cbbMotif
             // 
@@ -86,22 +87,6 @@
             this.cbbMotif.Size = new System.Drawing.Size(152, 26);
             this.cbbMotif.TabIndex = 36;
             // 
-            // txtDateDebut
-            // 
-            this.txtDateDebut.Font = new System.Drawing.Font("Microsoft Sans Serif", 11.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
-            this.txtDateDebut.Location = new System.Drawing.Point(138, 82);
-            this.txtDateDebut.Name = "txtDateDebut";
-            this.txtDateDebut.Size = new System.Drawing.Size(113, 24);
-            this.txtDateDebut.TabIndex = 35;
-            // 
-            // txtDateFin
-            // 
-            this.txtDateFin.Font = new System.Drawing.Font("Microsoft Sans Serif", 11.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
-            this.txtDateFin.Location = new System.Drawing.Point(138, 110);
-            this.txtDateFin.Name = "txtDateFin";
-            this.txtDateFin.Size = new System.Drawing.Size(113, 24);
-            this.txtDateFin.TabIndex = 34;
-            // 
             // lblMotif
             // 
             this.lblMotif.AutoSize = true;
@@ -176,12 +161,29 @@
             this.btnAnnuler.TabIndex = 42;
             this.btnAnnuler.Text = "Annuler les modifications";
             this.btnAnnuler.UseVisualStyleBackColor = true;
+            this.btnAnnuler.Click += new System.EventHandler(this.btnAnnuler_Click);
+            // 
+            // dtpDateDebut
+            // 
+            this.dtpDateDebut.Location = new System.Drawing.Point(138, 84);
+            this.dtpDateDebut.Name = "dtpDateDebut";
+            this.dtpDateDebut.Size = new System.Drawing.Size(173, 20);
+            this.dtpDateDebut.TabIndex = 43;
+            // 
+            // dtpDateFin
+            // 
+            this.dtpDateFin.Location = new System.Drawing.Point(138, 112);
+            this.dtpDateFin.Name = "dtpDateFin";
+            this.dtpDateFin.Size = new System.Drawing.Size(173, 20);
+            this.dtpDateFin.TabIndex = 44;
             // 
             // frmModificationAbsence
             // 
             this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
             this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
             this.ClientSize = new System.Drawing.Size(533, 226);
+            this.Controls.Add(this.dtpDateFin);
+            this.Controls.Add(this.dtpDateDebut);
             this.Controls.Add(this.btnAnnuler);
             this.Controls.Add(this.txtPrenom);
             this.Controls.Add(this.lblPrenom);
@@ -189,8 +191,6 @@
             this.Controls.Add(this.lblNom);
             this.Controls.Add(this.btnEnregistrer);
             this.Controls.Add(this.cbbMotif);
-            this.Controls.Add(this.txtDateDebut);
-            this.Controls.Add(this.txtDateFin);
             this.Controls.Add(this.lblMotif);
             this.Controls.Add(this.lblDateFin);
             this.Controls.Add(this.lblDateDebut);
@@ -198,6 +198,7 @@
             this.Controls.Add(this.lblDescription);
             this.Name = "frmModificationAbsence";
             this.Text = "Form1";
+            this.Load += new System.EventHandler(this.frmModificationAbsence_Load);
             this.ResumeLayout(false);
             this.PerformLayout();
 
@@ -208,8 +209,6 @@
         private System.Windows.Forms.Label lblDescription;
         private System.Windows.Forms.Button btnEnregistrer;
         private System.Windows.Forms.ComboBox cbbMotif;
-        private System.Windows.Forms.TextBox txtDateDebut;
-        private System.Windows.Forms.TextBox txtDateFin;
         private System.Windows.Forms.Label lblMotif;
         private System.Windows.Forms.Label lblDateFin;
         private System.Windows.Forms.Label lblDateDebut;
@@ -218,5 +217,7 @@
         private System.Windows.Forms.TextBox txtNom;
         private System.Windows.Forms.Label lblNom;
         private System.Windows.Forms.Button btnAnnuler;
+        private System.Windows.Forms.DateTimePicker dtpDateDebut;
+        private System.Windows.Forms.DateTimePicker dtpDateFin;
     }
 }
\ No newline at end of file
diff --git a/MediaTek86/vue/ModificationAbsence.cs b/MediaTek86/vue/ModificationAbsence.cs
index 016b9af..b6ce1d1 100644
--- a/MediaTek86/vue/ModificationAbsence.cs
+++ b/MediaTek86/vue/ModificationAbsence.cs
@@ -1,4 +1,6 @@
-﻿using System;
+﻿using MediaTek86.controle;
+using MediaTek86.modele;
+using System;
 using System.Collections.Generic;
 using System.ComponentModel;
 using System.Data;
@@ -12,13 +14,226 @@ namespace MediaTek86.vue
 {
     public partial class frmModificationAbsence : Form
     {
+        // Déclaration des propriétés
+        private int idpersonnel;
+        private string nom;
+        private string prenom;
+        private DateTime datedebut;
+        private DateTime datefin;
+        private int idmotif;
+        private string motif;
+
+        /// <summary>
+        /// Permet de changer la valeur de idpersonnel
+        /// </summary>
+        /// <param name="idpersonnel"></param>
+        public void SetIdPersonnel(int idpersonnel)
+        {
+            this.idpersonnel = idpersonnel;
+        }
+        /// <summary>
+        /// Permet de changer la valeur du nom
+        /// </summary>
+        /// <param name="nom"></param>
+        public void SetNom(string nom)
+        {
+            this.nom = nom;
+        }
+        /// <summary>
+        /// Permet de changer la valeur du prenom
+        /// </summary>
+        /// <param name="prenom"></param>
+        public void SetPrenom(string prenom)
+        {
+            this.prenom = prenom;
+        }
+        /// <summary>
+        /// Permet de changer la valeur de datedebut
+        /// </summary>
+        /// <param name="datedebut"></param>
+        public void SetDateDebut(DateTime datedebut)
+        {
+            this.datedebut = datedebut;
+        }
+        /// <summary>
+        /// Permet de changer la valeur de datefin
+        /// </summary>
+        /// <param name="datefin"></param>
+        public void SetDateFin(DateTime datefin)
+        {
+            this.datefin = datefin;
+        }
+        /// <summary>
+        /// Permet de changer la valeur de idmotif
+        /// </summary>
+        /// <param name="idmotif"></param>
+        public void SetIdMotif(int idmotif)
+        {
+            this.idmotif = idmotif;
+        }
+        /// <summary>
+        /// Permet de changer la valeur du motif
+        /// </summary>
+        /// <param name="motif"></param>
+        public void SetMotif(string motif)
+        {
+            this.motif = motif;
+        }
+        /// <summary>
+        /// Retourne idpersonnel
+        /// </summary>
+        /// <returns></returns>
+        public int GetIdPersonnel()
+        {
+            return idpersonnel;
+        }
+        /// <summary>
+        /// Retourne le nom
+        /// </summary>
+        /// <returns></returns>
+        public string GetNom()
+        {
+            return nom;
+        }
+        /// <summary>
+        /// Retourne le prenom
+        /// </summary>
+        /// <returns></returns>
+        public string GetPrenom()
+        {
+            return prenom;
+        }
+        /// <summary>
+        /// Retourne datedebut
+        /// </summary>
+        /// <returns></returns>
+        public DateTime GetDateDebut()
+        {
+            return datedebut;
+        }
+        /// <summary>
+        /// Retourne datefin
+        /// </summary>
+        /// <returns></returns>
+        public DateTime GetDateFin()
+        {
+            return datefin;
+        }
+        /// <summary>
+        /// Retourne idmotif
+        /// </summary>
+        /// <returns></returns>
+        public int GetIdMotif()
+        {
+            return idmotif;
+        }
+        /// <summary>
+        /// Retourne le motif
+        /// </summary>
+        /// <returns></returns>
+        public string GetMotif()
+        {
+            return motif;
+        }
+
+        /// <summary>
+        /// Objet pour gérer la liste des motifs
+        /// </summary>
+        public BindingSource bdgMotif = new BindingSource();
+
+        /// <summary>
+        /// instance du controleur
+        /// </summary>
+        private Controle controle;
+
         /// <summary>
         /// Initialisation des composants graphiques
         /// Récupération du controleur
         /// </summary>
-        public frmModificationAbsence()
+        public frmModificationAbsence(Controle controle)
         {
             InitializeComponent();
+            this.controle = controle;
+            Init();
+        }
+
+        /// <summary>
+        /// Initialisation de la frame : remplissage des listes
+        /// </summary>
+        public void Init()
+        {
+            RemplirListeMotif();
+            txtNom.Enabled = false;
+            txtPrenom.Enabled = false;
+        }
+
+       /// <summary>
+       /// Affiche les motifs
+       /// </summary>
+        public void RemplirListeMotif()
+        {
+            controle.GetLesMotifs(bdgMotif);
+            cbbMotif.DataSource = bdgMotif;
+            if (cbbMotif.Items.Count > 0)
+            {
+                cbbMotif.SelectedIndex = 0;
+            }
+        }
+
+        /// <summary>
+        /// Remplis les zones de texte au chargement de la fenêtre
+        /// </summary>
+        /// <param name="sender"></param>
+        /// <param name="e"></param>
+        private void frmModificationAbsence_Load(object sender, EventArgs e)
+        {
+            txtNom.Text = nom;
+            txtPrenom.Text = prenom;
+            dtpDateDebut.Value = datedebut;
+            dtpDateFin.Value = datefin;
+            cbbMotif.SelectedIndex = cbbMotif.FindStringExact(motif);
+        }
+
+        /// <summary>
+        /// Annule les modifications et retourne à la liste des absences
+        /// </summary>
+        /// <param name="sender"></param>
+        /// <param name="e"></param>
+        private void btnAnnuler_Click(object sender, EventArgs e)
+        {
+            controle.AnnulerUpdateAbsence();
+        }
+
+        /// <summary>
+        /// Enregistre les modifications de l'absence
+        /// </summary>
+        /// <param name="sender"></param>
+        /// <param name="e"></param>
+        private void btnEnregistrer_Click(object sender, EventArgs e)
+        {
+            DateTime datedebut = dtpDateDebut.Value;
+            DateTime datefin = dtpDateFin.Value;
+            int result = DateTime.Compare(datedebut, datefin);
+
+            if (cbbMotif.SelectedIndex != -1)
+            {
+                if (result < 0)
+                {
+                    if (MessageBox.Show("Voulez-vous vraiment enregistrer ?", "Confirmation d'enregistrement", MessageBoxButtons.YesNo) == DialogResult.Yes)
+                    {
+                        controle.EnrUpdateAbsence(dtpDateDebut.Value, dtpDateFin.Value);
+                    }
+                }
+                else
+                {
+                    MessageBox.Show("La date de début est supérieur à la date de fin", "Imformation");
+
+                }
+            }
+            else
+            {
+                MessageBox.Show("Tous les champs doivent être remplis.", "Information");
+            }
         }
     }
 }
-- 
2.49.0.windows.1

