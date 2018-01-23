#Création d'une instance de l'objet Simulator
set ns [new Simulator]
#Ouvrir le fichier trace pour nam
set nf [open out.nam w]
$ns namtrace-all $nf

#Definir la procédure de terminaison de la simulation 
proc finish {} {
	global ns nf qEC qCS

	$ns flush-trace
	#fermer le fichier trace 
	close $nf
	#Exécuter le nam avec en entrée le fichier trace 
	exec nam out.nam &
#retrouver quelques resultats et paramètres de la simulation 
$qEC printPolicyTable
#$qCS printStats
$qEC printPolicerTable
#$qCS printPHBTable
$qEC printStats
	exit 0
}
#Insérer 

set c1 [$ns node]
set c2 [$ns node]
set edge [$ns node]
set core [$ns node]
set server [$ns node]

set cir1 1000000
set cir2 500000

#Declaration des liens
$ns simplex-link $c1 $edge 1.5Mb 2ms DropTail
$ns simplex-link $c2 $edge 1.5Mb 2ms DropTail
$ns simplex-link $edge $core 1.5Mb 2ms dsRED/edge
$ns simplex-link $core $server 1.5Mb 2ms dsRED/core

#Positionnement des liens
$ns simplex-link-op $c1 $edge orient right-down
$ns simplex-link-op $c2 $edge orient right-up
$ns simplex-link-op $edge $core orient right
$ns simplex-link-op $core $server orient right

#Definition des agents
set udp [new Agent/UDP]
$ns attach-agent $c1 $udp
set udp2 [new Agent/UDP]
$ns attach-agent $c2 $udp2

set null [new Agent/Null]
$ns attach-agent $server $null
set null2 [new Agent/Null]
$ns attach-agent $server $null2

$ns connect $udp $null
$ns connect $udp2 $null2

set cirp [expr $cir1+10000] 
set cbr [new Application/Traffic/CBR]
$cbr set rate_ $cirp
$cbr attach-agent $udp

set cbr2 [new Application/Traffic/CBR]
$cbr2 set rate_ $cir2
$cbr2 attach-agent $udp2

#Pointeur sur le buffer du lien 
set qEC [[$ns link $edge $core] queue]

#Configurer les parameters entre un noed edge et un autre core 
$qEC meanPktSize 210
$qEC set numQueues_ 1
$qEC setNumPrec 2
$qEC addPolicyEntry [$c1 id] [$server id] TokenBucket 10 $cir1 500
$qEC addPolicyEntry [$c2 id] [$server id] Null 34
$qEC addPolicerEntry TokenBucket 10 12
$qEC addPolicerEntry Null 34
$qEC addPHBEntry 10 0 0  
$qEC addPHBEntry 12 0 1
$qEC addPHBEntry 34 0 0


#configurer le buffer DS RED
$qEC configQ 0 0 4 10 0.1
$qEC configQ 0 1 2 5 0.5
#$qEC configQ 0 1 10 20 0.10

#configurer les parameters entre Core et Edge
set qCS [[$ns link $core $server] queue]

$qCS meanPktSize 210
$qCS set numQueues_ 1
$qCS setNumPrec 2
$qCS addPHBEntry 10 0 0  
$qCS addPHBEntry 12 0 1
$qCS addPHBEntry 34 0 0

#retrouver quelques resultats et paramètres de la simulation 
$qEC printPolicyTable
$qCS printStats
$qEC printPolicerTable
$qCS printPHBTable
$qEC printStats

$ns at 0.0 "$cbr start"
$ns at 0.0 "$cbr2 start"

#$ns at 5 "$cbr2 stop"
#$ns at 5 "$cbr stop"
#appeler la procédure de terminaison après un temps t (ex t=5s)
$ns at 5 "finish"

#Exécuter la simulation 
$ns run



