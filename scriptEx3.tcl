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
#Mis au debut c est pour le routage 
$ns rtproto DV

set NodeNb 8
for {set i 1} {$i<=$NodeNb} {set i [expr $i+1]} {set n($i) [$ns node]}

$ns duplex-link $n(1) $n(3) 10Mb 10ms DropTail
$ns duplex-link $n(2) $n(3) 10Mb 10ms DropTail
$ns duplex-link $n(3) $n(4) 10Mb 10ms DropTail
$ns duplex-link $n(3) $n(5) 10Mb 10ms DropTail
$ns duplex-link $n(4) $n(6) 10Mb 10ms DropTail
$ns duplex-link $n(5) $n(8) 10Mb 10ms DropTail
$ns duplex-link $n(6) $n(7) 10Mb 10ms DropTail
$ns duplex-link $n(8) $n(7) 10Mb 10ms DropTail

$ns duplex-link-op $n(1) $n(3) orient right-down
$ns duplex-link-op $n(2) $n(3) orient left-down
$ns duplex-link-op $n(3) $n(4) orient right-down
$ns duplex-link-op $n(3) $n(5) orient left-down
$ns duplex-link-op $n(4) $n(6) orient right-down
$ns duplex-link-op $n(5) $n(8) orient right-down
$ns duplex-link-op $n(6) $n(7) orient left-down
$ns duplex-link-op $n(8) $n(7) orient right

set udp [new Agent/UDP]
$ns attach-agent $n(1) $udp
set udp2 [new Agent/UDP]
$ns attach-agent $n(2) $udp2

set null [new Agent/Null]
$ns attach-agent $n(8) $null

$ns connect $udp $null
$ns connect $udp2 $null


set cbr [new Application/Traffic/CBR]
$cbr set packetSize_ 500
$cbr set interval_ 5ms
$cbr attach-agent $udp

set cbr2 [new Application/Traffic/CBR]
$cbr2 set packetSize_ 500
$cbr2 set interval_ 5ms
$cbr2 attach-agent $udp2


$ns color 1 Blue 
$udp set class_ 1

$ns color 3 Green
$udp2 set class_ 3


$ns at 1 "$cbr start"
$ns at 2 "$cbr2 start"

$ns rtmodel-at 4 down $n(5) $n(8)
$ns rtmodel-at 5 up $n(5) $n(8)

$ns at 6 "$cbr2 stop"
$ns at 7 "$cbr stop"
#appeler la procédure de terminaison après un temps t (ex t=5s)
$ns at 8.0 "finish"

#Exécuter la simulation 
$ns run



