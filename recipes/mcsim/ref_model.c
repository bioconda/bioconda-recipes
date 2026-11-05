/* model.c
   ___________________________________________________

   Model File:  perc.model

   Date:  Wed Jun  3 15:29:54 2020

   Created by:  "../../mod/mod v6.2.0"
    -- a model preprocessor by Don Maszle
   ___________________________________________________

   Copyright (c) 1993-2020 Free Software Foundation, Inc.

   Model calculations for compartmental model:

   6 States:
     Q_fat -> 0.0;
     Q_wp -> 0.0;
     Q_pp -> 0.0;
     Q_liv -> 0.0;
     Q_exh -> 0.0;
     Q_met -> 0.0;

   6 Outputs:
     C_liv -> 0.0;
     C_alv -> 0.0;
     C_exh -> 0.0;
     C_ven -> 0.0;
     Pct_metabolized -> 0.0;
     C_exh_ug -> 0.0;

   2 Inputs:
     C_inh (is a function)
     R_ing (is a function)

   36 Parameters:
     PPM_per_mg_per_l = 72.0 / 0.488;
     mg_per_l_per_PPM = 1/PPM_per_mg_per_l;
     InhMag = 0.0;
     Period = 0.0;
     Exposure = 0.0;
     IngDose = 0.0;
     LeanBodyWt = 55;
     Pct_M_fat = .16;
     Pct_LM_liv = .03;
     Pct_LM_wp = .17;
     Pct_LM_pp = .70;
     Pct_Flow_fat = .09;
     Pct_Flow_liv = .34;
     Pct_Flow_wp = .50;
     Pct_Flow_pp = .07;
     PC_fat = 144;
     PC_liv = 4.6;
     PC_wp = 8.7;
     PC_pp = 1.4;
     PC_art = 12.0;
     Flow_pul = 8.0;
     Vent_Perf = 1.14;
     sc_Vmax = .0026;
     Km = 1.0;
     BodyWt = 0;
     V_fat = 0;
     V_liv = 0;
     V_wp = 0;
     V_pp = 0;
     Flow_fat = 0;
     Flow_liv = 0;
     Flow_wp = 0;
     Flow_pp = 0;
     Flow_tot = 0;
     Flow_alv = 0;
     Vmax = 0;
*/


#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>
#include <float.h>
#include "modelu.h"
#include "random.h"
#include "yourcode.h"


/*----- Indices to Global Variables */

/* Model variables: States and other outputs */
#define ID_Q_fat 0x00000
#define ID_Q_wp 0x00001
#define ID_Q_pp 0x00002
#define ID_Q_liv 0x00003
#define ID_Q_exh 0x00004
#define ID_Q_met 0x00005
#define ID_C_liv 0x00006
#define ID_C_alv 0x00007
#define ID_C_exh 0x00008
#define ID_C_ven 0x00009
#define ID_Pct_metabolized 0x0000a
#define ID_C_exh_ug 0x0000b

/* Inputs */
#define ID_C_inh 0x00000
#define ID_R_ing 0x00001

/* Parameters */
#define ID_PPM_per_mg_per_l 0x0000e
#define ID_mg_per_l_per_PPM 0x0000f
#define ID_InhMag 0x00010
#define ID_Period 0x00011
#define ID_Exposure 0x00012
#define ID_IngDose 0x00013
#define ID_LeanBodyWt 0x00014
#define ID_Pct_M_fat 0x00015
#define ID_Pct_LM_liv 0x00016
#define ID_Pct_LM_wp 0x00017
#define ID_Pct_LM_pp 0x00018
#define ID_Pct_Flow_fat 0x00019
#define ID_Pct_Flow_liv 0x0001a
#define ID_Pct_Flow_wp 0x0001b
#define ID_Pct_Flow_pp 0x0001c
#define ID_PC_fat 0x0001d
#define ID_PC_liv 0x0001e
#define ID_PC_wp 0x0001f
#define ID_PC_pp 0x00020
#define ID_PC_art 0x00021
#define ID_Flow_pul 0x00022
#define ID_Vent_Perf 0x00023
#define ID_sc_Vmax 0x00024
#define ID_Km 0x00025
#define ID_BodyWt 0x00026
#define ID_V_fat 0x00027
#define ID_V_liv 0x00028
#define ID_V_wp 0x00029
#define ID_V_pp 0x0002a
#define ID_Flow_fat 0x0002b
#define ID_Flow_liv 0x0002c
#define ID_Flow_wp 0x0002d
#define ID_Flow_pp 0x0002e
#define ID_Flow_tot 0x0002f
#define ID_Flow_alv 0x00030
#define ID_Vmax 0x00031


/*----- Global Variables */

/* For export. Keep track of who we are. */
char szModelDescFilename[] = "perc.model";
char szModelSourceFilename[] = __FILE__;
char szModelGenAndVersion[] = "../../mod/mod v6.2.0";

/* Externs */
extern BOOL vbModelReinitd;

/* Model Dimensions */
int vnStates = 6;
int vnOutputs = 6;
int vnModelVars = 12;
int vnInputs = 2;
int vnParms = 36;

/* States and Outputs*/
double vrgModelVars[12];

/* Inputs */
IFN vrgInputs[2];

/* Parameters */
double PPM_per_mg_per_l;
double mg_per_l_per_PPM;
double InhMag;
double Period;
double Exposure;
double IngDose;
double LeanBodyWt;
double Pct_M_fat;
double Pct_LM_liv;
double Pct_LM_wp;
double Pct_LM_pp;
double Pct_Flow_fat;
double Pct_Flow_liv;
double Pct_Flow_wp;
double Pct_Flow_pp;
double PC_fat;
double PC_liv;
double PC_wp;
double PC_pp;
double PC_art;
double Flow_pul;
double Vent_Perf;
double sc_Vmax;
double Km;
double BodyWt;
double V_fat;
double V_liv;
double V_wp;
double V_pp;
double Flow_fat;
double Flow_liv;
double Flow_wp;
double Flow_pp;
double Flow_tot;
double Flow_alv;
double Vmax;

BOOL bDelays = 0;


/*----- Global Variable Map */

VMMAPSTRCT vrgvmGlo[] = {
  {"Q_fat", (PVOID) &vrgModelVars[ID_Q_fat], ID_STATE | ID_Q_fat},
  {"Q_wp", (PVOID) &vrgModelVars[ID_Q_wp], ID_STATE | ID_Q_wp},
  {"Q_pp", (PVOID) &vrgModelVars[ID_Q_pp], ID_STATE | ID_Q_pp},
  {"Q_liv", (PVOID) &vrgModelVars[ID_Q_liv], ID_STATE | ID_Q_liv},
  {"Q_exh", (PVOID) &vrgModelVars[ID_Q_exh], ID_STATE | ID_Q_exh},
  {"Q_met", (PVOID) &vrgModelVars[ID_Q_met], ID_STATE | ID_Q_met},
  {"C_liv", (PVOID) &vrgModelVars[ID_C_liv], ID_OUTPUT | ID_C_liv},
  {"C_alv", (PVOID) &vrgModelVars[ID_C_alv], ID_OUTPUT | ID_C_alv},
  {"C_exh", (PVOID) &vrgModelVars[ID_C_exh], ID_OUTPUT | ID_C_exh},
  {"C_ven", (PVOID) &vrgModelVars[ID_C_ven], ID_OUTPUT | ID_C_ven},
  {"Pct_metabolized", (PVOID) &vrgModelVars[ID_Pct_metabolized], ID_OUTPUT | ID_Pct_metabolized},
  {"C_exh_ug", (PVOID) &vrgModelVars[ID_C_exh_ug], ID_OUTPUT | ID_C_exh_ug},
  {"C_inh", (PVOID) &vrgInputs[ID_C_inh], ID_INPUT | ID_C_inh},
  {"R_ing", (PVOID) &vrgInputs[ID_R_ing], ID_INPUT | ID_R_ing},
  {"PPM_per_mg_per_l", (PVOID) &PPM_per_mg_per_l, ID_PARM | ID_PPM_per_mg_per_l},
  {"mg_per_l_per_PPM", (PVOID) &mg_per_l_per_PPM, ID_PARM | ID_mg_per_l_per_PPM},
  {"InhMag", (PVOID) &InhMag, ID_PARM | ID_InhMag},
  {"Period", (PVOID) &Period, ID_PARM | ID_Period},
  {"Exposure", (PVOID) &Exposure, ID_PARM | ID_Exposure},
  {"IngDose", (PVOID) &IngDose, ID_PARM | ID_IngDose},
  {"LeanBodyWt", (PVOID) &LeanBodyWt, ID_PARM | ID_LeanBodyWt},
  {"Pct_M_fat", (PVOID) &Pct_M_fat, ID_PARM | ID_Pct_M_fat},
  {"Pct_LM_liv", (PVOID) &Pct_LM_liv, ID_PARM | ID_Pct_LM_liv},
  {"Pct_LM_wp", (PVOID) &Pct_LM_wp, ID_PARM | ID_Pct_LM_wp},
  {"Pct_LM_pp", (PVOID) &Pct_LM_pp, ID_PARM | ID_Pct_LM_pp},
  {"Pct_Flow_fat", (PVOID) &Pct_Flow_fat, ID_PARM | ID_Pct_Flow_fat},
  {"Pct_Flow_liv", (PVOID) &Pct_Flow_liv, ID_PARM | ID_Pct_Flow_liv},
  {"Pct_Flow_wp", (PVOID) &Pct_Flow_wp, ID_PARM | ID_Pct_Flow_wp},
  {"Pct_Flow_pp", (PVOID) &Pct_Flow_pp, ID_PARM | ID_Pct_Flow_pp},
  {"PC_fat", (PVOID) &PC_fat, ID_PARM | ID_PC_fat},
  {"PC_liv", (PVOID) &PC_liv, ID_PARM | ID_PC_liv},
  {"PC_wp", (PVOID) &PC_wp, ID_PARM | ID_PC_wp},
  {"PC_pp", (PVOID) &PC_pp, ID_PARM | ID_PC_pp},
  {"PC_art", (PVOID) &PC_art, ID_PARM | ID_PC_art},
  {"Flow_pul", (PVOID) &Flow_pul, ID_PARM | ID_Flow_pul},
  {"Vent_Perf", (PVOID) &Vent_Perf, ID_PARM | ID_Vent_Perf},
  {"sc_Vmax", (PVOID) &sc_Vmax, ID_PARM | ID_sc_Vmax},
  {"Km", (PVOID) &Km, ID_PARM | ID_Km},
  {"BodyWt", (PVOID) &BodyWt, ID_PARM | ID_BodyWt},
  {"V_fat", (PVOID) &V_fat, ID_PARM | ID_V_fat},
  {"V_liv", (PVOID) &V_liv, ID_PARM | ID_V_liv},
  {"V_wp", (PVOID) &V_wp, ID_PARM | ID_V_wp},
  {"V_pp", (PVOID) &V_pp, ID_PARM | ID_V_pp},
  {"Flow_fat", (PVOID) &Flow_fat, ID_PARM | ID_Flow_fat},
  {"Flow_liv", (PVOID) &Flow_liv, ID_PARM | ID_Flow_liv},
  {"Flow_wp", (PVOID) &Flow_wp, ID_PARM | ID_Flow_wp},
  {"Flow_pp", (PVOID) &Flow_pp, ID_PARM | ID_Flow_pp},
  {"Flow_tot", (PVOID) &Flow_tot, ID_PARM | ID_Flow_tot},
  {"Flow_alv", (PVOID) &Flow_alv, ID_PARM | ID_Flow_alv},
  {"Vmax", (PVOID) &Vmax, ID_PARM | ID_Vmax},
  {"", NULL, 0} /* End flag */
};  /* vrgpvmGlo[] */


/*----- InitModel
   Should be called to initialize model variables at
   the beginning of experiment before reading
   variants from the simulation spec file.
*/

void InitModel(void)
{
  /* Initialize things in the order that they appear in
     model definition file so that dependencies are
     handled correctly. */

  vrgModelVars[ID_Q_fat] = 0.0;
  vrgModelVars[ID_Q_wp] = 0.0;
  vrgModelVars[ID_Q_pp] = 0.0;
  vrgModelVars[ID_Q_liv] = 0.0;
  vrgModelVars[ID_Q_exh] = 0.0;
  vrgModelVars[ID_Q_met] = 0.0;
  vrgModelVars[ID_C_liv] = 0.0;
  vrgModelVars[ID_C_alv] = 0.0;
  vrgModelVars[ID_C_exh] = 0.0;
  vrgModelVars[ID_C_ven] = 0.0;
  vrgModelVars[ID_Pct_metabolized] = 0.0;
  vrgModelVars[ID_C_exh_ug] = 0.0;
  vrgInputs[ID_C_inh].iType = IFN_PERDOSE;
  vrgInputs[ID_C_inh].dTStartPeriod = 0;
  vrgInputs[ID_C_inh].bOn = FALSE;
  vrgInputs[ID_C_inh].dMag = 0.000000;
  vrgInputs[ID_C_inh].dT0 = 0.000000;
  vrgInputs[ID_C_inh].dTexp = 0.000000;
  vrgInputs[ID_C_inh].dDecay = 0.000000;
  vrgInputs[ID_C_inh].dTper = 0.000000;
  vrgInputs[ID_C_inh].hMag = 0x40010;
  vrgInputs[ID_C_inh].hT0 = 0;
  vrgInputs[ID_C_inh].hTexp = 0x40012;
  vrgInputs[ID_C_inh].hDecay = 0;
  vrgInputs[ID_C_inh].hTper = 0x40011;
  vrgInputs[ID_C_inh].dVal = 0.0;
  vrgInputs[ID_C_inh].nDoses = 0;
  vrgInputs[ID_R_ing].iType = IFN_CONSTANT;
  vrgInputs[ID_R_ing].dTStartPeriod = 0;
  vrgInputs[ID_R_ing].bOn = FALSE;
  vrgInputs[ID_R_ing].dMag = 0.000000;
  vrgInputs[ID_R_ing].dT0 = 0.000000;
  vrgInputs[ID_R_ing].dTexp = 0.000000;
  vrgInputs[ID_R_ing].dDecay = 0.000000;
  vrgInputs[ID_R_ing].dTper = 0.000000;
  vrgInputs[ID_R_ing].hMag = 0;
  vrgInputs[ID_R_ing].hT0 = 0;
  vrgInputs[ID_R_ing].hTexp = 0;
  vrgInputs[ID_R_ing].hDecay = 0;
  vrgInputs[ID_R_ing].hTper = 0;
  vrgInputs[ID_R_ing].dVal = 0.0;
  vrgInputs[ID_R_ing].nDoses = 0;
  PPM_per_mg_per_l = 72.0 / 0.488;
  mg_per_l_per_PPM = 1/PPM_per_mg_per_l;
  InhMag = 0.0;
  Period = 0.0;
  Exposure = 0.0;
  IngDose = 0.0;
  LeanBodyWt = 55;
  Pct_M_fat = .16;
  Pct_LM_liv = .03;
  Pct_LM_wp = .17;
  Pct_LM_pp = .70;
  Pct_Flow_fat = .09;
  Pct_Flow_liv = .34;
  Pct_Flow_wp = .50;
  Pct_Flow_pp = .07;
  PC_fat = 144;
  PC_liv = 4.6;
  PC_wp = 8.7;
  PC_pp = 1.4;
  PC_art = 12.0;
  Flow_pul = 8.0;
  Vent_Perf = 1.14;
  sc_Vmax = .0026;
  Km = 1.0;
  BodyWt = 0;
  V_fat = 0;
  V_liv = 0;
  V_wp = 0;
  V_pp = 0;
  Flow_fat = 0;
  Flow_liv = 0;
  Flow_wp = 0;
  Flow_pp = 0;
  Flow_tot = 0;
  Flow_alv = 0;
  Vmax = 0;

  vbModelReinitd = TRUE;

} /* InitModel */


/*----- Dynamics section */

void CalcDeriv (double  rgModelVars[], double  rgDerivs[], PDOUBLE pdTime)
{
  /* local */ double Cout_fat;
  /* local */ double Cout_wp;
  /* local */ double Cout_pp;
  /* local */ double Cout_liv;
  /* local */ double dQ_ven;
  /* local */ double C_art;
  /* local */ double dQmet_liv;

  CalcInputs (pdTime); /* Get new input vals */


  Cout_fat = rgModelVars[ID_Q_fat] / ( V_fat * PC_fat ) ;

  Cout_wp = rgModelVars[ID_Q_wp] / ( V_wp * PC_wp ) ;

  Cout_pp = rgModelVars[ID_Q_pp] / ( V_pp * PC_pp ) ;

  Cout_liv = rgModelVars[ID_Q_liv] / ( V_liv * PC_liv ) ;

  dQ_ven = Flow_fat * Cout_fat + Flow_wp * Cout_wp + Flow_pp * Cout_pp + Flow_liv * Cout_liv ;

  rgModelVars[ID_C_ven] = dQ_ven / Flow_tot ;

  C_art = ( Flow_alv * vrgInputs[ID_C_inh].dVal / PPM_per_mg_per_l + dQ_ven ) / ( Flow_tot + Flow_alv / PC_art ) ;

  rgModelVars[ID_C_alv] = C_art / PC_art ;

  rgModelVars[ID_C_exh] = 0.7 * rgModelVars[ID_C_alv] + 0.3 * vrgInputs[ID_C_inh].dVal / PPM_per_mg_per_l ;

  dQmet_liv = Vmax * rgModelVars[ID_Q_liv] / ( Km + rgModelVars[ID_Q_liv] ) ;

  rgDerivs[ID_Q_exh] = Flow_alv * rgModelVars[ID_C_alv] ;

  rgDerivs[ID_Q_fat] = Flow_fat * ( C_art - Cout_fat ) ;

  rgDerivs[ID_Q_wp] = Flow_wp * ( C_art - Cout_wp ) ;

  rgDerivs[ID_Q_pp] = Flow_pp * ( C_art - Cout_pp ) ;

  rgDerivs[ID_Q_liv] = vrgInputs[ID_R_ing].dVal + Flow_liv * ( C_art - Cout_liv ) - dQmet_liv ;

  rgDerivs[ID_Q_met] = dQmet_liv ;

} /* CalcDeriv */


/*----- Model scaling */

void ScaleModel (PDOUBLE pdTime)
{

  BodyWt = LeanBodyWt / ( 1 - Pct_M_fat ) ;
  V_fat = Pct_M_fat * BodyWt / 0.92 ;
  V_liv = Pct_LM_liv * LeanBodyWt ;
  V_wp = Pct_LM_wp * LeanBodyWt ;
  V_pp = 0.9 * LeanBodyWt - V_liv - V_wp ;

  Flow_alv = Flow_pul * 0.7 ;

  Flow_tot = Flow_alv / Vent_Perf ;

  Flow_fat = Pct_Flow_fat * Flow_tot ;
  Flow_liv = Pct_Flow_liv * Flow_tot ;
  Flow_pp = Pct_Flow_pp * Flow_tot ;
  Flow_wp = Flow_tot - Flow_fat - Flow_liv - Flow_pp ;

  Vmax = sc_Vmax * exp ( 0.7 * log ( LeanBodyWt ) ) ;

} /* ScaleModel */


/*----- Jacobian calculations */

void CalcJacob (PDOUBLE pdTime, double rgModelVars[],
                long column, double rgdJac[])
{
  /* local */ double jac_fat_fat;
  /* local */ double jac_wp_fat;
  /* local */ double jac_pp_fat;
  /* local */ double jac_liv_fat;
  /* local */ double jac_exh_fat;
  /* local */ double jac_met_fat;
  /* local */ double jac_fat_wp;
  /* local */ double jac_wp_wp;
  /* local */ double jac_pp_wp;
  /* local */ double jac_liv_wp;
  /* local */ double jac_exh_wp;
  /* local */ double jac_met_wp;
  /* local */ double jac_fat_pp;
  /* local */ double jac_wp_pp;
  /* local */ double jac_pp_pp;
  /* local */ double jac_liv_pp;
  /* local */ double jac_exh_pp;
  /* local */ double jac_met_pp;
  /* local */ double jac_fat_liv;
  /* local */ double jac_wp_liv;
  /* local */ double jac_pp_liv;
  /* local */ double jac_liv_liv;
  /* local */ double jac_exh_liv;
  /* local */ double jac_met_liv;
  /* local */ double jac_fat_exh;
  /* local */ double jac_wp_exh;
  /* local */ double jac_pp_exh;
  /* local */ double jac_liv_exh;
  /* local */ double jac_exh_exh;
  /* local */ double jac_met_exh;
  /* local */ double jac_fat_met;
  /* local */ double jac_wp_met;
  /* local */ double jac_pp_met;
  /* local */ double jac_liv_met;
  /* local */ double jac_exh_met;
  /* local */ double jac_met_met;

 switch (column) { 

 case (1): 

  jac_fat_fat = Flow_fat / ( V_fat * PC_fat ) * ( Flow_fat / ( Flow_tot + Flow_alv / PC_art ) - 1 ) ;

  jac_wp_fat = Flow_wp / ( V_fat * PC_fat ) * ( Flow_fat / ( Flow_tot + Flow_alv / PC_art ) ) ;

  jac_pp_fat = Flow_pp / ( V_fat * PC_fat ) * ( Flow_fat / ( Flow_tot + Flow_alv / PC_art ) ) ;

  jac_liv_fat = Flow_liv / ( V_fat * PC_fat ) * ( Flow_fat / ( Flow_tot + Flow_alv / PC_art ) ) ;

  jac_exh_fat = Flow_alv / ( V_fat * PC_fat ) * ( Flow_fat / ( Flow_tot * PC_art + Flow_alv ) ) ;

  jac_met_fat = 0 ;

 rgdJac[0] = jac_fat_fat; 

 rgdJac[1] = jac_wp_fat;  

 rgdJac[2] = jac_pp_fat;  

 rgdJac[3] = jac_liv_fat; 

 rgdJac[4] = jac_exh_fat; 

 rgdJac[5] = jac_met_fat; 

 break; 

 case (2): 

  jac_fat_wp = Flow_fat / ( V_wp * PC_wp ) * ( Flow_wp / ( Flow_tot + Flow_alv / PC_art ) ) ;

  jac_wp_wp = Flow_wp / ( V_wp * PC_wp ) * ( Flow_wp / ( Flow_tot + Flow_alv / PC_art ) - 1 ) ;

  jac_pp_wp = Flow_pp / ( V_wp * PC_wp ) * ( Flow_wp / ( Flow_tot + Flow_alv / PC_art ) ) ;

  jac_liv_wp = Flow_liv / ( V_wp * PC_wp ) * ( Flow_wp / ( Flow_tot + Flow_alv / PC_art ) ) ;

  jac_exh_wp = Flow_alv / ( V_wp * PC_wp ) * ( Flow_wp / ( Flow_tot * PC_art + Flow_alv ) ) ;

  jac_met_wp = 0 ;

 rgdJac[0] = jac_fat_wp; 

 rgdJac[1] = jac_wp_wp;  

 rgdJac[2] = jac_pp_wp;  

 rgdJac[3] = jac_liv_wp; 

 rgdJac[4] = jac_exh_wp; 

 rgdJac[5] = jac_met_wp; 

 break; 

 case (3): 

  jac_fat_pp = Flow_fat / ( V_pp * PC_pp ) * ( Flow_pp / ( Flow_tot + Flow_alv / PC_art ) ) ;

  jac_wp_pp = Flow_wp / ( V_pp * PC_pp ) * ( Flow_pp / ( Flow_tot + Flow_alv / PC_art ) ) ;

  jac_pp_pp = Flow_pp / ( V_pp * PC_pp ) * ( Flow_pp / ( Flow_tot + Flow_alv / PC_art ) - 1 ) ;

  jac_liv_pp = Flow_liv / ( V_pp * PC_pp ) * ( Flow_pp / ( Flow_tot + Flow_alv / PC_art ) ) ;

  jac_exh_pp = Flow_alv / ( V_pp * PC_pp ) * ( Flow_pp / ( Flow_tot * PC_art + Flow_alv ) ) ;

  jac_met_pp = 0 ;

 rgdJac[0] = jac_fat_pp; 

 rgdJac[1] = jac_wp_pp;  

 rgdJac[2] = jac_pp_pp;  

 rgdJac[3] = jac_liv_pp; 

 rgdJac[4] = jac_exh_pp; 

 rgdJac[5] = jac_met_pp; 

 break; 

 case (4): 

  jac_fat_liv = Flow_fat / ( V_liv * PC_liv ) * ( Flow_liv / ( Flow_tot + Flow_alv / PC_art ) ) ;

  jac_wp_liv = Flow_wp / ( V_liv * PC_liv ) * ( Flow_liv / ( Flow_tot + Flow_alv / PC_art ) ) ;

  jac_pp_liv = Flow_pp / ( V_liv * PC_liv ) * ( Flow_liv / ( Flow_tot + Flow_alv / PC_art ) ) ;

  jac_liv_liv = Flow_liv / ( V_liv * PC_liv ) * ( Flow_liv / ( Flow_tot + Flow_alv / PC_art ) - 1 ) - Vmax * Km / ( ( Km + rgModelVars[ID_Q_liv] ) * ( Km + rgModelVars[ID_Q_liv] ) ) ;

  jac_exh_liv = Flow_alv / ( V_liv * PC_liv ) * ( Flow_liv / ( Flow_tot * PC_art + Flow_alv ) ) ;

  jac_met_liv = Vmax * Km / ( ( Km + rgModelVars[ID_Q_liv] ) * ( Km + rgModelVars[ID_Q_liv] ) ) ;

 rgdJac[0] = jac_fat_liv; 

 rgdJac[1] = jac_wp_liv;  

 rgdJac[2] = jac_pp_liv;  

 rgdJac[3] = jac_liv_liv; 

 rgdJac[4] = jac_exh_liv; 

 rgdJac[5] = jac_met_liv; 

 break; 

 case (5): 

  jac_fat_exh = 0 ;

  jac_wp_exh = 0 ;

  jac_pp_exh = 0 ;

  jac_liv_exh = 0 ;

  jac_exh_exh = 0 ;

  jac_met_exh = 0 ;

 rgdJac[0] = jac_fat_exh; 

 rgdJac[1] = jac_wp_exh;  

 rgdJac[2] = jac_pp_exh;  

 rgdJac[3] = jac_liv_exh; 

 rgdJac[4] = jac_exh_exh; 

 rgdJac[5] = jac_met_exh; 

 break; 

 case (6): 

  jac_fat_met = 0 ;

  jac_wp_met = 0 ;

  jac_pp_met = 0 ;

  jac_liv_met = 0 ;

  jac_exh_met = 0 ;

  jac_met_met = 0 ;

 rgdJac[0] = jac_fat_met; 

 rgdJac[1] = jac_wp_met;  

 rgdJac[2] = jac_pp_met;  

 rgdJac[3] = jac_liv_met; 

 rgdJac[4] = jac_exh_met; 

 rgdJac[5] = jac_met_met; 

 break; 

 }  /* end case */

} /* CalcJacob */


/*----- Outputs calculations */

void CalcOutputs (double  rgModelVars[], double  rgDerivs[], PDOUBLE pdTime)
{

  rgModelVars[ID_C_liv] = rgModelVars[ID_Q_liv] / V_liv ;

  rgModelVars[ID_Pct_metabolized] = ( InhMag ? 100 * rgModelVars[ID_Q_met] / ( 1440 * Flow_alv * InhMag * mg_per_l_per_PPM ) : 0 ) ;

  rgModelVars[ID_C_exh_ug] = rgModelVars[ID_C_exh] * 1000 ;

}  /* CalcOutputs */


