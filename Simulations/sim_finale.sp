* Finalny Testbufor - Symulacja Post-Layout @ 30MHz (Naprawiony)
.include "tsmc180_t77a_spice.lib"
.include "projekt.spice"

* --- OPCJE ---
.options allow_ambiguous_models tnom=27

* --- ZASILANIE ---
V_VDD Vdd 0 1.8
V_GND gnd 0 0
* Zasilanie podłoża (Bulk) - upewnij się, że etykiety Vdd# i Vss są w projekt.spice
V_B1 Vdd# 0 1.8
V_B2 Vss  0 0

* --- WEJŚCIE (30 MHz) ---
* T = 1/30meg = 33.333ns
* PULSE(Vlow Vhigh Tdel Trise Tfall Ton Tperiod)
Vin in 0 PULSE(0 1.8 0n 0.1n 0.1n 16.57n 33.33n)

* --- OBCIĄŻENIE (25 pF + 15 mA) ---
CL1 Q1 0 25p
* Źródło behawioralne wymuszające 15mA (sink/source)
B_LOAD1 Q1 0 I = if(V(Q1) > 0.9, 15m, -15m)

* --- INSTANCJA PROJEKTU ---
* Uwaga: Sprawdź czy kolejność pinów w projekt.spice zgadza się z tą poniżej!
X1 Vdd gnd in Q1 in Q2 in Q3 in Q4 in Q5 in Q6 projekt

* ==========================================================
* ANALIZA TRANSIENT (Czasowa)
* ==========================================================
* Symulujemy 100ns, żeby zobaczyć 3 pełne cykle
.tran 0 100n

* --- POMIARY ---

* 1. Czasy zboczy (10% - 90%) na drugim cyklu
.measure tran tr_30m TRIG V(Q1) VAL=0.18 RISE=2 TARG V(Q1) VAL=1.62 RISE=2
.measure tran tf_30m TRIG V(Q1) VAL=1.62 FALL=2 TARG V(Q1) VAL=0.18 FALL=2

* 2. Poziomy napięć wyjściowych przy obciążeniu 15mA
.measure tran VOH_30m FIND V(Q1) AT 25n
.measure tran VOL_30m FIND V(Q1) AT 40n

* 3. Średni pobór prądu z VDD (Moc dynamiczna)
.measure tran I_avg_30m AVG I(V_VDD) FROM=0 TO=100n

.end
