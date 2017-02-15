class devapp-UTC {

        file {
                "/etc/localtime" :
			backup => false,
                        owner => "root",
                        group => "root",
                        mode => 644,
                        replace => true,
                        source => "puppet://$server/dev-baseconfig/dev-utc/localtime"

                        }
}
