class nookdevapp-phpini {

        file {
                "/etc/php.ini" :
			backup => false,
                        owner => "root",
                        group => "root",
                        mode => 644,
                        replace => true,
                       # before => Service["httpd"],
                       # notify => Service["httpd"],
			source => "puppet://$server/modules/nookdev-phpini/php.ini"
	}
}
	
