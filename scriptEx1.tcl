#Création d'une instance de l'objet Simulator
set ns [new Simulator]
#Ouvrir le fichier trace pour nam
set nf [open out.nam w]
$ns namtrace-all $nf

#Definir la procédure de terminaison de la simulation 
proc finish {} {
	global ns nf
	$ns flush-trace
	#fermer le fichier trace 
	close $nf
	#Exécuter le nam avec en entrée le fichier trace 
	exec nam out.nam &
	exit 0
}
#Insérer 
set NodeNb 1
for {set i 0} {$i<=$NodeNb} {set i [expr $i+1]} {set n($i) [$ns node]}
$ns duplex-link $n(0) $n(1) 1Mb 10ms DropTail

set udp [new Agent/UDP]
$ns attach-agent $n(0) $udp

set cbr [new Application/Traffic/CBR]
$cbr set packetSize_ 500
$cbr set interval_ 5ms
$cbr attach-agent $udp

set null [new Agent/Null]
$ns attach-agent $n(1) $null
$ns connect $udp $null
$ns at 1 "$cbr start"
$ns at 4.5 "$cbr stop"

#appeler la procédure de terminaison après un temps t (ex t=5s)
$ns at 5.0 "finish"

#Exécuter la simulation 
$ns run
