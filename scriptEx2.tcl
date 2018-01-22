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
set NodeNb 3
for {set i 0} {$i<=$NodeNb} {set i [expr $i+1]} {set n($i) [$ns node]}
$ns duplex-link $n(0) $n(2) 2Mb 10ms DropTail
$ns duplex-link $n(1) $n(2) 2Mb 10ms DropTail
$ns duplex-link $n(2) $n(3) 1.7Mb 20ms DropTail

$ns duplex-link-op $n(0) $n(2) orient right-down
$ns duplex-link-op $n(1) $n(2) orient right-up
$ns duplex-link-op $n(2) $n(3) orient right

$ns queue-limit $n(2) $n(3) 10

set udp [new Agent/UDP]
$ns attach-agent $n(1) $udp

set tcp [new Agent/TCP]
$ns attach-agent $n(0) $tcp

set sink [new Agent/TCPSink]
$ns attach-agent $n(3) $sink

set null [new Agent/Null]
$ns attach-agent $n(3) $null

$ns connect $udp $null
$ns connect $tcp $sink



set cbr [new Application/Traffic/CBR]
$cbr set packetSize_ 1000
$cbr set rate_ 1Mb
$cbr attach-agent $udp

set ftp [new Application/FTP]
$ftp attach-agent $tcp

$ns color 1 Blue 
$udp set class_ 1

$ns color 2 Red
$sink set class_ 2

$ns color 3 Green
$tcp set class_ 3


$ns at 0.1 "$cbr start"
$ns at 4.5 "$cbr stop"

$ns at 1 "$ftp start"
$ns at 4 "$ftp stop"


#appeler la procédure de terminaison après un temps t (ex t=5s)
$ns at 5.0 "finish"

#Exécuter la simulation 
$ns run
