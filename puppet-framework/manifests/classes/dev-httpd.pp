class nookdevapp-httpd {

        file {
                "/etc/httpd/conf/httpd.conf" :
			backup => false,
                        owner => "root",
                        group => "root",
                        mode => 644,
                        replace => true,
                        before => Service["httpd"],
                        notify => Service["httpd"],
			source => "puppet://$server/modules/nookdev-httpd/conf/httpd.conf"
	}
}
	
