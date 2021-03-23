#Creating simulator object 
set ns [new Simulator]   

#Creating the nam file
set nf [open out.nam w]      
#It opens the file 'out.nam' for writing and gives it the file handle 'nf'. 
$ns namtrace-all $nf

#Finish Procedure  (closes the trace file and starts nam) 
proc finish {} {
        global ns nf
        $ns flush-trace
        close $nf
        exec nam out.nam &
        exit 0
        }
#The trace data is flushed into the file by using command $ns flush-trace and then file is closed.

$ns color 1 blue

set oldIndex 0
set nodes(0) [$ns node]
for { set index 1 }  { $index < 7 }  { incr index } {
   set oldIndex [expr $index - 1]
   set nodes($index) [$ns node]
   $ns duplex-link $nodes($oldIndex) $nodes($index) 512Kb 5ms DropTail 
}
$ns duplex-link $nodes(6) $nodes(0) 512Kb 5ms DropTail

$ns rtproto DV

#Creating a UDP agent,Specifying udp traffic to have red color and attaching it to n0
set udp0 [new Agent/UDP]
$udp0 set fid_ 1        
$ns attach-agent $nodes(0) $udp0
#Creating the Null agent,Attaching it to n3 and connecting it with udp agent
set null0 [new Agent/Null]
$ns attach-agent $nodes(3) $null0     
$ns connect $udp0 $null0
#Creating the CBR agent to generate the traffic over udp0 agent ,and attaching cbr0 with udp0
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 1024
#Each packet will be generated after 0.01s i.e. 100 packets per second
$cbr0 set interval 0.01
$cbr0 attach-agent $udp0

#brings down the link between node 2 and node 3 at 0.4.
$ns rtmodel-at 0.4 down $nodes(2) $nodes(3)
#brings the dropped link back up at 1.0.
$ns rtmodel-at 1.0 up $nodes(2) $nodes(3)

#Starting the cbr traffic
$ns at 0.02 "$cbr0 start"
$ns at 1.5 "$cbr0 stop"

#Calling the finish procedure
$ns at 2.0 "finish"

#Run the simulation
$ns run

#doneq1