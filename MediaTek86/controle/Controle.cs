﻿using MediaTek86.dal;
using MediaTek86.modele;
using MediaTek86.vue;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace MediaTek86.controle
{
    /// <summary>
    /// Gère les interractions entre la vue et le modèle
    /// </summary>
    public class Controle
    {
        /// <summary>
        /// instance de frmListePersonnel
        /// </summary>
        private frmListePersonnel frmListePersonnel;

        /// <summary>
        /// instance de frmModificationPersonnel
        /// </summary>
        private frmModificationPersonnel frmModificationPersonnel;

        /// <summary>
        /// instance de frmGererAbsence
        /// </summary>
        private frmGererAbsence frmGererAbsence;

        /// <summary>
        /// Ouverture de la fenêtre
        /// </summary>
        public Controle()
        {
            frmListePersonnel = new frmListePersonnel(this);
            frmListePersonnel.ShowDialog();
        }

        /// <summary>
        /// Récupère et retourne les infos du personnel provenant de la BDD
        /// </summary>
        /// <param name="bdgListe"></param>
        public void GetLesPersonnels(BindingSource bdgListe)
        {
            List<Personnel> lesPersonnels = AccesDonnees.GetLesPersonnels();
            bdgListe.DataSource = lesPersonnels;
        }

        /// <summary>
        /// Récupère et retourne les infos des services provenant de la BDD
        /// </summary>
        /// <param name="bdgListe"></param>
        public void GetLesServices(BindingSource bdgListe)
        {
            List<Service> lesServices = AccesDonnees.GetLesServices();
            bdgListe.DataSource = lesServices;
        }

        /// <summary>
        /// Récupère et retourne les infos des motifs provenant de la BDD
        /// </summary>
        /// <param name="bdgListe"></param>
        public void GetLesMotifs(BindingSource bdgListe)
        {
            List<Motif> lesMotifs = AccesDonnees.GetLesMotifs();
            bdgListe.DataSource = lesMotifs;
        }

        /// <summary>
        /// Récupère et retourne les infos des absences provenant de la BDD
        /// </summary>
        /// <param name="personnel"></param>
        /// <param name="bdgListe"></param>
        public void GetLesAbsences(Personnel personnel, BindingSource bdgListe)
        {
            List<Absence> lesAbsences = AccesDonnees.GetLesAbsences(personnel);
            bdgListe.DataSource = lesAbsences;
        }

        /// <summary>
        /// Demande pour accéder aux absences d'un personnel
        /// </summary>
        public void DemGererAbsence()
        {
            Personnel personnel = (Personnel)frmListePersonnel.bdgPersonnel.List[frmListePersonnel.bdgPersonnel.Position];
            frmListePersonnel.Hide();
            frmGererAbsence = new frmGererAbsence(this);
            frmGererAbsence.RemplirListeAbsence(personnel);
            frmGererAbsence.SetNom(personnel.Nom);
            frmGererAbsence.SetPrenom(personnel.Prenom);
            frmGererAbsence.SetIdPersonnel(personnel.Idpersonnel);
            frmGererAbsence.ShowDialog();
        }

        /// <summary>
        /// Demande d'ajout d'un personnel
        /// </summary>
        /// <param name="nom"></param>
        /// <param name="prenom"></param>
        /// <param name="tel"></param>
        /// <param name="mail"></param>
        public void AddDeveloppeur(string nom, string prenom, string tel, string mail)
        {
            Service service = (Service)frmListePersonnel.bdgService.List[frmListePersonnel.bdgService.Position];
            int idpersonnel = 0;
            Personnel personnel = new Personnel(idpersonnel, nom, prenom, tel, mail, service.Idservice, service.Nom);
            AccesDonnees.AddPersonnel(personnel);
        }

        /// <summary>
        /// Demande de suppression d'un personnel
        /// </summary>
        public void DelPersonnel()
        {
            Personnel personnel = (Personnel)frmListePersonnel.bdgPersonnel.List[frmListePersonnel.bdgPersonnel.Position];
            if (MessageBox.Show("Voulez-vous vraiment supprimer " + personnel.Nom + " " + personnel.Prenom + " ?", "Confirmation de suppression", MessageBoxButtons.YesNo) == DialogResult.Yes)
            {
                AccesDonnees.DelPersonnel(personnel);
            }
        }

        /// <summary>
        /// Demande pour acceder à la modification d'un personnel
        /// </summary>
        public void DemUpdatePersonnel()
        {
            // Ferme la fenêtre ouverte
            frmListePersonnel.Hide();
            frmModificationPersonnel = new frmModificationPersonnel(this);
            Personnel personnel = (Personnel)frmListePersonnel.bdgPersonnel.List[frmListePersonnel.bdgPersonnel.Position];
            frmModificationPersonnel.idpersonnel = personnel.Idpersonnel;
            frmModificationPersonnel.nom = personnel.Nom;
            frmModificationPersonnel.prenom = personnel.Prenom;
            frmModificationPersonnel.tel = personnel.Tel;
            frmModificationPersonnel.mail = personnel.Mail;
            frmModificationPersonnel.service = personnel.Service;
            // Ouvre la fenêtre frmModificationPersonnel
            frmModificationPersonnel.ShowDialog();
        }

        /// <summary>
        /// Enregistre les modifications d'un personnel
        /// </summary>
        /// <param name="nom"></param>
        /// <param name="prenom"></param>
        /// <param name="tel"></param>
        /// <param name="mail"></param>
        public void EnrUpdatePersonnel(string nom, string prenom, string tel, string mail)
        {
            Service service = (Service)frmModificationPersonnel.bdgService.List[frmModificationPersonnel.bdgService.Position];
            Personnel personnel = new Personnel(frmModificationPersonnel.idpersonnel, nom, prenom, tel, mail, service.Idservice, service.Nom);
            AccesDonnees.UpdatePersonnel(personnel);
            frmModificationPersonnel.Hide();
            frmListePersonnel = new frmListePersonnel(this);
            frmListePersonnel.ShowDialog();
        }
    }
}
