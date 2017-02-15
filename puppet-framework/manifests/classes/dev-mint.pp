class nookdevapp-mintdb {

        file {
                "/var/www/html/mint/config/db.php" :
			backup => false,
                        owner => "joomla",
                        group => "apache",
                        mode => 755,
                        replace => true,
			source => "puppet://$server/modules/nookdev-mint/db.php"
	}
}
	
