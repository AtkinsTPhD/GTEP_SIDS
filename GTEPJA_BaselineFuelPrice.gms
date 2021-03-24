*=======================================================
* Long term Investment Planning Model for Jamaica
*======================================================
Option optca = 0.001;
option optcr = 0.0001;

*========================
*Defining Sets & Aliases
*========================
Sets
 dow(*)    Day of week from sun to sat
 hr(*)     Hour Index
 dtype(*)  Day type index
 htype(*)  Hour type index
 quart(*)  Quarters in a year
 year(*)   Year index
 wk(*)     Week index

 byear(year)  Base year
 atqwk(quart,wk) Attaching quarters to week
 attday(dtype,dow) Attaching day types to days
 atth(htype,hr)   Attaching hours to hour types

 node(*)          Node in network
 slackbus(node)   Slack bus

 Plant(*)         Power Plant
 EPlant(Plant)     Existing Plant
 DecomPlant(EPlant) Plants to be decommissioned
*Note that ep13 was out of service in 2017
* I assume it is in service since it was built in 2001
 CPlant(Plant)     Candidate Plants
 MustBuildPlant(CPlant) Plants scheduled for construction
 JPSPlant(Eplant)    Plants owned by JPSCo
 IPPPlant(Eplant)    Plants owned by IPPs

 SnSSDJPS(JPSPlant)  Existing JPSCo steam and slow speed deisel plants
 GTJPS(JPSPlant)     Existing JPSCo gas turbine plants
 CCJPS(JPSPlant)     Existing JPSCo combined cycle plants
 HydroJPS(JPSPlant)  Existing JPSCo hydro plants
;

Alias (dow,ddow),(hr,hhr),(htype,hhtype),(dtype,ddtype),(quart,q),(year,y),(wk,wwk),(node,n);

Sets
 Tline(*)      Transmission Lines
 ETLine(TLine) Existing Transmission Lines
 CTLine(TLine) Candidate Transmission Lines

 Tec(*)       Technology set
 Thermal(Tec) Thermal Fossil Fuel Technologies set
 RETec(Tec)   Renewable Energy Technology set
 RETecnb(tec) Renewable Technology set excluding biomass
 Biomass(tec) Biomass Technology
 nhre(tec)    Wind and Solar technology
 hyth(tec)    Hydro and thermal technologies

 PlantType(plant,tec) Attaching Plants to technology
 MapPlant(node,Plant) Attaching Plants to nodes
 MapTline(Tline,node,n) Tranmission network mapping nodes to transmission lines


 TlineHeadings(*)  Column headings for Tline parameter table
 PlantHeadings(*)  Column headings for Plant parameter table
 ScalarHeadings(*) Headings for scalar values for import
 CalHeadings(*)    Headings for Calibration data;

Sets
  ModelType Model Type  /calibrate,sim_KVL,seq_KVL_a,seq_KVL_b,no_KVL/
  FPScenarios Fuel Price Scenarios /Baseline, High, Low/   ;

*======================
*Parameters for import
*======================
Parameters
 Tlinedata(Tline,Tlineheadings) Relevant parameters for transmission lines
 PlantData(plant,tec,PlantHeadings) Relevant parameters for power plants
 AvailabilityFactor(plant,tec,htype) Availability factor
 FuelPriceBaseline(year,thermal) Fuel Price (baseline) for thermal plants in 2017$ per mmBtu
 FuelPriceLow(year,thermal) Fuel price for low fuel price scenario (2017$ per mmBtu)
 FuelPriceHigh(year,thermal) Fuel price for high fuel price scenario (2017$ per mmBtu)
 Demand(node,year,quart,dtype,htype)  Average Demand in MW each hour
 PeakDem(year,quart)  System Peak Demand in MW each year and quarter
 ScalarParams(ScalarHeadings) Scalars
 MapTline1(tline,node,n) Parameter representation of network
 CalData(CalHeadings)  Actual 2017 data for comparing and calibrating model
 Rainfall(quart)
;

*================================================================================
*The followling creates a text file with coordinates and structure for importing
*data froom the Excel data file
*===============================================================================
$onecho > gtepinput.txt
set=dow    rng=Set_Time!D2:J2     cdim= 1
set=hr    rng=Set_Time!D3:AA3    cdim=1
set=dtype  rng=Set_Time!D4:E4     cdim=1
set=htype  rng=Set_Time!D5:H5     cdim=1
set=quart   rng=Set_Time!D6:G6    cdim=1
set=ayear   rng=Set_Time!D7:AA7   cdim=1
set=wk      rng=Set_Time!D8:BC8   cdim=1

set=byear   rng=Set_Time!D10      cdim=1
set=atqwk     rng=Set_Time!D13:Bc14  cdim=2
set=attday  rng=Set_Time!D16:E22    rdim=2
set=atth    rng=Set_Time!D24:AA25   cdim=2

set=node    rng=Set_Nodes!D2:S2    cdim=1
set=slackbus rng=Set_Nodes!D3      cdim=1
set=Plant   rng=Set_Plant!D2:DJ2   cdim=1
set=EPlant  rng=Set_Plant!D4:AH4   cdim=1
set=DecomPlant rng=Set_Plant!D5:M5  cdim=1
set=CPlant  rng=Set_Plant!D6:CE6   cdim=1
set=MustBuildPlant rng=Set_Plant!D7 cdim=1
set=JPSPlant rng=Set_Plant!D8:Z8   cdim=1
set=IPPPlant rng=Set_Plant!D9:K9    cdim=1
set=SnSSDJPS  rng=Set_Plant!D10:I10  cdim=1
set=GTJPS     rng=Set_Plant!D11:J11  cdim=1
set=CCJPS     rng=Set_Plant!D12      cdim=1
Set=HydroJPS   rng=Set_Plant!D13:K13  cdim=1


set=Tline   rng=Set_Tline!D2:AR2   cdim=1
set=ETLine  rng=Set_Tline!D4:V4    cdim=1
set=CTLine  rng=Set_Tline!D5:Y5    cdim=1

set=Tec     rng=Set_tec!D2:J2     cdim=1
set=Thermal rng=Set_tec!D4:F4     cdim=1
set=RETec   rng=Set_tec!D5:G5     cdim=1
set=RETecnb  rng=Set_tec!D6:F6    cdim=1
set=Biomass  rng=Set_tec!D7       cdim=1
set=nhre     rng=Set_tec!D8:E8    cdim=1
set=hyth     rng=Set_tec!D9:G9    cdim=1

set=PlantType  rng=Set_PlantType!A3:B113  rdim=2
set=MapPlant   rng=Set_MapPlant!A3:B113   rdim=2
set=MapTline   rng=Set_MapTline!A3:C44   rdim=3

set=TlineHeadings  rng=Par_Tlinedata!B3:J3  cdim=1
set=PlantHeadings  rng=Par_PlantData!C3:AA3  cdim=1
set=ScalarHeadings  rng=par_Scalar!B3:B15     rdim=1
set=CalHeadings     rng=par_CalData!B3:B9    rdim=1


par=TLineData rng=Par_TLineData!A3:J45   cdim=1 rdim=1
par=PlantData rng=Par_PlantData!A3:AA114  cdim=1 rdim=2
par=AvailabilityFactor rng=Par_AvailabilityFactor!A3:G60 cdim=1 rdim=2
par=Rainfall  rng=Par_AvgRain!A2:B5   rdim=1
par=FuelPriceBaseline rng=Par_FuelPriceBaseline!A4:D28   cdim=1 rdim=1
par=FuelPriceLow   rng = Par_FuelPriceLow!A4:D28   cdim = 1   rdim =1
par=FuelPriceHigh   rng = Par_FuelPriceHigh!A4:D28   cdim = 1   rdim =1
par=Demand    rng=par_demand!A2:I1922   cdim=1 rdim=4
par=Peakdem  rng=Peak_demand_MW!A2:E26  cdim=1 rdim=1
par=ScalarParams  rng=par_Scalar!B3:C13    rdim=1
par=CalData   rng=par_CalData!B3:C15      rdim=1
$offecho


$CALL GDXXRW Input_GTEPJA_Anonymized.xlsx @gtepinput.txt
$GDXIN Input_GTEPJA_Anonymized.gdx
$LOADDC dow,hr,dtype,htype,quart,ayear,wk,byear,atqwk,attday,atth
$LOADDC node,slackbus,Plant,EPlant,DecomPlant, CPlant, MustBuildPlant, JPSPlant,IPPplant,SnSSDJPS,GTJPS,CCJPS,HydroJPS
$LOADDC Tline,ETline,CTLine
$LOAD tec,thermal,retec,retecnb,biomass,nhre,hyth
$LOAD PlantType,MapPlant,MapTline
$LOAD TlineHeadings, PlantHeadings, ScalarHeadings,Calheadings
$LOAD Tlinedata,PlantData,AvailabilityFactor,Rainfall,FuelPriceBaseline,FuelPriceLow,FuelPriceHigh,Demand,Peakdem,ScalarParams,CalData
$GDXIN

$ontext
display dow,hr,dtype,htype,quart,year,wk,byear,atqwk,attday,atth  ;
display node,slackbus,Plant,EPlant,DecomPlant, CPlant, MustBuildPlant,JPSPlant,IPPplant,SnSSDJPS,GTJPS,CCJPS,HydroJPS ;
display Tline,ETline,CTLine;
display tec,thermal,retec,retecnb,biomass;
display planttype,mapplant,maptline;
display TlineHeadings, PlantHeadings, ScalarHeadings,CalHeadings;
display Tlinedata,PlantData,AvailabilityFactor,FuelPrice,Demand,Peakdem,ScalarParams,CalData;
$offtext

Set year(ayear) ; year(ayear) = yes$(trunc((ord(ayear)+1)/2)*2 eq ord(ayear)+1) ;
Parameter cumymap(ayear,y) Years preceding y ;
cumymap(ayear,y)$(year(ayear) and year(y)) = 1$(ord(ayear) le ord(y)) ;
Display year,cumymap ;


$Ontext
*============================================================================
*Unfreeze this section only when Doubling Demand to constrain transmission
*=============================================================================
Demand(node,ayear,quart,dtype,htype)$(ord(ayear) ge 3) = 2*Demand(node,ayear,quart,dtype,htype);
PeakDem(ayear,quart)$(ord(ayear) ge 3) = 2*PeakDem(ayear,quart);
$Offtext


*=================================================================
*Creating Parameters from imported parameter tables
*=================================================================
Parameters
  TLineDistance(Tline)  Length of transmission lines in km
 Susceptance(TLine)    Susceptance of transmission line in p.u. on 100 MVA
 Reactance(Tline)      Reactance of transmission line in p.u. on 100 MVA
 PFmax(TLine)          Capacity of transmission line (MVA=MW)
 OCCtl(TLine)          Overnight Capital Cost of Transmission Line ($ millions)
 OCCannualTline(Tline) Annualized Capital OCst of Tlines
 crftl(Tline)          Capital recovery Factor for transmission lines


 GrossCap(Plant,tec)   Gross Capacity of plant
 ACapF(Eplant,retecnb) Actual or reported Capacity factors
 MinOpCap(plant,tec)   Minimum Operating capacity
 FOrate(Plant,tec)     Forced outage rate
 UFOrate(Plant,tec)    Unforced outage rate
 Hrate(plant,tec)      Heat rate in mmBtu
 FOM(ayear,plant,tec)   Fixed O&M Cost in $ per year
 VOM(plant,tec)        Variable O&M COst in $ per MWh
 OCCg(plant,tec)       Overnight Capital Cost (OCC) of Plant ($ millions)
 OCCannualP(plant,tec) Annualized OCC of plants ($ millions)
 crfg(plant,tec)       Capital Recovery Factor
 COD(plant,tec)        Commercial operating date of plant
 DecomDate(plant,tec)  Decommission date of plant
 NEO(plant,tec)        Net energy output of plant (in GWh)

 InvBudget(ayear)      Annual investment budget ($ millions)
 AnPeakDem(ayear)      Annual Peak Demand (MW)
;


TLineDistance(Tline) = Tlinedata(tline,"distance");
Susceptance(TLine)= Tlinedata(tline,"b");
Reactance(Tline) = Tlinedata(tline,"x");
PFmax(TLine) = TlineData(tline,"PFmax");
OCCtl(TLine) = TlineData(tline,"occtl");
OCCannualTLine(TLine)= TlineData(tline,"Tlineinvcost_yr");
crftl(tline) = TLineData(TLine,"crftl");

GrossCap(Plant,tec)= PlantData(plant,tec,"GrossCap");
ACapF(Eplant,retecnb) = PlantData(eplant,retecnb,"CapF");
MinOpCap(plant,tec) = PlantData(plant,tec,"MinOpCap");
FOrate(Plant,tec) = PlantData(plant,tec,"FOrate");
UFOrate(Plant,tec)= PlantData(plant,tec,"UFOrate");
Hrate(plant,tec) = PlantData(plant,tec,"hrate");
FOM(year,plant,tec) = PlantData(plant,tec,"FOM");
VOM(plant,tec) = PlantData(plant,tec,"VOM");
OCCg(plant,tec) = PlantData(plant,tec,"occg");
OCCannualP(plant,tec) = PlantData(plant,tec,"occ_annual");
crfg(plant,tec) = PlantData(plant,tec,"crfg");
COD(plant,tec) = PlantData(plant,tec,"COD");
DecomDate(plant,tec) = PlantData(plant,tec,"DecomDate");
NEO(plant,tec) = PlantData(plant,tec,"NEO");
AnPeakDem(year) = Smax(quart,Peakdem(year,quart));


Parameters UFOrateD(Plant,thermal,htype) Disaggregated Unforced Outage Rate;
*Here I assume that no unforced outtage will happen during peak hours
UFOrateD(Plant,thermal,htype)$PlantType(Plant,thermal) = UFOrate(plant,thermal);
UFOrateD(Plant,thermal,'peakh')$PlantType(Plant,thermal) = 0;
display uforated;


Scalars
 disc     Discount rate
 DumpCost Cost ($ per MWh) to dump energy
 UECost   Cost of unserved energy ($ per MWh)
 M        Big M used in model
 UMRCost  Cost of userved reserve capacity ($ per MW)
 ResMarg  Reserve Margin
 pi       assigning pi to 10 dp
 million 1 million
 pubase   Base for per unit conversions
 AvgRainfall Average quarterly rainfall
 RETarget  Renewable Energy Target
* ESVOM   Energy Storage variable O&MM Cost ($ per MWh)
* ESFOM   Energy Storage fixed O&MM Cost ($ per MW-yr)
* ESOCC   Overnight Capital Cost of Energy Storage system ($ millions per MW)
;

disc =ScalarParams("disc");
DumpCost = ScalarParams("DumpCost");
UECost = ScalarParams("UECost");
M = ScalarParams("M");
UMRCost = ScalarParams("UMRCost");
ResMarg = ScalarParams("ResMarg");
pi = ScalarParams("pi");
million = 1E6;
pubase = ScalarParams("pubase");
AvgRainfall = sum(quart,Rainfall(quart))/card(quart);
RETarget = 0.3;
*ESVOM = ScalarParams("ESVOM");
*ESFOM = ScalarParams("ESFOM");
*ESOCC = ScalarParams("ESOCC");
*Display grosscap,forate,uforate,disc,million,resmarg,AnPeakDem,pubase;
display AvgRainfall;

*======================================================================
*Creating Other Paramters Based on input tables
*======================================================================
Parameters
 AvailableEPlant(year,EPlant,tec) 1 if Existing plant is available in year 0 otherwise
 discf(year) Discount Factor
 Mday(dtype) Number of days per day type in a year
 Mquart(quart) Proportion of year in a quarter
 mth(htype)   Number of hours by hour type
 Bij(tline) Inverse of reactance used in power flow constraints
 FuelPrice(year,thermal) Fuel Price in (2017$ per mmBtu) for use in each scenario
 RainfallDev(quart)    Deviation from average rainfall
 AdjAvailFact1(plant,tec,quart,htype) Adjusted Availability factors (first step of calculation)
 AdjAvailFact2(plant,tec,quart,htype) Adjusted Availability factors (2nd step of calculation)
;

AvailableEPlant(year,EPlant,tec) = 1$PlantType(Eplant,tec);
display availableEplant;
AvailableEPlant(year,decomplant,tec)$((ord(year)+2017) gt DecomDate(DecomPlant,tec) and PlantType(decomplant,tec))=0;

discf(year) = 1/((1+disc)**(ord(year)-1));

Mquart(quart)=sum(wk$atqwk(quart,wk),1)/card(wk);
Mth(htype) = sum(hr$atth(htype,hr),1);
Mday(dtype)= 365*sum(dow$attday(dtype,dow),1)/card(dow);

Bij(tline) = 1/Reactance(tline);

*----------------------------------------------------
*Adjusting Hydro availability factors for seasonality
*----------------------------------------------------
RainfallDev(quart) = (rainfall(quart)-Avgrainfall)/AvgRainfall;
Display RainfallDev, AvailabilityFactor;

AdjAvailFact1(plant,tec,quart,htype)$PlantType(Plant,tec) = AvailabilityFactor(plant,tec,htype);

AdjAvailFact1(plant,'hydro',quart,htype)$PlantType(Plant,'hydro') = (1+RainfallDev(quart))*AvailabilityFactor(plant,'hydro',htype);
AdjAvailFact2(plant,tec,quart,htype)$PlantType(Plant,Tec) = AdjAvailFact1(plant,tec,quart,htype) ;
*Adjusting for hydro plants with capacity factors above 0.74
*IF(ord(quart) LE 3,
*    AdjAvailFact2(plant,'hydro',quart,hytpe)=AdjAvailFact1(plant,'hydro',quart,hytpe)+(AdjAvailFact1(plant,'hydro','Q4',hytpe)-1)/3;
*ELSE
*    AdjAvailFact2(plant,'hydro',quart,hytpe) = 1;
*);

AdjAvailFact2(plant,'hydro',quart,htype)$(ord(quart) LE 3 and PlantType(Plant,'hydro')) = AdjAvailFact1(plant,'hydro',quart,htype)+((AdjAvailFact1(plant,'hydro','Q4',htype)-1)/3)$(AdjAvailFact1(plant,'hydro','q4',htype) GT 1);
AdjAvailFact2(plant,'hydro','q4',htype)$(PlantType(Plant,'hydro') and AdjAvailFact2(plant,'hydro','q4',htype) GT 1) = 1;
Display AdjAvailFact1,AdjAvailFact2;

$ontext
*=================================
*Setting Investment Budget
*=================================
 InvBudget(year) = 100;
$offtext


*=================================
*Storage Parameters
*=================================
*Here I create parameters for storing bases for comparing models
Parameters
 STotCost(ModelType) Storage parameter for NPV over planning horizon (USD mil)
 TotCostY(year,ModelType) Annual Total Cost in USD Million (operations and investments)
 OpCost(year,ModelType) Operating Cost USD Millions (Fixed & Variable)
 SBuildPlant(year,CPlant,tec,ModelType) Storage parameter for built plant variable
 SBuildTline(year,ctline,ModelType) Storage parameter for built transmission line variable
 SInvCostPlant(year,ModelType) Storage parameter for investment cost in generators USD Millions
 SInvCostTLine(year,ModelType) Storage parameter for investment cost in transmission lines USD millions
 Annual_Generation(year,ModelType) Annual Generation (GWh)
 LCOE(year,ModelType) Levelized Cost of energy (US cents per kWh)
 GenPortfolio(year,tec,ModelType) Annual generation (GWh) by technology
 GenPortfolioShare(year,tec,ModelType) Share of output by techology (in %)
 Capfactor(plant,tec,year,ModelType) Capacity Factor
;


*=========================================
*Global Variables & Definition
*=========================================
Variable TotCost Net Present Value (USD Millions) of Operation and Investment Costs (Objective);

Variables
 theta(Tline,node,ayear,quart,dtype,htype) Bus voltage angles (rad)
 PowerFlow(tline,node,n,ayear,quart,dtype,htype) Power flow across transmission line in MW;


Positive Variables
 U(ayear,CTline) Slack variable in application of big M method
 UE(ayear,quart,dtype,htype,node) Average Unserved energy in MW
 DumpEn(ayear,quart,dtype,htype,node) Average Dumped Enegy MW
 PGG(ayear,quart,dtype,htype,plant,tec) Power generation in MW
 UMR(ayear)  Unmet Reserves (MW) each year
 FixedCost(ayear) Annual Total Fixed O&M Costs (USD)
 InvCostPlant(ayear) NPV Total Investment Cost (USD Million)  for generation each year
 InvCostTline(ayear) NPV Total Investment Cost (USD Million)  for transmission each year
 BuildRE(ayear,CPlant,tec) Number of MW of plant built (used for Solar and Wind only)
;


Binary Variables
 BuildPlant(ayear,CPlant,tec) 1 if candidate plant is build at node (will use for Fossil fuel and RoR Hydro only)
 BuildTline(ayear,CTline)       1 if candidate transmission line is built;


*=======================================================
* Model equations and Definition
*=======================================================
*Objective Function
*-------------------

Equation objdef Objective function definition;
objdef..TotCost =E= card(ayear)/card(year)*
 ((SUM(year,(
      (SUM((quart,dtype,htype),Mquart(quart)*Mday(dtype)*mth(htype)*(
*Fuel & Variable Costs for thermal plants
         SUM((plant,thermal)$PlantType(plant,thermal),PGG(year,quart,dtype,htype,plant,thermal)*
                 (hrate(plant,thermal)/1000*FuelPrice(year,thermal)+VOM(plant,thermal)))
*Variable Cost for Biomass plants should come here if data available

*Variable Cost for Renewable plants excluding biomass plants
          +SUM((plant,retecnb)$PlantType(plant,retecnb),PGG(year,quart,dtype,htype,plant,retecnb)*VOM(plant,retecnb))

*Unserved energy and dump costs
          + SUM(node,UECost*UE(year,quart,dtype,htype,node))
*           + DumpCost*DumpEn(year,quart,dtype,htype,node)
                          ))
      +FixedCost(year)
*     + UMR(year)*UMRCost
 )*discf(year))
*Converting to millions of dollars
 ))/million
*Adding Investment Costs
 + SUM(year,InvCostPlant(year)) + SUM(year,InvCostTline(year)));



*-----------------------------------
*Fixed & Investment Cost Equations
*-----------------------------------
Equations
 FCostdef     Fixed O&M Cost equation definition
 InvCostPdef  Investment cost equation definition for plants
 InvCostTLdef Investment Cost equation definition for transmission lines;

FCostdef(year)..FixedCost(year) =E= SUM((EPlant,tec)$PlantType(Eplant,Tec),FOM(year,EPlant,tec)*AvailableEPlant(year,EPlant,tec))
*BuildPlant variable will be set to be applicable to only fossil fuel and hydro resources
                                 + SUM((Cplant,hyth)$PlantType(Cplant,hyth),FOM(year,CPlant,hyth)*SUM(y$(year(y) and cumymap(y,year) eq 1),
                                       BuildPlant(y,cplant,hyth)))
*Non-hydro renewable energy fixed costs
                                 + SUM((CPlant,nhre)$PlantType(Cplant,nhre),FOM(year,Cplant,nhre)*SUM(y$(year(y) and cumymap(y,year) eq 1),
                                       BuildRE(y,CPlant,nhre)));

*$ontext
InvCostPdef(year)..InvCostPlant(year) =E= (
                                         SUM((Cplant,hyth)$PlantType(CPlant,hyth),OCCg(CPlant,hyth)*SUM(y$(year(y) and cumymap(y,year) eq 1),
                                            BuildPlant(y,CPlant,hyth))*crfg(Cplant,hyth))
                                         +SUM((CPlant,nhre)$PlantType(CPlant,nhre),OCCg(CPlant,nhre)*SUM(y$(year(y) and cumymap(y,year) eq 1),
                                            BuildRE(y,CPlant,nhre))*crfg(Cplant,nhre))
                                           )*discf(year);

InvCostTLdef(year)..InvCostTline(year)=E= SUM(ctline,OCCtl(ctline)*SUM(y$(year(y) and cumymap(y,year) eq 1),BuildTline(y,ctline))*crftl(ctline))
                                         *discf(year);


$ontext
*-----------------------------------
*Investment budget Constraint
*-----------------------------------
Equation budget Annual Investment Budget Constraint;
budget(year)..InvCostPlant(year)+ InvCostTline(year) =L= InvBudget(year);
$offtext

*--------------------------------------
*Constraints on building infrastructure
*--------------------------------------
*$ontext
Equations
 POnce  Candidate plant (thermal and hydro) can only be built once
 TLOnce Candidate transmission line can only be built once
* PlannedPlant Planned construction of plants
;


POnce(Cplant,hyth)$PlantType(CPlant,hyth)..SUM(year,BuildPlant(year,CPlant,hyth)) =L=1;
TLOnce(ctline)..SUM(year,BuildTline(year,ctline)) =L=1;

*Plant that must be built
BuildPlant.fx(ayear,MustBuildPlant,hyth)$(ord(ayear)+2016 eq COD(MustBuildPlant,hyth)) =1;
BuildPlant.fx(ayear+1,MustBuildPlant,hyth)$(ord(ayear)+2016 eq COD(MustBuildPlant,hyth)) =1;

*I assume that no plants, transmission lines or battery energy storage  will be built before 2019
BuildPlant.fx(ayear,Cplant,tec)$(ord(ayear) lt 3)=0;
BuildRE.fx(ayear,Cplant,tec)$(ord(ayear) lt 3)=0;
Buildtline.fx(ayear,ctline)$(ord(ayear) lt 3)=0;


*BuildPlant variable not applicable to nhre units
BuildPlant.fx(ayear,Cplant,nhre)=0;

*BuildRE variable not applicable to hydro or thermal units
BuildRE.fx(ayear,Cplant,hyth)=0;

*Ensuring that 37 MW solar plant already scheduled to build will be built
BuildRE.fx(ayear,"NewSolar","solar")$(ord(ayear)+2016 eq COD("NewSolar","solar")) = 37;
BuildRE.fx(ayear+1,"NewSolar","solar")$(ord(ayear)+2016 eq COD("NewSolar","solar")) = 37;



*=============================================================
*Generation Capacity Constraints
*=============================================================
Equations
 CThermalGen Constraint on candidate thermal generation
 HydroGen    Constraint on candidate Hydro generation
 nhreGen     Constraint on candidate wind and solar generation
 maxnhre     Max MW build for each wind and solar plant
;

*---------------
*Thermal Plants
*---------------
*Setting Upper bound on existing thermal generation
PGG.up(year,quart,dtype,htype,Eplant,thermal)$PlantType(EPlant,thermal)=
            AvailableEPlant(year,EPlant,thermal)*GrossCap(EPlant,thermal)
           *(1-FOrate(EPlant,thermal))*(1-UFOrated(EPlant,thermal,htype));


*Setting Upper bound on candidate thermal generation
CThermalGen(year,quart,dtype,htype,Cplant,thermal)$PlantType(CPlant,thermal)..
         PGG(year,quart,dtype,htype,Cplant,thermal)=L=
         SUM(y$(year(y) and cumymap(y,year) eq 1),BuildPlant(y,cplant,thermal))
         *GrossCap(CPlant,thermal)*(1-FOrate(CPlant,thermal))
            *(1-UFOrated(CPlant,thermal,htype));



*------------------------------
*Renewable Energy Constraints
*------------------------------
*Upper limit on existing RE resources
PGG.up(year,quart,dtype,htype,Eplant,retecnb)$PlantType(EPlant,retecnb)=
          AvailableEPlant(year,EPlant,retecnb)*GrossCap(EPlant,retecnb)
          *AdjAvailFact2(EPlant,retecnb,quart,htype);

*Upper limit on candidate hydro resources
HydroGen(year,quart,dtype,htype,Cplant,'hydro')$PlantType(CPlant,'hydro')..
          PGG(year,quart,dtype,htype,Cplant,'hydro') =L=
         SUM(y$(year(y) and cumymap(y,year) eq 1),BuildPlant(y,Cplant,'hydro'))*GrossCap(CPlant,'hydro')
          *AdjAvailFact2(CPlant,'hydro',quart,htype);


**Upper limit on candidate wind and solar resources
nhreGen(year,quart,dtype,htype,CPlant,nhre)$PlantType(Cplant,nhre)..
         PGG(year,quart,dtype,htype,CPlant,nhre) =L=
               SUM(y$(year(y) and cumymap(y,year) eq 1),BuildRE(y,Cplant,nhre))
                         *AdjAvailFact2(CPlant,nhre,quart,htype);

*Upper limit on number of MW (solar and wind) for each candidate plant
maxnhre(CPlant,nhre)$PlantType(CPlant,nhre).. SUM(year,BuildRE(year,CPlant,nhre)) =L= 350;



*$Ontext
*------------------------------
*Reserve Margin Constraint
*------------------------------
*Setting Availability Factor for thermal plants to 1
AvailabilityFactor(plant,thermal,htype)$PlantType(Plant,thermal) = 1;
AdjAvailFact2(plant,thermal,quart,htype)$PlantType(Plant,thermal) = 1;
*display AvailabilityFactor,AdjAvailFact2;


Equation ResMargDef Reserve Margin Constraint;
ResMargDef(year,quart)..SUM((EPlant,tec)$PlantType(EPlant,tec),GrossCap(EPlant,tec)*AvailableEPlant(year,EPlant,tec)* AdjAvailFact2(Eplant,tec,quart,'peakh'))
                         +SUM((Cplant,tec)$PlantType(CPlant,tec),
                           SUM(y$(year(y) and cumymap(y,year) eq 1),BuildPlant(y,Cplant,tec))*GrossCap(Cplant,tec)*AdjAvailFact2(Cplant,tec,quart,'peakh')
                                 + SUM(y$(year(y) and cumymap(y,year) eq 1),BuildRE(y,Cplant,tec))*GrossCap(Cplant,tec)*AdjAvailFact2(Cplant,tec,quart,'peakh'))
                           + UMR(year) =g= AnPeakdem(year)*(1+ResMarg);


*=====================================================
*Transmission Constraints
*=====================================================
*For Existing & Candidate Transmission Lines
*--------------------------------------------
Equation
 PFLimitCTLine1 Capacity constraint on power flow across candidate lines
 PFLimitCTLine2 Capacity constraint on power flow across candidate lines

;

PowerFlow.up(ETline,node,n,year,quart,dtype,htype)$MapTline(ETline,node,n)=
                 PFmax(ETline)/pubase;

PowerFlow.lo(ETline,node,n,year,quart,dtype,htype)$MapTline(ETline,node,n)=
                 -PFmax(ETline)/pubase;

PFLimitCTLine1(CTline,node,n,year,quart,dtype,htype)$MapTline(CTline,node,n)..
         PowerFlow(CTline,node,n,year,quart,dtype,htype) =L=
                 SUM(y$(year(y) and cumymap(y,year) eq 1),BuildTline(y,ctline))*PFmax(CTline)/pubase;


PFLimitCTLine2(CTline,node,n,year,quart,dtype,htype)$MapTline(CTline,node,n)..
         PowerFlow(CTline,node,n,year,quart,dtype,htype) =g=
                 -SUM(y$(year(y) and cumymap(y,year) eq 1),BuildTline(y,ctline))*PFmax(CTline)/pubase;



*---------------------------------------
*Implementing Kirchhoff's Voltage Laws
*---------------------------------------
Equations
 KVL1 Constraining power flow on existing line by susceptance and volatage angles
 KVL2 Constraining power flow on Candidate line by susceptance and volatage angles
 KVL3 Constraining power flow on Candidate line by susceptance and volatage angles
 VAdef1 Constraint on bus voltage angle
 VAdef2 Constraint on bus voltage angle;


*Using Inverse reactance
KVL1(ETline,node,n,year,quart,dtype,htype)$MapTline(ETline,node,n)..
   PowerFlow(ETline,node,n,year,quart,dtype,htype)=E=
      Bij(ETline)*(
         theta(ETline,node,year,quart,dtype,htype)-theta(ETline,n,year,quart,dtype,htype));


KVL2(CTline,node,n,year,quart,dtype,htype)$MapTline(CTline,node,n)..
   PowerFlow(CTline,node,n,year,quart,dtype,htype) =E= Bij(CTline)*(
         theta(CTline,node,year,quart,dtype,htype)-theta(CTline,n,year,quart,dtype,htype))
         + (SUM(y$(year(y) and cumymap(y,year) eq 1),BuildTline(y,ctline))-1)*M + U(year,CTLine);


KVL3(year,ctline).. U(year,CTLine) =L=2*(1-SUM(y$(year(y) and cumymap(y,year) eq 1),BuildTline(y,ctline)))*M;
VAdef1(TLine,node,year,quart,dtype,htype)..theta(TLine,node,year,quart,dtype,htype)=L=pi ;
VAdef2(TLine,node,year,quart,dtype,htype)..theta(TLine,node,year,quart,dtype,htype)=g=-pi ;


*===============================================
* Power Balance Equations
*===============================================
Equation PowerBalance Demand must match supply;

PowerBalance(year,quart,dtype,htype,node)..
         SUM((plant,tec)$(MapPlant(node,Plant) and PlantType(Plant,tec)),PGG(year,quart,dtype,htype,plant,tec)/pubase)
         + SUM((n,tline),
                 PowerFlow(tline,n,node,year,quart,dtype,htype)$MapTline(tline,n,node)
                 -PowerFlow(tline,node,n,year,quart,dtype,htype)$MapTline(tline,node,n))
          +UE(year,quart,dtype,htype,node)/pubase=E= Demand(node,year,quart,dtype,htype)/pubase;




*===============================================
* Renewable Portfolio Standard
*===============================================
Parameter TotalDemand(ayear) Total Demand MWh;
TotalDemand(year) = SUM((quart,dtype,htype,node),Mquart(quart)*Mday(dtype)*mth(htype)*Demand(node,year,quart,dtype,htype));
*display TotalDemand;
Set RPSPer(ayear) RPS enforcement periods ;
RPSPer(ayear) = Yes$(year(ayear) and ord(ayear)+2016 ge 2030) ;
Display RPSPer ;

Equation RPS_cons constraint defining renewable portfolio standard;
RPS_cons(year)$RPSPer(year)..SUM((quart,dtype,htype,plant,retecnb)$PlantType(Plant,retecnb),
         Mquart(quart)*Mday(dtype)*mth(htype)*PGG(year,quart,dtype,htype,plant,retecnb)) =g=RETarget*TotalDemand(year);


*==========================================
* Idiosyncratic & Other Constraints
*==========================================
theta.fx(Tline,slackbus,year,quart,dtype,htype) = 0;

* I temporarily exclude biomass
PGG.fx(year,quart,dtype,htype,plant,biomass) =0;

*Since GT11 was down in 2017 (OUR data) but will be brought back online afterwards (OUR annual report 2017-2018)
PGG.fx(byear,quart,dtype,htype,"Bogue_GT11","NG")=0;


*Fixing unmet energy to zero until pending improved measure of unmet energy costs.
*Cost of generator for unmet energy cost may not be sufficient
UE.fx(year,quart,dtype,htype,node)=0;


*Setting Unmet reserve to zero
UMR.fx(year) = 0;

*Ensuring no dumped energy
DumpEn.fx(year,quart,dtype,htype,node) =0;


*=================================================================================

*==============================================
* FUEL PRICE SCENARIO
*==============================================
************************************************************************
*Just below, you can select a given fuel price scenario by
*commenting out the ones not needed. Here, I run the baseline fuel
*price scenario.
************************************************************************

FuelPrice(year,thermal) = FuelPriceBaseline(year,thermal);
*FuelPrice(year,thermal) = FuelPriceHigh(year,thermal);
*FuelPrice(year,thermal) = FuelPriceLow(year,thermal);

*$ONTEXT
*===============================================
* SIMULTANEOUS MODEL WITH LOOP FLOW
*===============================================
*****************************************************************
*In this section, I run the simultaneous model with loop flow
*and save the output to excel files.
*****************************************************************


*$ONTEXT
Model GTEPJA_simKVL /
objdef,
FCostdef,InvCostPdef,InvCostTLdef,
*budget,
POnce,TLOnce,
CThermalGen,
HydroGen,ResMargDef,
PFLimitCTLine1, PFLimitCTLine2,
KVL1, KVL2, KVL3, VAdef1, VAdef2,
RPS_cons,
nhreGen, maxnhre,
PowerBalance
/;
option limcol=0;
option limrow=0;
Option MIP = Cplex;
$onecho > cplex.opt
epint 0
nodefileind 3
$offecho
*$ONTEXT
GTEPJA_simKVL.optfile=1 ;
GTEPJA_simKVL.resLim=60480000;
Solve GTEPJA_simKVL using MIP minimizing totcost;
*$OFFTEXT



*--------------------------------------------------------
*Storing simultaneous KVL outputs in storage parameters
*---------------------------------------------------------
STotCost('sim_KVL') = TotCost.l;
SBuildPlant(year,cplant,hyth,'sim_KVL')=BuildPlant.l(year,CPlant,hyth);
SBuildPlant(year,cplant,nhre,'sim_KVL')=BuildRE.l(year,CPlant,nhre);

SBuildTline(year,ctline,'sim_KVL')=BuildTline.l(year,CTline);

TotCostY(year,'sim_KVL')= (SUM((quart,dtype,htype),Mquart(quart)*Mday(dtype)*mth(htype)*(
*Fuel & Variable Costs for thermal plants
         SUM((plant,thermal),PGG.l(year,quart,dtype,htype,plant,thermal)*
                 (hrate(plant,thermal)/1000*FuelPrice(year,thermal)+VOM(plant,thermal)))
*Variable Cost for Biomass plants should come here if data available

*Variable Cost for Renewable plants excluding biomass plants
          +SUM((plant,retecnb),PGG.l(year,quart,dtype,htype,plant,retecnb)*VOM(plant,retecnb))

*Unserved energy and dump costs
          + SUM(node,UECost*UE.l(year,quart,dtype,htype,node))
*           + DumpCost*DumpEn(year,quart,dtype,htype,node)
                          ))
      +FixedCost.l(year)
*     + UMR(year)*UMRCost
 )*discf(year)
*Converting to millions of dollars
 /million
*Adding Investment Costs
 + InvCostPlant.l(year) + InvCostTline.l(year);



***************************************************

OpCost(year,'sim_KVL') = (SUM((quart,dtype,htype),Mquart(quart)*Mday(dtype)*mth(htype)*(
*Fuel & Variable Costs for thermal plants
         SUM((plant,thermal),PGG.l(year,quart,dtype,htype,plant,thermal)*
                 (hrate(plant,thermal)/1000*FuelPrice(year,thermal)+VOM(plant,thermal)))
*Variable Cost for Biomass plants should come here

*Variable Cost for Renewble plants excluding biomass plants
          +SUM((plant,retecnb),PGG.l(year,quart,dtype,htype,plant,retecnb)*VOM(plant,retecnb))

*Unserved energy and dump costs
          + SUM(node,UECost*UE.l(year,quart,dtype,htype,node))
*           + DumpCost*DumpEn(year,quart,dtype,htype,node)
                          ))
      +FixedCost.l(year)
*     + UMR(year)*UMRCost
 )*discf(year)
*Converting to millions of dollars
 /million;

 SInvCostPlant(year,'sim_KVL') = InvCostPlant.l(year);

 SInvCostTLine(year,'sim_KVL') = InvCostTline.l(year);

 Annual_Generation(year,'sim_KVL') = SUM((quart,dtype,htype,plant,tec),Mquart(quart)*Mday(dtype)*mth(htype)*
         PGG.l(year,quart,dtype,htype,plant,tec))/1000;

 LCOE(year,'sim_KVL')= (100*million*TotCostY(year,'sim_KVL'))/(million*Annual_Generation (year,'sim_KVL'));

 GenPortfolio(year,tec,'sim_KVL') = SUM((quart,dtype,htype,plant),Mquart(quart)*Mday(dtype)*mth(htype)*
         PGG.l(year,quart,dtype,htype,plant,tec))/1000;

 GenPortfolioShare(year,tec,'sim_KVL')=100* GenPortfolio(year,tec,'sim_KVL')/Annual_Generation(year,'sim_KVL');

*Display STotCost,TotCostY,OpCost, Annual_Generation,LCOE,GenPortfolio, GenPortfolioShare;


Capfactor(plant,tec,year,'sim_KVL')$PlantType(Plant,tec)= SUM((quart,dtype,htype),Mquart(quart)*Mday(dtype)*mth(htype)*
                            PGG.l(year,quart,dtype,htype,plant,tec))/
                           SUM((quart,dtype,htype),Mquart(quart)*Mday(dtype)*mth(htype)*
                             GrossCap(Plant,tec));
*display CapFactor;

Parameter CapFactor2017(plant,retecnb,ModelType) Capacity factor for 2017;

CapFactor2017(plant,retecnb,'sim_KVL')$PlantType(Plant,retecnb) = Capfactor(plant,retecnb,'2017','sim_KVL');

********************************************************************************************************************
*$OFFTEXT


*$ONTEXT
*==================
*Calibrating Model
*==================
*In this section, I compare model results with known information for 2017.
*Data for comparison are obtained from sources such JPSCo's annual report (2017),
*OUR annual report (2017-2018) and data collected directly from the OUR in initial visit.


*COMPARING OPERATING COST
*------------------------
Parameters OpCostX(*)   Examining 2017 operating Costs from Model;

OpCostX('Model (USD mil)') = OpCost('2017','sim_KVL');
OpCostX('Reported (USD mil)') = CalData('CostOfSales');
OpCostX('Ratio') = OpCostX('Model (USD mil)')/OpCostX('Reported (USD mil)');
OpCostX('Difference') = OpCostX('Model (USD mil)')-OpCostX('Reported (USD mil)');
OpCostX('Difference (%)') = 100*OpCostX('Difference')/OpCostX('Reported (USD mil)');
Display OpCostX;

*Noting Multiplicative factor for average computation
Parameter  Factor(quart,dtype,htype);
factor(quart,dtype,htype) = Mquart(quart)*Mday(dtype)*mth(htype);
display factor;


*EXAMINING POWERFLOW
*--------------------

Parameter PowerFlowShare(tline,node,n,year,quart,dtype,htype) Share of power flow to capacity in percent;
PowerFlowShare(tline,node,n,year,quart,dtype,htype)=((pubase*powerflow.l(tline,node,n,year,quart,dtype,htype))/PFmax(tline))*100;
display powerflowshare;

Scalars
maxpf Max power flow
minpf Min power flow
maxpfshare max powerflowshare
minpfshare min powerflow share;

maxpf = smax((tline,node,n,year,quart,dtype,htype),powerflow.l(tline,node,n,year,quart,dtype,htype));
minpf = smin((tline,node,n,year,quart,dtype,htype),powerflow.l(tline,node,n,year,quart,dtype,htype));
maxpfshare = smax((tline,node,n,year,quart,dtype,htype),PowerFlowShare(tline,node,n,year,quart,dtype,htype));
minpfshare = smin((tline,node,n,year,quart,dtype,htype),PowerFlowShare(tline,node,n,year,quart,dtype,htype));

*Display maxpf, minpf, maxpfshare,minpfshare;

*EXAMINING SUPPLY
*------------------
Parameters
GWh17(plant,tec) Total generation (GWh) by each plant in 2017
TotGen(*)     Comparing Total generation
GSnSSD(*)  Comparing generation from JPSCo steam and slow speed diesel plants
GHydro(*)  Comparing generation from JPSCo hydro plants
GGT(*)     Comparing generation from JPSCo gas turbine plants
GCC(*)     Comparing generation from JPSCo combined cycle plant
CapFactorDiff(Eplant,retecnb) difference between simulated and actural capacity factors
;

CapFactorDiff(Eplant,retecnb) = CapFactor(Eplant,retecnb,'2017','sim_KVL')-ACapF(Eplant,retecnb);
display capfactordiff;

GWh17(plant,tec) = SUM((quart,dtype,htype),Mquart(quart)*Mday(dtype)*mth(htype)*
         PGG.l('2017',quart,dtype,htype,plant,tec))/1000;

TotGen("Model (GWh)") = sum((plant,tec),GWh17(plant,tec));
TotGen("Reported (GWh)") = CalData("NetGen")/1000;
TotGen("Ratio")  = TotGen("Model (GWh)")/TotGen("Reported (GWh)");
TotGen("Difference (GWh)") = TotGen("Model (GWh)")-TotGen("Reported (GWh)");
TotGen("Nominal_Error (%)") = 100*(TotGen("Model (GWh)")-TotGen("Reported (GWh)"))/TotGen("Reported (GWh)");

GSnSSD('Model (GWh)') = SUM((quart,dtype,htype,SnSSDJPS,tec),Mquart(quart)*Mday(dtype)*mth(htype)*
         PGG.l('2017',quart,dtype,htype,SnSSDJPS,tec))/1000;
GSnSSD('Reported (GWh)') = CalData('SnSSDGen')/1000;
GSnSSD('Difference (GWh)') = GSnSSD('Model (GWh)')-GSnSSD('Reported (GWh)');
GSnSSD('Nominal_Error (%)') = 100*GSnSSD('Difference (GWh)')/GSnSSD('Reported (GWh)');
GSnSSD('Model_Share (%)') = 100*GSnSSD('Model (GWh)')/TotGen("Model (GWh)");
GSnSSD('Reported_Share (%)')=100*GSnSSD('Reported (GWh)')/TotGen("Reported (GWh)");

GHydro('Model (GWh)') = SUM((quart,dtype,htype,HydroJPS,tec),Mquart(quart)*Mday(dtype)*mth(htype)*
         PGG.l('2017',quart,dtype,htype,HydroJPS,tec))/1000;
GHydro('Reported (GWh)') = CalData('HydroGen')/1000;
GHydro('Difference (GWh)') = GHydro('Model (GWh)')-GHydro('Reported (GWh)');
GHydro('Nominal_Error (%)') = 100*GHydro('Difference (GWh)')/GHydro('Reported (GWh)');
GHydro('Model_Share (%)') = 100*GHydro('Model (GWh)')/TotGen("Model (GWh)");
GHydro('Reported_Share (%)') = 100*GHydro('Reported (GWh)')/TotGen("Reported (GWh)");

GGT('Model (GWh)') = SUM((quart,dtype,htype,GTJPS,tec),Mquart(quart)*Mday(dtype)*mth(htype)*
         PGG.l('2017',quart,dtype,htype,GTJPS,tec))/1000;
GGT('Reported (GWh)') = CalData('GTGen')/1000;
GGT('Difference (GWh)') = GGT('Model (GWh)')-GGT('Reported (GWh)');
GGT('Nominal_Error (%)') = 100*GGT('Difference (GWh)')/GGT('Reported (GWh)');
GGT('Model_Share (%)') = 100*GGT('Model (GWh)')/TotGen("Model (GWh)");
GGT('Reported_Share (%)') = 100*GGT('Reported (GWh)')/TotGen("Reported (GWh)");

GCC('Model (GWh)') = SUM((quart,dtype,htype,CCJPS,tec),Mquart(quart)*Mday(dtype)*mth(htype)*
         PGG.l('2017',quart,dtype,htype,CCJPS,tec))/1000;
GCC('Reported (GWh)') = CalData('CCGen')/1000;
GCC('Difference (GWh)') = GCC('Model (GWh)')-GCC('Reported (GWh)');
GCC('Nominal_Error (%)') = 100*GCC('Difference (GWh)')/GCC('Reported (GWh)');
GCC('Model_Share(%)')=100*GCC('Model (GWh)')/TotGen("Model (GWh)");
GCC('Reported_Share(%)') =100* GCC('Reported (GWh)')/TotGen("Reported (GWh)");

*Display GWh17,TotGen,GSnSSD,GHydro,GGT,GCC;


*COMPARING RENEWABLE OUTPUT
*---------------------------
PARAMETER NEOX17(plant,retecnb,*) Examining Net Energy Output of renewable plants for 2017;
NEOX17(Eplant,retecnb,'Model (GWh)')$PlantType(EPlant,retecnb) = SUM((quart,dtype,htype),Mquart(quart)*Mday(dtype)*mth(htype)*
                                          PGG.l('2017',quart,dtype,htype,Eplant,retecnb))/1000;
NEOX17(Eplant,retecnb,'Reported (GWh)')$PlantType(EPlant,retecnb)= NEO(Eplant,retecnb);
NEOX17(Eplant,retecnb,'Difference (GWh)')$PlantType(EPlant,retecnb) = NEOX17(Eplant,retecnb,'Model (GWh)')-NEOX17(Eplant,retecnb,'Reported (GWh)');
NEOX17(Eplant,retecnb,'Error (%)')$PlantType(EPlant,retecnb) = 100*NEOX17(Eplant,retecnb,'Difference (GWh)')/NEOX17(Eplant,retecnb,'Reported (GWh)');
*Display NEOX17;



*JPSCo vs IPP Generation
*=======================
Parameter
JPSCoGen(*)   Comparing model results for JPSCo Generation
IPPGen(*)     Comparing results for combined IPP Generation
;

JPSCOgen("Model (GWh)") = SUM((quart,dtype,htype,JPSPlant,tec),Mquart(quart)*Mday(dtype)*mth(htype)*
                        PGG.l('2017',quart,dtype,htype,JPSPlant,tec))/1000;
JPSCOgen("Reported (GWh)") = (CalData('NetGen')-CalData('Purchases'))/1000;
JPSCOgen("Difference (GWh)") = JPSCOgen("Model (GWh)")-JPSCOgen("Reported (GWh)");
JPSCOgen("Nominal_Error (%)") = 100*JPSCOgen("Difference (GWh)")/JPSCOgen("Reported (GWh)");
JPSCOgen("Model_Share (%)") = 100*JPSCOgen("Model (GWh)")/TotGen("Model (GWh)");
JPSCOgen("Reported_Share (%)") = 100*JPSCOgen("Reported (GWh)")/TotGen("Reported (GWh)");

*$ONTEXT
IPPGen("Model (GWh)") = SUM((quart,dtype,htype,IPPPlant,tec),Mquart(quart)*Mday(dtype)*mth(htype)*
                        PGG.l('2017',quart,dtype,htype,IPPPlant,tec))/1000;
IPPGen("Reported (GWh)") = CalData('Purchases')/1000;
IPPGen("Difference (GWh)") = IPPGen("Model (GWh)")-IPPGen("Reported (GWh)");
IPPGen("Nominal_Error (%)") = 100*IPPGen("Difference (GWh)")/IPPGen("Reported (GWh)");
IPPGen("Model_Share (%)")=100*IPPGen("Model (GWh)")/TotGen("Model (GWh)");
IPPGen("Reported_Share (%)")=100*IPPGen("Reported (GWh)")/TotGen("Reported (GWh)");

*Display JPSCoGen, IPPGen;


*UNSERVED ENERGY
*--------------------
Parameter
UEGWh(year,node) Unserved Energy in GWh in model
UEshare(year) Unmet Energy as a share of total demand (in percent);

UEGWh(year,node) = SUM((quart,dtype,htype),Mquart(quart)*Mday(dtype)*mth(htype)*UE.l(year,quart,dtype,htype,node))/1000;

UEshare(year) = 100*SUM((node,quart,dtype,htype),Mquart(quart)*Mday(dtype)*mth(htype)*UE.l(year,quart,dtype,htype,node))/
                  SUM((n,q,hhtype,ddtype),Demand(n,year,q,ddtype,hhtype));

*Display UEGWh,UEshare;
*$OFFTEXT
*END OF CALIBRATION AND VALIDATION COMPUTATIONS



*-----------------------------------
*Output for model calibration
*-----------------------------------
*$ONTEXT
Execute_unload "Output_GTEPJA_all_CalibrationFullModel_BaselineFuelPrice.gdx"  opcostx,TotGen,GSnSSD,GHydro,GGT,GCC,NEOX17,JPSCoGen, IPPGen, capfactor, CapFactor2017, CapFactorDiff
Execute "gdxxrw.exe Output_GTEPJA_all_CalibrationFullModel_BaselineFuelPrice.gdx par=OpCostX rng=OpCostX!"
Execute "gdxxrw.exe Output_GTEPJA_all_CalibrationFullModel_BaselineFuelPrice.gdx Par=TotGen rng=CompareTotGen!"
Execute "gdxxrw.exe Output_GTEPJA_all_CalibrationFullModel_BaselineFuelPrice.gdx Par=GSnSSD rng=CompareSnSSD!"
Execute "gdxxrw.exe Output_GTEPJA_all_CalibrationFullModel_BaselineFuelPrice.gdx Par=GHydro rng=CompareJPSHydro!"
Execute "gdxxrw.exe Output_GTEPJA_all_CalibrationFullModel_BaselineFuelPrice.gdx Par=GGT rng=CompareJPSGGT!"
Execute "gdxxrw.exe Output_GTEPJA_all_CalibrationFullModel_BaselineFuelPrice.gdx Par=GCC rng=CompareJPSCC!"
Execute "gdxxrw.exe Output_GTEPJA_all_CalibrationFullModel_BaselineFuelPrice.gdx par=NEOX17 rng=Net_Output_Renewable!"
Execute "gdxxrw.exe Output_GTEPJA_all_CalibrationFullModel_BaselineFuelPrice.gdx par=JPSCoGen rng=CompareJPSCo!"
Execute "gdxxrw.exe Output_GTEPJA_all_CalibrationFullModel_BaselineFuelPrice.gdx par=IPPGen rng=CompareIPPs!"
Execute "gdxxrw.exe Output_GTEPJA_all_CalibrationFullModel_BaselineFuelPrice.gdx par=CapFactor2017 rng=SCapFactor2017!"
Execute "gdxxrw.exe Output_GTEPJA_all_CalibrationFullModel_BaselineFuelPrice.gdx par=CapFactorDiff rng=SCapFactorDiff!"
*$OFFTEXT
;
*------------------------------------------------------------------------
*Output Simultaneous model with Loop flow model
*------------------------------------------------------------------------
*$ONTEXT
Execute_unload "Output_GTEPJA_all_simkvl_BaselineFuelPrice.gdx" stotcost,totcosty, LCOE, powerflow.m, powerflowshare,theta.l,UE.l,uegwh,ueshare,u.l, opcost, SInvcostPlant, SInvcostTline, SBuildplant, SbuildTline,Annual_Generation,GenPortfolio,GenPortfolioShare,capfactor
Execute "gdxxrw.exe Output_GTEPJA_all_simkvl_BaselineFuelPrice.gdx par=stotcost rng=STotalCost!"
Execute "gdxxrw.exe Output_GTEPJA_all_simkvl_BaselineFuelPrice.gdx par=TotCosty rng=yrlyTotCost!"
Execute "gdxxrw.exe Output_GTEPJA_all_simkvl_BaselineFuelPrice.gdx par=LCOE rng=LCOE_centskWh!"
Execute "gdxxrw.exe Output_GTEPJA_all_simkvl_BaselineFuelPrice.gdx var=powerflow.m rng=PowerFlowmarginal!"
Execute "gdxxrw.exe Output_GTEPJA_all_simkvl_BaselineFuelPrice.gdx par=powerflowshare rng=PowerFlowShare!"
Execute "gdxxrw.exe Output_GTEPJA_all_simkvl_BaselineFuelPrice.gdx var=theta.l rng=Theta!"
Execute "gdxxrw.exe Output_GTEPJA_all_simkvl_BaselineFuelPrice.gdx var=UE.l rng=Unserved_EnergyMW!"
Execute "gdxxrw.exe Output_GTEPJA_all_simkvl_BaselineFuelPrice.gdx Par=UEGWh rng=Unserved_EnergyGWh!"
Execute "gdxxrw.exe Output_GTEPJA_all_simkvl_BaselineFuelPrice.gdx Par=UEshare rng=Percent_Unmet_Demand!"
Execute "gdxxrw.exe Output_GTEPJA_all_simkvl_BaselineFuelPrice.gdx var=u.l rng=U!"
Execute "gdxxrw.exe Output_GTEPJA_all_simkvl_BaselineFuelPrice.gdx par=opcost rng=OpCost_USDM!"
Execute "gdxxrw.exe Output_GTEPJA_all_simkvl_BaselineFuelPrice.gdx par=SInvcostPlant rng=InvCostPlant!"
Execute "gdxxrw.exe Output_GTEPJA_all_simkvl_BaselineFuelPrice.gdx par=SInvcostTline rng=InvCostTline!"
Execute "gdxxrw.exe Output_GTEPJA_all_simkvl_BaselineFuelPrice.gdx par=SBuildPlant rng=BuildPlant!"
Execute "gdxxrw.exe Output_GTEPJA_all_simkvl_BaselineFuelPrice.gdx par=SBuildTline rng=BuildTline!"
Execute "gdxxrw.exe Output_GTEPJA_all_simkvl_BaselineFuelPrice.gdx par=Annual_Generation rng=Generation_GWh!"
Execute "gdxxrw.exe Output_GTEPJA_all_simkvl_BaselineFuelPrice.gdx par=GenPortfolio rng=GenPortfolio_GWh!"
Execute "gdxxrw.exe Output_GTEPJA_all_simkvl_BaselineFuelPrice.gdx par=GenPortfolioShare rng=GenPortfolioShare!"
Execute "gdxxrw.exe Output_GTEPJA_all_simkvl_BaselineFuelPrice.gdx par=CapFactor rng=SCapFator!"
*$OFFTEXT
;


*$ONTEXT
*===============================================
* SIMULTANEOUS TRANSPORTATION MODEL
*(No loop flow)
*===============================================
*****************************************************************
*In this section, I run the simultaneous model without loop flow
*which becomes a transportation model for the previous problem.
*I then save results in excel file.
*****************************************************************

Model GTEPJA_Transportation /
objdef,
FCostdef,InvCostPdef,InvCostTLdef,
*budget,
POnce,TLOnce,
CThermalGen,
HydroGen,ResMargDef,
PFLimitCTLine1, PFLimitCTLine2,
RPS_cons,
nhreGen, maxnhre,
PowerBalance
/;
option limcol=10;
option limrow=10;
Option MIP = Cplex;
$onecho > cplex.opt
epint 0
nodefileind 3
$offecho
*$ONTEXT
GTEPJA_Transportation.optfile=1 ;
GTEPJA_Transportation.resLim=60480000;
Solve GTEPJA_Transportation using MIP minimizing totcost;
*$OFFTEXT


*--------------------------------------------------------
*Storing Transportation Model outputs in storage parameters
*---------------------------------------------------------
STotCost('no_KVL') = TotCost.l;
SBuildPlant(year,cplant,hyth,'no_KVL')=BuildPlant.l(year,CPlant,hyth);
SBuildPlant(year,cplant,nhre,'no_KVL')=BuildRE.l(year,CPlant,nhre);
SBuildTline(year,ctline,'no_KVL')=BuildTline.l(year,CTline);
TotCostY(year,'no_KVL')= (SUM((quart,dtype,htype),Mquart(quart)*Mday(dtype)*mth(htype)*(
*Fuel & Variable Costs for thermal plants
         SUM((plant,thermal),PGG.l(year,quart,dtype,htype,plant,thermal)*
                 (hrate(plant,thermal)/1000*FuelPrice(year,thermal)+VOM(plant,thermal)))
*Variable Cost for Biomass plants should come here if data available

*Variable Cost for Renewable plants excluding biomass plants
          +SUM((plant,retecnb),PGG.l(year,quart,dtype,htype,plant,retecnb)*VOM(plant,retecnb))

*Unserved energy and dump costs
          + SUM(node,UECost*UE.l(year,quart,dtype,htype,node))
*           + DumpCost*DumpEn(year,quart,dtype,htype,node)
                          ))
      +FixedCost.l(year)
*     + UMR(year)*UMRCost
 )*discf(year)
*Converting to millions of dollars
 /million
*Adding Investment Costs
 + InvCostPlant.l(year) + InvCostTline.l(year);

OpCost(year,'no_KVL') = (SUM((quart,dtype,htype),Mquart(quart)*Mday(dtype)*mth(htype)*(
*Fuel & Variable Costs for thermal plants
         SUM((plant,thermal),PGG.l(year,quart,dtype,htype,plant,thermal)*
                 (hrate(plant,thermal)/1000*FuelPrice(year,thermal)+VOM(plant,thermal)))
*Variable Cost for Biomass plants should come here

*Variable Cost for Renewble plants excluding biomass plants
          +SUM((plant,retecnb),PGG.l(year,quart,dtype,htype,plant,retecnb)*VOM(plant,retecnb))

*Unserved energy and dump costs
          + SUM(node,UECost*UE.l(year,quart,dtype,htype,node))
*           + DumpCost*DumpEn(year,quart,dtype,htype,node)
                          ))
      +FixedCost.l(year)
*     + UMR(year)*UMRCost
 )*discf(year)
*Converting to millions of dollars
 /million;

 SInvCostPlant(year,'no_KVL') = InvCostPlant.l(year);

 SInvCostTLine(year,'no_KVL') = InvCostTline.l(year);

 Annual_Generation(year,'no_KVL') = SUM((quart,dtype,htype,plant,tec),Mquart(quart)*Mday(dtype)*mth(htype)*
         PGG.l(year,quart,dtype,htype,plant,tec))/1000;

 LCOE(year,'no_KVL')= (100*million*TotCostY(year,'no_KVL'))/(million*Annual_Generation (year,'no_KVL'));

 GenPortfolio(year,tec,'no_KVL') = SUM((quart,dtype,htype,plant),Mquart(quart)*Mday(dtype)*mth(htype)*
         PGG.l(year,quart,dtype,htype,plant,tec))/1000;

 GenPortfolioShare(year,tec,'no_KVL')=100* GenPortfolio(year,tec,'no_KVL')/Annual_Generation(year,'no_KVL');

*Display STotCost,TotCostY,OpCost, Annual_Generation,LCOE,GenPortfolio, GenPortfolioShare;


Capfactor(plant,tec,year,'no_KVL')$PlantType(Plant,tec)= SUM((quart,dtype,htype),Mquart(quart)*Mday(dtype)*mth(htype)*
                            PGG.l(year,quart,dtype,htype,plant,tec))/
                           SUM((quart,dtype,htype),Mquart(quart)*Mday(dtype)*mth(htype)*
                             GrossCap(Plant,tec));
*display CapFactor;

Parameter CapFactor2017(plant,retecnb,ModelType) Capacity factor for 2017;

CapFactor2017(plant,retecnb,'no_KVL')$PlantType(Plant,retecnb) = Capfactor(plant,retecnb,'2017','no_KVL');

********************************************************************************************************************
*$OFFTEXT


*------------------------------------------------------------------------
*Output Transportation model
*------------------------------------------------------------------------
*$ONTEXT
Execute_unload "Output_GTEPJA_all_nokvl_BaselineFuelPrice.gdx" stotcost,totcosty, LCOE, powerflow.m,theta.l, opcost, SInvcostPlant, SInvcostTline, SBuildplant, SbuildTline,Annual_Generation,GenPortfolio,GenPortfolioShare,capfactor
Execute "gdxxrw.exe Output_GTEPJA_all_nokvl_BaselineFuelPrice.gdx par=stotcost rng=STotalCost!"
Execute "gdxxrw.exe Output_GTEPJA_all_nokvl_BaselineFuelPrice.gdx par=TotCosty rng=yrlyTotCost!"
Execute "gdxxrw.exe Output_GTEPJA_all_nokvl_BaselineFuelPrice.gdx par=LCOE rng=LCOE_centskWh!"
Execute "gdxxrw.exe Output_GTEPJA_all_nokvl_BaselineFuelPrice.gdx var=powerflow.m rng=PowerFlowmarginal!"
Execute "gdxxrw.exe Output_GTEPJA_all_nokvl_BaselineFuelPrice.gdx var=theta.l rng=Theta!"
Execute "gdxxrw.exe Output_GTEPJA_all_nokvl_BaselineFuelPrice.gdx par=opcost rng=OpCost_USDM!"
Execute "gdxxrw.exe Output_GTEPJA_all_nokvl_BaselineFuelPrice.gdx par=SInvcostPlant rng=InvCostPlant!"
Execute "gdxxrw.exe Output_GTEPJA_all_nokvl_BaselineFuelPrice.gdx par=SInvcostTline rng=InvCostTline!"
Execute "gdxxrw.exe Output_GTEPJA_all_nokvl_BaselineFuelPrice.gdx par=SBuildPlant rng=BuildPlant!"
Execute "gdxxrw.exe Output_GTEPJA_all_nokvl_BaselineFuelPrice.gdx par=SBuildTline rng=BuildTline!"
Execute "gdxxrw.exe Output_GTEPJA_all_nokvl_BaselineFuelPrice.gdx par=Annual_Generation rng=Generation_GWh!"
Execute "gdxxrw.exe Output_GTEPJA_all_nokvl_BaselineFuelPrice.gdx par=GenPortfolio rng=GenPortfolio_GWh!"
Execute "gdxxrw.exe Output_GTEPJA_all_nokvl_BaselineFuelPrice.gdx par=GenPortfolioShare rng=GenPortfolioShare!"
Execute "gdxxrw.exe Output_GTEPJA_all_nokvl_BaselineFuelPrice.gdx par=CapFactor rng=SCapFator!"
*$OFFTEXT
;

*$ONTEXT
*===============================================
* SEQUENTIAL MODEL WITH LOOP FLOW
*===============================================
*****************************************************************
*In this section, I run the sequential model with loop flow.
*Stage 1 is a generation expansion plan excluding transmission considerations.
* The objective is to meet expected aggregate demand at least cost.
*Stage 2 assumes that capacity decisions have been made and transmission investments
*may now be necessary to accommodate the additional capacity.
*I then save results in excel file.
*****************************************************************

Equation  PowerBalance_seqKVL_1 Power Balance equation for stage 1;

PowerBalance_seqKVL_1(year,quart,dtype,htype)..
         SUM((plant,tec)$PlantType(Plant,tec),PGG(year,quart,dtype,htype,plant,tec)/pubase)
          +SUM(node,UE(year,quart,dtype,htype,node)/pubase)=E= sum(node,Demand(node,year,quart,dtype,htype)/pubase);



*Making sure no transmission lines are built in stage 1
BuildTline.fx(year,ctline) = 0;

Model GTEPJA_seqKVL_a /
objdef,
FCostdef,InvCostPdef,InvCostTLdef,
*budget,
POnce,TLOnce,
CThermalGen,
HydroGen,ResMargDef,
RPS_cons,
nhreGen,
maxnhre,
PowerBalance_seqKVL_1
/;
option limcol=0;
option limrow=0;
Option MIP = Cplex;
$onecho > cplex.opt
epint 0
nodefileind 3
$offecho
*$ONTEXT
GTEPJA_seqKVL_a.optfile=1;
GTEPJA_seqKVL_a.resLim=604800;
Solve GTEPJA_seqKVL_a using MIP minimizing totcost;


*Fixing build plant results
buildPlant.fx(year,Cplant,tec) = BuildPlant.l(year,CPlant,tec);


*Writing Output for verification
Execute_unload "Output_GTEPJA_all_2021-03-04_seq_kvl_pt1_BaselineFuelPrice_1195_DemAdj.gdx"  buildPlant.l, buildRE.l, BuildTLine.l
Execute "gdxxrw.exe Output_GTEPJA_all_2021-03-04_seq_kvl_pt1_BaselineFuelPrice_1195_DemAdj.gdx var=BuildPlant.l rng=BuildPlant!"
Execute "gdxxrw.exe Output_GTEPJA_all_2021-03-04_seq_kvl_pt1_BaselineFuelPrice_1195_DemAdj.gdx var=BuildRE.l rng=BuildRE!"
Execute "gdxxrw.exe Output_GTEPJA_all_2021-03-04_seq_kvl_pt1_BaselineFuelPrice_1195_DemAdj.gdx var=BuildTLine.l rng=BuildTLine!"
;


**Setting lower bounds on build variables
BuildPlant.lo(ayear,Cplant,tec) = round(BuildPlant.l(ayear,CPlant,tec));
BuildRE.lo(ayear,Cplant,nhre) = BuildRE.l(ayear,CPlant,nhre);
*BuildES.fx(year,Cplant,nhre) = BuildES.l(year,CPlant,nhre);


*Having fixed plant construction decision, I will now run full model
*===================================================================

*Unfixing build transmission line variable
BuildTline.lo(ayear,CTline)=0;
BuildTline.up(ayear,CTline)=1;

*Again assuming that no new transmission lines will be built before 2019
Buildtline.fx(ayear,Ctline)$(ord(ayear) lt 3)=0;

*Again assuming nothing is built in the first 3 years.
BuildPlant.fx(ayear,Cplant,tec)$(ord(ayear) lt 3)=0;
BuildRE.fx(ayear,Cplant,tec)$(ord(ayear) lt 3)=0;
Buildtline.fx(ayear,ctline)$(ord(ayear) lt 3)=0;


*Again, BuildPlant variable not applicable to nhre units
BuildPlant.fx(ayear,Cplant,nhre)=0;

*Again, BuildRE variable not applicable to hydro or thermal units
BuildRE.fx(ayear,Cplant,hyth)=0;

*Again Ensuring that 37 MW solar plant already scheduled to build will be built
BuildRE.fx(ayear,"NewSolar","solar")$(ord(ayear)+2016 eq COD("NewSolar","solar")) = 37;
BuildRE.fx(ayear+1,"NewSolar","solar")$(ord(ayear)+2016 eq COD("NewSolar","solar")) = 37;

Model GTEPJA_seqKVL_b /
objdef,
FCostdef,InvCostPdef,InvCostTLdef,
*budget,
POnce,TLOnce,
CThermalGen,
HydroGen,ResMargDef,
PFLimitCTLine1, PFLimitCTLine2,
KVL1, KVL2, KVL3, VAdef1, VAdef2,
RPS_cons,
nhreGen, maxnhre,
PowerBalance
/;
option limcol=0;
option limrow=0;
Option MIP = Cplex;
$onecho > cplex.opt
epint 0
nodefileind 3
$offecho
*$ONTEXT
GTEPJA_seqKVL_b.optfile=1;
GTEPJA_seqKVL_b.resLim=60480000;
Solve GTEPJA_seqKVL_b using MIP minimizing totcost;


*--------------------------------------------------------
*Storing Sequential Model outputs in storage parameters
*---------------------------------------------------------
STotCost('seq_KVL_b') = TotCost.l;
SBuildPlant(year,cplant,hyth,'seq_KVL_b')=BuildPlant.l(year,CPlant,hyth);
SBuildPlant(year,cplant,nhre,'seq_KVL_b')=BuildRE.l(year,CPlant,nhre);
SBuildTline(year,ctline,'seq_KVL_b')=BuildTline.l(year,CTline);
TotCostY(year,'seq_KVL_b')= (SUM((quart,dtype,htype),Mquart(quart)*Mday(dtype)*mth(htype)*(
*Fuel & Variable Costs for thermal plants
         SUM((plant,thermal),PGG.l(year,quart,dtype,htype,plant,thermal)*
                 (hrate(plant,thermal)/1000*FuelPrice(year,thermal)+VOM(plant,thermal)))
*Variable Cost for Biomass plants should come here if data available

*Variable Cost for Renewable plants excluding biomass plants
          +SUM((plant,retecnb),PGG.l(year,quart,dtype,htype,plant,retecnb)*VOM(plant,retecnb))

*Unserved energy and dump costs
          + SUM(node,UECost*UE.l(year,quart,dtype,htype,node))
*           + DumpCost*DumpEn(year,quart,dtype,htype,node)
                          ))
      +FixedCost.l(year)
*     + UMR(year)*UMRCost
 )*discf(year)
*Converting to millions of dollars
 /million
*Adding Investment Costs
 + InvCostPlant.l(year) + InvCostTline.l(year);

OpCost(year,'seq_KVL_b') = (SUM((quart,dtype,htype),Mquart(quart)*Mday(dtype)*mth(htype)*(
*Fuel & Variable Costs for thermal plants
         SUM((plant,thermal),PGG.l(year,quart,dtype,htype,plant,thermal)*
                 (hrate(plant,thermal)/1000*FuelPrice(year,thermal)+VOM(plant,thermal)))
*Variable Cost for Biomass plants should come here

*Variable Cost for Renewble plants excluding biomass plants
          +SUM((plant,retecnb),PGG.l(year,quart,dtype,htype,plant,retecnb)*VOM(plant,retecnb))

*Unserved energy and dump costs
          + SUM(node,UECost*UE.l(year,quart,dtype,htype,node))
*           + DumpCost*DumpEn(year,quart,dtype,htype,node)
                          ))
      +FixedCost.l(year)
*     + UMR(year)*UMRCost
 )*discf(year)
*Converting to millions of dollars
 /million;

 SInvCostPlant(year,'seq_KVL_b') = InvCostPlant.l(year);

 SInvCostTLine(year,'seq_KVL_b') = InvCostTline.l(year);

 Annual_Generation(year,'seq_KVL_b') = SUM((quart,dtype,htype,plant,tec),Mquart(quart)*Mday(dtype)*mth(htype)*
         PGG.l(year,quart,dtype,htype,plant,tec))/1000;

 LCOE(year,'seq_KVL_b')= (100*million*TotCostY(year,'seq_KVL_b'))/(million*Annual_Generation (year,'seq_KVL_b'));

 GenPortfolio(year,tec,'seq_KVL_b') = SUM((quart,dtype,htype,plant),Mquart(quart)*Mday(dtype)*mth(htype)*
         PGG.l(year,quart,dtype,htype,plant,tec))/1000;

 GenPortfolioShare(year,tec,'seq_KVL_b')=100* GenPortfolio(year,tec,'seq_KVL_b')/Annual_Generation(year,'seq_KVL_b');

*Display STotCost,TotCostY,OpCost, Annual_Generation,LCOE,GenPortfolio, GenPortfolioShare;


Capfactor(plant,tec,year,'seq_KVL_b')$PlantType(Plant,tec)= SUM((quart,dtype,htype),Mquart(quart)*Mday(dtype)*mth(htype)*
                            PGG.l(year,quart,dtype,htype,plant,tec))/
                           SUM((quart,dtype,htype),Mquart(quart)*Mday(dtype)*mth(htype)*
                             GrossCap(Plant,tec));
*display CapFactor;

Parameter CapFactor2017(plant,retecnb,ModelType) Capacity factor for 2017;

CapFactor2017(plant,retecnb,'seq_KVL_b')$PlantType(Plant,retecnb) = Capfactor(plant,retecnb,'2017','seq_KVL_b');


*------------------------------------------------------------------------
*Output for Sequential Model - Baseline Fuel Price Scenario
*------------------------------------------------------------------------
*$ONTEXT
Execute_unload "Output_GTEPJA_all_seqkvlCombined_BaselineFuelPrice.gdx" stotcost,totcosty, LCOE, powerflow.m, opcost, SInvcostPlant, SInvcostTline, SBuildplant, SbuildTline,Annual_Generation,GenPortfolio,GenPortfolioShare,capfactor
Execute "gdxxrw.exe Output_GTEPJA_all_seqkvlCombined_BaselineFuelPrice.gdx par=stotcost rng=STotalCost!"
Execute "gdxxrw.exe Output_GTEPJA_all_seqkvlCombined_BaselineFuelPrice.gdx par=TotCosty rng=yrlyTotCost!"
Execute "gdxxrw.exe Output_GTEPJA_all_seqkvlCombined_BaselineFuelPrice.gdx par=LCOE rng=LCOE_centskWh!"
Execute "gdxxrw.exe Output_GTEPJA_all_seqkvlCombined_BaselineFuelPrice.gdx var=powerflow.m rng=PowerFlowmarginal!"
Execute "gdxxrw.exe Output_GTEPJA_all_seqkvlCombined_BaselineFuelPrice.gdx par=opcost rng=OpCost_USDM!"
Execute "gdxxrw.exe Output_GTEPJA_all_seqkvlCombined_BaselineFuelPrice.gdx par=SInvcostPlant rng=InvCostPlant!"
Execute "gdxxrw.exe Output_GTEPJA_all_seqkvlCombined_BaselineFuelPrice.gdx par=SInvcostTline rng=InvCostTline!"
Execute "gdxxrw.exe Output_GTEPJA_all_seqkvlCombined_BaselineFuelPrice.gdx par=SBuildPlant rng=BuildPlant!"
Execute "gdxxrw.exe Output_GTEPJA_all_seqkvlCombined_BaselineFuelPrice.gdx par=SBuildTline rng=BuildTline!"
Execute "gdxxrw.exe Output_GTEPJA_all_seqkvlCombined_BaselineFuelPrice.gdx par=Annual_Generation rng=Generation_GWh!"
Execute "gdxxrw.exe Output_GTEPJA_all_seqkvlCombined_BaselineFuelPrice.gdx par=GenPortfolio rng=GenPortfolio_GWh!"
Execute "gdxxrw.exe Output_GTEPJA_all_seqkvlCombined_BaselineFuelPrice.gdx par=GenPortfolioShare rng=GenPortfolioShare!"
Execute "gdxxrw.exe Output_GTEPJA_all_seqkvlCombined_BaselineFuelPrice.gdx par=CapFactor rng=SCapFator!"
*$OFFTEXT
