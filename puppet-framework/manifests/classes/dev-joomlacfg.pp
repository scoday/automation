class nookdevapp-joomlacfg {

        file {
                "/var/www/configuration.php" :
			backup => false,
                        owner => "joomla",
                        group => "apache",
                        mode => 755,
                        replace => true,
			source => "puppet://$server/modules/nookdev-joomlacfg/configuration.php"
	}
}
	
