* Kompleksowa symulacja 5-stopniowego bufora - Pre-Layout Fixed
.include "tsmc180_t77a_spice.lib"

* --- OPCJE ---
.options allow_ambiguous_models tnom=27

* --- ZASILANIE ---
V_DD VDD 0 1.8
V_SS VSS 0 0

* --- WEJŚCIE (30 MHz) ---
Vin in 0 PULSE(0 1.8 0n 0.1n 0.1n 16.57n 33.33n)

* --- SCHEMAT 5-STOPNIOWEGO BUFORA ---
X1 VDD in out VSS bufor_5st

* --- OBCIĄŻENIE DYNAMICZNE I STATYCZNE (15 mA + 25 pF) ---
CL out 0 25p
* Poprawione obciążenie: 15mA pobierane z wyjścia (sink/source)
B_LOAD out 0 I = if(V(out) > 0.9, 15m, -15m)

* --- DEFINICJE PODUKŁADÓW ---
.subckt bufor_5st VDD IN OUT VSS
X1 VDD IN n1 VSS inv_stage Wn=0.4u Wp=1.0u
X2 VDD n1 n2 VSS inv_stage Wn=1.6u Wp=4.0u
X3 VDD n2 n3 VSS inv_stage Wn=6.4u Wp=16.0u
X4 VDD n3 n4 VSS inv_stage Wn=26.0u Wp=66.0u
X5 VDD n4 OUT VSS inv_stage Wn=135.0u Wp=340.0u
.ends

.subckt inv_stage VDD_p IN OUT VSS_p Wn=1u Wp=2.5u
M1 OUT IN VDD_p VDD_p pfet w={Wp} l=0.2u
M2 OUT IN VSS_p VSS_p nfet w={Wn} l=0.2u
.ends

* --- ANALIZA CZASOWA (Transient) ---
.tran 0 100n

* --- POMIARY (Ctrl+L po symulacji) ---

* 1. Wydajność prądowa: Napięcia przy obciążeniu 15mA (Poprawione czasy!)
.measure tran VOH_15mA FIND V(out) AT 10n
.measure tran VOL_15mA FIND V(out) AT 25n

* 2. Czasy narastania i opadania (10% - 90%)
.measure tran trise_pre TRIG V(out) VAL=0.18 RISE=2 TARG V(out) VAL=1.62 RISE=2
.measure tran tfall_pre TRIG V(out) VAL=1.62 FALL=2 TARG V(out) VAL=0.18 FALL=2

* 3. Maksymalny prąd szczytowy
.measure tran I_peak_max MAX ABS(I(V_DD))

* --- ANALIZA DC (Napięcie przełączania) ---
* Aby zobaczyć VTC, zakomentuj .tran i .measure tran powyżej, a odkomentuj poniższe:
*.dc Vin 0 1.8 0.001
.measure dc V_switching WHEN V(out)=V(in)

.end
