class devapp-fstab {

	file {
		"/etc/fstab" :
			backup => false,
			owner => "root", 
			group => "root", 
			mode => 644,
			replace => true,
			source => "puppet://$server/dev-baseconfig/fstab/fstab.devapp" 
			
			}
}
